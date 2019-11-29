package CoffeeManager::Adapter::Action;

use strict;
use warnings;
use utf8;

=head1 NAME

CoffeeManager::Adapter::Action - implementation of action layer for the CoffeeManager application

=cut

use Time::Piece qw//;

use CoffeeManager::Error::NotFound;
use CoffeeManager::Error::Validation;
use CoffeeManager::Model::Coffee;
use CoffeeManager::Model::User;
use CoffeeManager::View::Data::CaffeineLevel;
use CoffeeManager::View::Data::Coffee;
use CoffeeManager::View::Data::CoffeeHistory;


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

sub user_model {
	my $self = shift;
	return CoffeeManager::Model::User->new($self->dbh);
}

sub coffee_model {
	my $self = shift;
	return CoffeeManager::Model::Coffee->new($self->dbh);
}

sub register_user {
	my $self = shift;
	my $params = shift;

	my $model = $self->user_model;
	my $user = $model->create_user(%$params)
	or return $self->error($model->error);
	return $user;
}

sub add_coffee_machine {
	my $self = shift;
	my $params = shift;

	my $model = $self->coffee_model;
	my $machine = $model->create_machine(%$params)
	or return $self->error($model->error);
	return $machine;
}

sub buy_some_coffee {
	my $self = shift;
	my $params = shift;

	$params->{'timestamp'} = time();
	return $self->register_coffee($params);
}

sub register_some_coffee {
	my $self = shift;
	my $params = shift;

	unless (defined($params->{'timestamp'})) {
		return $self->buy_some_coffee($params);
	}

	eval {
		$params->{'timestamp'} =~ s/Z\Z/+0000/;
		$params->{'timestamp'} =~ s/(?<=[+-]\d\d):(?=\d\d\Z)//;
		$params->{'timestamp'} = Time::Piece->strptime($params->{'timestamp'}, '%Y-%m-%dT%H:%M:%S%z');
	};
	return $self->error(CoffeeManager::Error::Validation->new('not_ISO8601_date' => 'timestamp')) if ($@);

	$params->{'timestamp'} = $params->{'timestamp'}->epoch;
	return $self->register_coffee($params);
}

sub register_coffee {
	my $self = shift;
	my $params = shift;

	my $user_model = $self->user_model;
	my $coffee_model = $self->coffee_model;
	my $user = $user_model->take_user($params->{'user_id'})
	or return $self->error(
		$user_model->error || CoffeeManager::Error::NotFound->new(user => $params->{'user_id'})
	);
	my $machine = $coffee_model->take_machine($params->{'machine_id'})
	or return $self->error(
		$coffee_model->error || CoffeeManager::Error::NotFound->new(machine => $params->{'machine_id'})
	);

	my $coffee = $coffee_model->register_coffee(
		user_id => $user->id,
		machine_id => $machine->id,
		timestamp => $params->{'timestamp'},
	)
	or return $self->error($coffee_model->error);

	return CoffeeManager::View::Data::Coffee->new(
		id => $coffee->id,
		user => $user,
		machine => $machine,
		timestamp => $coffee->timestamp,
	);
}

sub get_stats_coffee {
	my $self = shift;
	my $params = shift;

	my $user_model = $self->user_model;
	my $coffee_model = $self->coffee_model;
	my $coffees = $coffee_model->list_coffees(
		(defined($params->{'slice_attr'})) ? ($params->{'slice_attr'}, $params->{ $params->{'slice_attr'} }) : ()
	)
	or return $self->error($coffee_model->error);
	my $users = $user_model->list_users($coffees->user_id)
	or return $self->error($user_model->error);
	my $machines = $coffee_model->list_machines($coffees->machine_id)
	or return $self->error($coffee_model->error);

	return CoffeeManager::View::Data::CoffeeHistory->new($coffees, $users, $machines);
}

sub get_stats_caffeine_level {
	my $self = shift;
	my $params = shift;

	return $self->get_stats_caffeine_level_at($params, time());
}

sub get_stats_caffeine_level_at {
	my $self = shift;
	my $params = shift;
	my $timestamp = shift;

	my $user_model = $self->user_model;
	my $coffee_model = $self->coffee_model;
	my $user = $user_model->take_user($params->{'user_id'})
	or return $self->error(
		$user_model->error || CoffeeManager::Error::NotFound->new(user => $params->{'user_id'})
	);
	my $caffeine_history = [];

	foreach my $hour (reverse 0..24) {
		my $ts = $timestamp - $hour * 3600;
		my $level = $coffee_model->get_caffeine_level(user_id => $user->id, timestamp => $ts);
		return $self->error($coffee_model->error) if ($coffee_model->error);
		push(@$caffeine_history, CoffeeManager::View::Data::CaffeineLevel->new(
			level => $level,
			timestamp => $ts,
		));
	}
	return $caffeine_history;
}

1;
