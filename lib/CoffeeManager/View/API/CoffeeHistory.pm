package CoffeeManager::View::API::CoffeeHistory;

use strict;
use warnings;
use utf8;

use CoffeeManager::View::API::Coffee;


sub new {
	my $class = shift;
	my $coffee_history = shift;

	return bless [
		map { CoffeeManager::View::API::Coffee->new($_) } @$coffee_history
	], ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return [map { $_->serialize } @$self];
}

sub TO_JSON {
	return shift->serialize;
}

1;
