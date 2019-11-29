package CoffeeManager::View::Data::DateTime;

use strict;
use warnings;
use utf8;

use Time::Piece qw//;


sub new {
	my $class = shift;
	my $timestamp = shift;

	return bless {
		'object' => Time::Piece->new($timestamp),
	}, ref($class) || $class;
}

sub timestamp {
	return shift->{'object'}->epoch;
}

sub iso8601 {
	return shift->{'object'}->strftime('%Y-%m-%dT%H:%M:%S%z');
}

1;
