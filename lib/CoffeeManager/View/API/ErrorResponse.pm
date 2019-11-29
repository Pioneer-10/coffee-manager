package CoffeeManager::View::API::ErrorResponse;

use strict;
use warnings;
use utf8;

use constant DEFAULT_HTTP_CODE => 400;
use constant ERROR_HTTP_CODE => {
	'not_found' => 404,
};


sub new {
	my $class = shift;
	my $error = shift;

	return bless {
		'error' => $error,
	}, ref($class) || $class;
}

sub http_code {
	my $self = shift;

	return $self->ERROR_HTTP_CODE->{ $self->{'error'}->code } || $self->DEFAULT_HTTP_CODE;
}

sub serialize {
	my $self = shift;

	return {
		'error_code' => $self->{'error'}->code,
		'error_text' => $self->{'error'}->as_string,
	};
}

sub TO_JSON {
	return shift->serialize;
}

1;
