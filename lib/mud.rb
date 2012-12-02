require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/json'
require 'arml'
require 'rack/accept'

class Mud < Sinatra::Base
	class Error < Arml::Error
	end

  register Sinatra::Synchrony
	helpers Sinatra::JSON

	set :reload_templates, false
	set :show_exceptions, false
	set :json_encoder, :to_json
	set :method_override, true # so we can use PUT from forms
	enable :sessions

StatusCodes = {
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',                      # RFC 2518 (WebDAV)
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',                    # RFC 2518 (WebDAV)
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Request Range Not Satisfiable',
    417 => 'Expectation Failed',
    422 => 'Unprocessable Entity',            # RFC 2518 (WebDAV)
    423 => 'Locked',                          # RFC 2518 (WebDAV)
    424 => 'Failed Dependency',               # RFC 2518 (WebDAV)
    425 => 'No code',                         # WebDAV Advanced Collections
    426 => 'Upgrade Required',                # RFC 2817
    449 => 'Retry with',                      # unofficial Microsoft
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',         # RFC 2295
    507 => 'Insufficient Storage',            # RFC 2518 (WebDAV)
    509 => 'Bandwidth Limit Exceeded',        # unofficial
    510 => 'Not Extended',                    # RFC 2774
};

	use Rack::Accept

	@@mainroom = nil
	@@initialized = false

	def scode(thing)
		return StatusCodes[thing] || ''
	end

	def player
		@current_player
	end

# Gets the options for the given object
#
# @param [String] resource_type The type of resource to get options for
# @param [Arml::Common] obj The object that the options should apply to
# @return [Array] An array of hashrefs describing the valid options
	def get_options_for(resource_type, obj = nil)
		#TODO can we generate the routes from this?
		opts = {}
		opts['object'] = [
			{
				href: lambda { |o| o[:href] },
				action: "examine",
				parameters: {}
			},
			{
				href: lambda { |o| o[:href] + '/take' },
				action: "take",
				description: "Take the object",
				parameters: {},
				prereq: lambda { |p,o| p.parent == o.parent }
			},
			{
				href: lambda { |o| o[:href] + '/drop' },
				action: "drop",
				description: "Drop the object",
				parameters: {},
				prereq: lambda { |p,o| p.has?(o) }
			}
		];
		opts['room'] = [
			{
				href: lambda { |o| o[:href] },
				action: "examine",
				parameters: {}
			},
			{
				href: lambda { |o| o[:href] + '/create_exit' },
				action: "create exit",
				description: "Link this room with another",
				method: "PUT",
				parameters: {
					direction: {
						type: 'String',
						description: 'The direction you wish to create the exit on'
					},
					to: {
						type: 'String',
						description: 'The identifier of the room you want to link to'
					}
				}
			},
			{
				href: '/room',
				method: 'POST',
				description: 'Create a new room',
				parameters: {
					name: {
						type: 'String',
						description: 'The name of the room to create'
					},
					description: {
						type: 'String',
						description: 'A description of the room'
					}
				}
			}
		];

		return [] if !opts[resource_type]

		# Limit to this resource type
		valid_opts = opts[resource_type]

		# Process some of the values
		valid_opts.each do |e|
			skip_key = false
			e.each do |k,v|
				# Delete empty keys
				e.delete(k) if v.respond_to?(:empty?) && v.empty?	
				# Attempt to resolve lambdas
				if v.is_a?(Proc)
					if obj
						if v.arity == 1
							# 1-arg functions just need the resource
							e[k] = v.call(obj.to_resource)
						elsif v.arity == 2
							# 2-arg functions need a player and object
							e[k] = v.call(player,obj)
						end
					else
						skip_key = true
					end
				end
			end
			e[:prereq] = false if skip_key
		end

		# Restrict to those that have passed the prereq
		valid_opts.select! {|e| !e.has_key?(:prereq) || e[:prereq] == true}

		return valid_opts
	end

# Initialize the game (only persists while webserver is running)
	def self.init_game
		return if @@initialized
		@@initialized = true
		Arml.db.collection('room').remove({})
		Arml.db.collection('player').remove({})
		Arml.db.collection('object').remove({})
		@@mainroom = Arml::Room.new({ name: 'The entrance hall' })
		mainroom = @@mainroom
		mainroom.save!
		room2 = Arml::Room.new({ name: 'The back room', description: 'A scary place' })
		room2.save!
		mainroom.add_exit('North', room2)
		room2.add_exit('South', @@mainroom)
		obj = Arml::Object.new({ name: 'A ball' })
		obj.save!
		mainroom.take(obj)
		initialized = true
	end

