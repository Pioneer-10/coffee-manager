package CoffeeManager::View::API::Coffee;

use strict;
use warnings;
use utf8;

use CoffeeManager::View::API::Machine;
use CoffeeManager::View::API::User;


sub new {
	my $class = shift;
	my $coffee = shift;

	return bless {
		'user' => CoffeeManager::View::API::User->new($coffee->user),
		'machine' => CoffeeManager::View::API::Machine->new($coffee->machine),
		'timestamp' => $coffee->timestamp,
	}, ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return {
		'machine' => $self->{'machine'}->serialize,
		'user' => $self->{'user'}->serialize,
		'timestamp' => $self->{'timestamp'}->iso8601,
	};
}

sub TO_JSON {
	return shift->serialize;
}

1;
