package CoffeeManager::Error::Encode;

use strict;
use warnings;
use utf8;

use constant code => 'encode_error';


sub new {
	my $class = shift;
	my $message = shift;

	return bless {
		message => $message,
	}, ref($class) || $class;
}

sub as_string {
	my $self = shift;
	return "Encode/decode error occurred: $self->{'message'}";
}

1;
