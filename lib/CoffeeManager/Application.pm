package CoffeeManager::Application;

use strict;
use warnings;
use utf8;

use DBI;
use Plack::Response;
use Routes::Tiny;

use CoffeeManager::Adapter::Action;
use CoffeeManager::Adapter::API;


sub new {
	my $class = shift;

	my $self = bless {}, ref($class) || $class;
	$self->_init_routes;
	return $self;
}

sub dbh {
	my $self = shift;

	unless ($self->{'_dbh'}) {
		$self->{'_dbh'} = DBI->connect('dbi:SQLite:dbname=coffee.db')
		or die "DBI->connect(): $DBI::errstr";

		$self->{'_dbh'}->sqlite_create_function('POW', 2, sub { my ($x, $y) = @_; return $x ** $y })
	}
	return $self->{'_dbh'};
}

sub _init_routes {
	my $self = shift;

	my $routes = $self->{'_routes'} = Routes::Tiny->new;

	# users
	$routes->add_route(PUT => '/user/request', name => 'register_user');

	# coffee manager
	$routes->add_route(POST => '/machine', name => 'add_coffee_machine');
	$routes->add_route(POST => '/coffee/buy/:user_id/:machine_id', name => 'buy_some_coffee');
	$routes->add_route(PUT => '/coffee/buy/:user_id/:machine_id', name => 'register_some_coffee');
	$routes->add_route(
		GET => '/stats/coffee',
		name => 'get_stats_coffee',
		arguments => {qw/action get_stats_coffee/},
	);
	$routes->add_route(
		GET => '/stats/coffee/machine/:machine_id',
		name => 'get_stats_coffee_machine',
		arguments => {qw/action get_stats_coffee slice_attr machine_id/},
	);
	$routes->add_route(
		GET => '/stats/coffee/user/:user_id',
		name => 'get_stats_coffee_user',
		arguments => {qw/action get_stats_coffee slice_attr user_id/},
	);
	$routes->add_route(GET => '/stats/level/user/:user_id', name => 'get_stats_caffeine_level');
}

sub handle_request {
	my $self = shift;
	my $request = shift;

	if (my $match = $self->{'_routes'}->match($request->path, method => $request->env->{'REQUEST_METHOD'})) {
		my $adapter = CoffeeManager::Adapter::API->new($self->dbh, 'CoffeeManager::Adapter::Action');
		return $adapter->handle_request(
			$request,
			$match->arguments->{'action'} || $match->name,
			$match->captures,
			$match->arguments,
		);
	}
	return $self->handle_not_found($request);
}

sub handle_not_found {
	my $self = shift;
	my $request = shift;

	my $response = Plack::Response->new(404);
	$response->content_type('text/plain');
	$response->body("Requested URL @{[ $request->path ]} was not found");

	return $response->finalize;
}

1;
