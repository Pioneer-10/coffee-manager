package CoffeeManager::Error::Validation;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my $code = shift;
	my @fields = @_;

	return bless {
		code => $code,
		fields => \@fields,
	}, ref($class) || $class;
}

sub code {
	return shift->{'code'};
}

sub reason {
	my $self = shift;
	my $reason = $self->code;
	$reason =~ s/[_\s]+/ /g;
	return $reason;
}

sub as_string {
	my $self = shift;
	return "The following fields are @{[ $self->reason ]}: @{[ join(', ', sort @{ $self->{'fields'} }) ]}";
}

1;
