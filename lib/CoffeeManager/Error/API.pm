package CoffeeManager::Error::API;

use strict;
use warnings;
use utf8;

use constant code => 'bad_request';


sub new {
	my $class = shift;
	my $message = shift;

	return bless {
		message => $message,
	}, ref($class) || $class;
}

sub as_string {
	my $self = shift;
	return "$self->{'message'}";
}

1;
