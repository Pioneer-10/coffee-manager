package CoffeeManager::View::API::Machine;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my $machine = shift;

	return bless {
		'machine' => $machine,
	}, ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return {
		'id' => $self->{'machine'}->id,
		'name' => $self->{'machine'}->name,
	};
}

sub TO_JSON {
	return shift->serialize;
}

1;
