package CoffeeManager::View::API::User;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my $user = shift;

	return bless {
		'user' => $user,
	}, ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return {
		'id' => $self->{'user'}->id,
		'login' => $self->{'user'}->login,
	};
}

sub TO_JSON {
	return shift->serialize;
}

1;
