package CoffeeManager::Model::Base;

use strict;
use warnings;
use utf8;

use CoffeeManager::Error::DB;
use CoffeeManager::Error::Validation;


sub new {
	my $class = shift;
	my $dbh = shift;

	return bless {
		'_dbh' => $dbh,
	}, ref($class) || $class;
}

sub dbh {
	my $self = shift;
	return $self->{'_dbh'};
}

sub error {
	my $self = shift;

	unless (scalar(@_)) {
		return $self->{'_error'};
	}
	$self->{'_error'} = shift;
	return
}

sub db_error {
	my $self = shift;
	my $msg = shift;

	return $self->error(CoffeeManager::Error::DB->new($msg));
}

sub validate_mandatory {
	my $self = shift;
	my $data = shift;

	if (my @fields = grep { !defined($data->{$_}) || ref($data->{$_}) ne '' || $data->{$_} eq '' } @_) {
		return $self->error(CoffeeManager::Error::Validation->new('missing', @fields));
	}
	return 1;
}

sub validate_integer {
	my $self = shift;
	my $data = shift;

	if (my @fields = grep { $data->{$_} && $data->{$_} =~ /\D/ } @_) {
		return $self->error(CoffeeManager::Error::Validation->new('not_integer', @fields));
	}
	return 1;
}

1;
