#!env perl
use strict;
use warnings;

use 5.010;

use feature qw(switch);

use JSON qw(from_json to_json);

use HTTP::Request::Common;
use WWW::Mechanize;
use Data::Dumper;
use List::Util qw(shuffle);
use Data::Random qw(:all);

my $host = shift || "http://localhost:9299";

my $mech = WWW::Mechanize->new;
$mech->add_header(Accept => 'application/json');

# start the game
$mech->get("$host/enter");

my $key = json()->{session_key};
$mech->add_header('X-Authentication' => $key);

while(1) {
	# check out our surroundings first
	$mech->get("$host/look");
	my $j = json();

	# find all the entities
	my @links = find_links($j);

	# find every possible option
	my @all_options = map { my $opts = options($_); @$opts } @links;

	# pick one
	for my $opt (shuffle @all_options) {
		$opt->{description} ||= '';
		print "Going to $opt->{action} (ref: $opt->{link})\n";
		# do it
		make_request_for_option($opt);
		last;
	}
}


sub json {
	return eval { from_json($mech->response->content) } or die $mech->response->content;
}

sub make_request_for_option {
	my $opt = shift;
	my $href = $opt->{href};
	my $method = $opt->{method} || 'GET';
	my $params = {};
	while (my ($param_name, $param) = each %{$opt->{parameters}}) {
		given ($param->{type}) {
			when ('String') {
				$params->{$param_name} = random_string();
			}
			default { die "Don't know what to do with $param->{type}" }
		}
	}
	if ($method eq 'PUT') {
		$params->{_method} = 'PUT';
		$method = 'POST';
	}
	my $lcm = lc $method;
	my @args = %$params ? ($params) : ();
	$mech->$lcm($href, @args);
}

sub find_links {
    my $hash = shift;
    my @subthings =
      ref $hash eq 'HASH' ? values %$hash : ref $hash eq 'ARRAY' ? @$hash : ();
    return ( ( ref $hash eq 'HASH' ? ( $hash->{href} || () ) : () ),
        map { find_links($_) } @subthings );
}

sub options {
	my $link = shift;
	my $r = HTTP::Request->new(OPTIONS => $link);
	$mech->request($r);
	my $opts = json();
	$_->{link} = $link for @$opts;
	$opts
}

sub random_string {
	return join ' ', rand_words(size => int(rand(10)))
}
