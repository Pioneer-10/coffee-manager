package CoffeeManager::View::API::NewRow;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my $row = shift;

	return bless { 'id' => $row->id, }, ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return { 'id' => $self->{'id'}, };
}

sub TO_JSON {
	return shift->serialize;
}

1;
