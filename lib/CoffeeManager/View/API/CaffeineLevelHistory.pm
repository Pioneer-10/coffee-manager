package CoffeeManager::View::API::CaffeineLevelHistory;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my $caffeine_history = shift;

	return bless {
		'items' => $caffeine_history,
	}, ref($class) || $class;
}

sub serialize {
	my $self = shift;

	return [map { {
		'level' => $_->level,
		'timestamp' => $_->timestamp->iso8601,
	} } @{ $self->{'items'} }];
}

sub TO_JSON {
	return shift->serialize;
}

1;
