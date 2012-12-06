require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/json'
require 'greygoo'
require 'rack/accept'

# The web app.
class Mud < Sinatra::Base
# Errors to do with the web app
	class Error < GreyGoo::Error
	end

# alias
	Permissions = GreyGoo::PermissionsError
# alias
	NotFound = GreyGoo::NotFoundError
# alias
	WrongArgs = GreyGoo::WrongArgsError

  register Sinatra::Synchrony
	helpers Sinatra::JSON

	set :reload_templates, false
	set :show_exceptions, false
	set :json_encoder, :to_json
	set :method_override, true # so we can use PUT from forms

	enable :sessions

# Just to make the HTML output nicer.
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

# Converts a status code to text
	def scode(thing)
		return StatusCodes[thing] || ''
	end

# Accessor for the player receiving this request
	def player
		@current_player
	end

# Gets the options for the given object
#
# @param [String] resource_type The type of resource to get options for
# @return [Array] An array of hashrefs describing the valid options
	def get_options_for(resource_type, *a)
		return GreyGoo::Options.get_options_for(resource_type, player, *a)
	end

# Initialize the game (only persists while webserver is running)
	def self.init_game
		return if @@initialized
		@@initialized = true
		GreyGoo.db.collection('room').remove({})
		GreyGoo.db.collection('player').remove({})
		GreyGoo.db.collection('object').remove({})
		@@mainroom = GreyGoo::Room.new({ name: 'The entrance hall' })
		mainroom = @@mainroom
		mainroom.save!
		room2 = GreyGoo::Room.new({ name: 'The back room', description: 'A scary place' })
		room2.save!
		mainroom.add_exit('North', room2)
		room2.add_exit('South', @@mainroom)
		obj = GreyGoo::Object.new({ name: 'A ball' })
		obj.save!
		mainroom.take(obj)
		initialized = true
	end

# Creates the player from the session key, if it can
	def set_player
		unless session[:player_id] && @current_player = find(session[:player_id])
			return redirect('/enter')
		end
	end

# Create a new player, or redirect if alreay logged in
	get '/enter' do
		return redirect('/self') if @current_player = find(session[:player_id])
		name = params[:name] || 'New player'
		player = GreyGoo::Player.new({ name: name })
		player.save!
		player.move_to_room(@@mainroom)
		player.reload
		session[:player_id] = player.id.to_s
		@current_player = player
		redirect('/self')
	end

	before do
		ENV["GREYGOO_URI_PREFIX"] = "http://#{request.host_with_port}"
		Mud.init_game
		set_player if request.path != '/enter' && !request.options?
	end

# Grabs the exception and renders it 
	def render_error
		errmsg = env['sinatra.error']
		render errmsg
	end

	error GreyGoo::Error do
		render_error
	end

	error GreyGoo::PermissionsError do
		status 403
		render_error
	end

	error GreyGoo::NotFoundError do
		status 404
		render_error
	end

	error GreyGoo::WrongArgsError do
		status 400
		render_error
	end

	error do
		errmsg = env['sinatra.error']
		errmsg.message
	end

# Just some html for now
	def html_head
		return %Q{<html><head><title>GreyGoo</title></head><body><h1>#{status} - #{scode(status.to_i)}</h1><a href="/player">player</a> | <a href="/room">room</a><br>}
	end

# Just some html for now
	def html_footer
		%Q{</body></html>}
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
	def render_options(resource_type, *a)
		accept = env['rack-accept.request']
		options = get_options_for(resource_type, *a)

		# If in the root, also get options for the resource
		unless a.empty?
			request.path.match(%r{/(\w+)$}) do |thing|
				options += get_options_for(thing[1])
			end
		end

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

# Convert urls to links and shorten the text, purely for making the html look nicer.
	def linkify(str)
			str.gsub( %r{http://[^"\s]+} ) do |url|
				short = url.gsub(%r{^.*#{Regexp.quote(request.host_with_port)}}, '')
    		"<a href='#{url}'>#{short}</a>"
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

		if thing.respond_to?(:to_resource)
			resource_obj = thing
			res = resource_obj.to_resource
			# append messages
			if player.has_messages?
				msgs = player.get_messages!
				res.update(msgs)
			end
			jout = JSON.pretty_generate(res)
		elsif thing.respond_to?(:to_json)
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
				#TODO get options by classname instead
				resource_type = thing.db_key
				options_html = render_options(resource_type, thing)
				out += options_html
			end

			out += html_footer

		else
			content_type('application/json')
			out = jout
		end
		return out
	end

  def initialize
    ENV["GREYGOO_MONGO_URI"] = ENV["MONGOLAB_URI"]
  end

# Shortcut to #GreyGoo.find
	def find(id)
		return nil if !id
		id = GreyGoo::Id.from_string(id)
		return GreyGoo.find(id)
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

		if (cr != room)
			unless player.can?(:enter, room)
				raise Mud::Error, "You don't know about that room"
			end
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
		newroom = GreyGoo::Room.new(hash)
		newroom.save!
		status 201
		return render newroom
	end

	post '/room/:id/create_object' do |id|
		room = find(id) or raise GreyGoo::NotFoundError, "No such room"
		if room != player.current_room
			raise Mud::Error, "You're not in that room"
		end
		o = GreyGoo::Object.new({ name: params[:name], description: params[:description] })
		o.save!
		room.take(o)
		render room
	end


	put '/room/:id/create_exit' do |id|
		room = find(id) or raise Mud::Error, "No such room"
		if room != player.current_room
			raise Mud::Error, "You're not in that room"
		end
		direction = params[:direction] or raise GreyGoo::WrongArgsError, "direction required"
		to				= params[:to]				 or raise GreyGoo::WrongArgsError, "to required"
		to_room = find(to) or raise GreyGoo::NotFoundError, "Can't create an exit to a room that doesn't exist"
		player.create_exit_to(direction, to_room)
		status 201
		return render player.current_room
	end

	get '/player/:id' do |id|
		return render find(id)
	end

	post '/player/:id/message' do |id|
		p = find(id)
		player.send_to(p, params[:message])
		return render p
	end

	get '/message/:id' do |id|
		msg = find(id) or raise NotFound, "That message doesn't exist"
		if msg.to != player && msg.from != player
			raise Permissions, "You can't view that message"
		end
		msg.read
		return render msg
	end

	get '/object/:id' do |id|
		obj = find(id)
		if !player.can?(:examine, obj)
			raise Permissions, "You can't see that object"
		end
		return render obj
	end

	get '/object/:id/take' do |id|
		obj = find(id)
		player.pickup(obj)
		return render player
	end

	get '/object/:id/drop' do |id|
		obj = find(id) or raise NotFound, "That object doesn't exist"
		player.drop(obj)
		return render player
	end
  
  get '/create' do
    key = GreyGoo::Room.new({ name: "one", description: "desc" }).save
    return key._id.to_s
  end

	post '/room/:id/broadcast' do |id|
		room = find(id) or raise NotFound, "No such room"
		player.broadcast_to(room, params[:message])
		player.reload
		return render room
	end

	get '/room' do
		cr = player.current_room
		render player.current_room
	end

	get '/player' do
		render player
	end

	get '/object' do
		render_options('object')
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
