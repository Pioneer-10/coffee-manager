package CoffeeManager::Encoder::JSON;

use strict;
use warnings;
use utf8;

use JSON::XS;

use CoffeeManager::Error::Encode;

use constant MIME_TYPE => 'application/json';


sub new {
	my $class = shift;

	return bless {
		'_engine' => JSON::XS->new->utf8->allow_nonref->convert_blessed
	}, ref($class) || $class;
}

sub error {
	my $self = shift;

	unless (scalar(@_)) {
		return $self->{'_error'};
	}
	$self->{'_error'} = CoffeeManager::Error::Encode->new(@_);
	return
}

sub encode {
	my $self = shift;
	my $data = shift;

	my $str;
	eval {
		local $SIG{__DIE__} = 'IGNORE';
		local $SIG{__WARN__} = 'IGNORE';
		$str = $self->{'_engine'}->encode($data);
	};
	return $self->error("$@") if ($@);
	return $str;
}

sub decode {
	my $self = shift;
	my $str = shift;

	my $data;
	eval {
		local $SIG{__DIE__} = 'IGNORE';
		local $SIG{__WARN__} = 'IGNORE';
		$data = $self->{'_engine'}->decode($str);
	};
	return $self->error("$@") if ($@);
	return $data;
}

1;
