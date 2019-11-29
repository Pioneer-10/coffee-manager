package CoffeeManager::Error::DB;

use strict;
use warnings;
use utf8;

use constant code => 'db_error';


sub new {
	my $class = shift;
	my $message = shift;

	return bless {
		message => $message,
	}, ref($class) || $class;
}

sub as_string {
	my $self = shift;
	return "Database error occurred: $self->{'message'}";
}

1;