# Creates the player from the session key, if it can
	def set_player
		if !session[:player_id] || !@current_player = find(session[:player_id])
			raise Mud::Error, "You need to go to /enter first"
		end
	end

	get '/enter' do
		return redirect('/self') if @current_player = find(session[:player_id])
		name = params[:name] || 'New player'
		player = Arml::Player.new({ name: name })
		player.save!
		player.move_to_room(@@mainroom)
		player.reload
		session[:player_id] = player.id.to_s
		@current_player = player
		redirect('/self')
	end

	before do
		ENV["ARML_URI_PREFIX"] = "http://#{request.host_with_port}"
		Mud.init_game
		set_player if request.path != '/enter' && !request.options?
	end

	error Arml::Error do
		errmsg = env['sinatra.error']
		render errmsg
	end

	error do
		errmsg = env['sinatra.error']
		errmsg.message
	end

	def html_head
		return %Q{<h1>#{status} - #{scode(status.to_i)}</h1><a href="/self">self</a> | <a href="/look">look</a><br>}
	end

# Render POST/PUT options as forms. We use the _method hack (See use of
# :method_override)
	def form_from_options(opts)
		form_html = ''
		opts.select {|e| e.has_key?(:method) && e[:method].match(/POST|PUT/)}.each do |opt|
			form_html += %Q{<h3>#{opt[:description]}</h3>}
			form_html += %Q{<form method="POST" action="#{opt[:href]}">\n}
			if opt[:method] != "POST"
				form_html += %Q{<input type="hidden" name="_method" value="#{opt[:method]}">}
			end

			opt[:parameters].each do |k, v|
				form_html += %Q{#{v[:description]} <input type="text" name="#{k}"><br>\n}
			end
			form_html += '<input type="submit" value="Do"></form><br>'
		end
		return form_html
	end

# Generate HTML from the options if in a browser, otherwise return json
	def render_options(resource_type, o = nil)
		accept = env['rack-accept.request']
		options = get_options_for(resource_type, o)
		options_json = JSON.pretty_generate(options)
		out = ""
		unless options.empty? 
			if accept.media_type?('text/html')
				form_html = form_from_options(options)
				unless form_html.empty?
					out += "<br><h1>Forms</h1>#{form_html}"
				end
				out += "<br><h1>Options</h1><pre>#{linkify(options_json)}</pre>"
			else
				content_type('application/json')
				out = options_json
			end
		end
		return out
	end

	def linkify(str)
			str.gsub( %r{http://[^"\s]+} ) do |url|
    		"<a href='#{url}'>#{url}</a>"
			end
	end
# Attempts to render 'something' as the client requests it. Yet, it's that
# generic.
#
# @param [Object] thing The thing we want to render, usually an object
# @return [String] HTML or JSON, depending on the Accept header
	def render(thing)
		accept = env['rack-accept.request']

		out = ''
		jout = ''
		if thing.respond_to?(:to_json)
			jout = thing.to_json
		else
			jout = JSON.pretty_generate(thing)
		end

		if accept.media_type?('text/html')
			jout = "<pre>#{jout}</pre>"

			out = html_head + jout
			out = linkify(out)

# If the thing looks like a resource, we can be clever and work out the options
# for it too

			if thing.respond_to?(:db_key)
				resource_type = thing.db_key
				options_html = render_options(resource_type, thing)
				out += options_html
			end

		else
			content_type('application/json')
			out = jout
		end
		return out
	end

	def user
		@current_player
	end

  def initialize
    ENV["ARML_MONGO_URI"] = ENV["MONGOLAB_URI"]
  end

	def find(id)
		return nil if !id
		id = Arml::Id.from_string(id)
		return Arml.find(id)
	end

	get '/look' do
		redirect("/room/#{self.player.current_room.id}")
	end

	get %r{/here(/.+)?} do |match|
		redirect("/look#{match}")
	end

	get %r{/self(/.+)?} do |match|
		redirect("/player/#{self.player.id}#{match}")
	end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end

	get '/room/:id' do |id|
		room = find(id)
		raise Mud::Error, "No such room" if !room

		cr = player.current_room

		if (cr != room && !cr.connected_to?(room))
			raise Mud::Error, "You don't know about that room"
		end
		if (cr != room)
			player.move_to_room(room)
		end
		return render room
	end

	post '/room' do
		# assume everyone can create rooms at this point
		name = params[:name] or raise Mud::Error, "Must at least have a name"
		hash = {
			name: name
		}
		hash[:description] = params[:description] if params[:description]
		newroom = Arml::Room.new(hash)
		newroom.save!
		status 201
		return render newroom
	end

	put '/room/:id/create_exit' do |id|
		room = find(id) or raise Mud::Error, "No such room"
		if room != player.current_room
			raise Mud::Error, "You're not in that room"
		end
		direction = params[:direction] or raise Mud::Error, "direction required"
		to				= params[:to]				 or raise Mud::Error, "to required"
		to_room = find(to) or raise Mud::Error, "Can't create an exit to a room that doesn't exist"
		player.create_exit_to(direction, to_room)
		status 201
		return render player.current_room
	end

	get '/player/:id/enter_room' do
		room_id = params[:room_id] or raise Mud::Error, "Need a room id"
		if params[:id] != player.id
			raise Mud::Error, "You are not that user"
		end
		player.move_to_room_id(room_id)
		return find(room_id).to_json
	end

	get '/player/:id' do |id|
		return render find(id)
	end


	get '/object/:id' do |id|
		obj = find(id)
		if !player.has?(obj) && obj.parent != player.current_room
			raise Mud::Error, "You can't see that object"
		end
		return render obj
	end

	get '/object/:id/take' do |id|
		obj = find(id)
		player.pickup(obj)
		return render player
	end

	get '/object/:id/drop' do |id|
		obj = find(id)
		player.drop(obj)
		return render player
	end
  
  get '/create' do
    key = Arml::Room.new({ name: "one", description: "desc" }).save
    return key._id.to_s
  end

  get '/load/:id' do |id|
    room = Arml::Room.load(id)
    room.to_json
  end

	get '/room' do
		render_options('room')
	end

### RENDER JSON FOR TEH OPTIONS
	options '/room' do
		render_options('room')
	end

	options '/room/:id' do |id|
		render_options('room', find(id))
	end

	options '/object/:id' do |id|
		render_options('object', find(id))
	end

end
