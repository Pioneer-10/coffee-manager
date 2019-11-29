package CoffeeManager::Error::NotFound;

use strict;
use warnings;
use utf8;

use constant code => 'not_found';


sub new {
	my $class = shift;
	my $resource_type = shift;
	my $resource_id = shift;

	return bless {
		resource_type => $resource_type,
		resource_id => $resource_id,
	}, ref($class) || $class;
}

sub as_string {
	my $self = shift;
	return "The requested $self->{'resource_type'} '$self->{'resource_id'}' was not found";
}

1;
