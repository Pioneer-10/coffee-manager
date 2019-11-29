package CoffeeManager::Model::Coffee;

use strict;
use warnings;
use utf8;

use CoffeeManager::Data::Coffee;
use CoffeeManager::Data::Machine;

use parent qw/CoffeeManager::Model::Base/;

use constant MACHINE_TABLE_NAME => 'coffee_machine';
use constant COFFEE_TABLE_NAME => 'coffee_consumption';


sub create_machine {
	my $self = shift;
	my $params = { @_ };

	$self->validate_mandatory($params, qw/name caffeine/)
	or return;
	$self->validate_integer($params, qw/caffeine/)
	or return;

	my @fields = qw/name caffeine/;
	my $dbh = $self->dbh;

	$dbh->do(
		"
			INSERT INTO @{[ $dbh->quote_identifier($self->MACHINE_TABLE_NAME) ]}
			(@{[ join(', ', map { $dbh->quote_identifier($_) } @fields) ]})
			VALUES (@{[ join(', ', map { '?' } @fields) ]})
		",
		undef,
		@$params{@fields},
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return CoffeeManager::Data::Machine->new(%$params, id => $dbh->last_insert_id);
}

sub take_machine {
	my $self = shift;
	my $id = shift;

	$self->validate_mandatory({'id' => $id}, qw/id/)
	or return;
	$self->validate_integer({'id' => $id}, qw/id/)
	or return;

	my $dbh = $self->dbh;
	my $row = $dbh->selectrow_hashref(
		"
			SELECT *
			FROM @{[ $dbh->quote_identifier($self->MACHINE_TABLE_NAME) ]}
			WHERE @{[ $dbh->quote_identifier('id') . ' = ?' ]}
		",
		undef,
		$id,
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return unless ($row);
	return CoffeeManager::Data::Machine->new(%$row);
}

sub list_machines {
	my $self = shift;
	my $id_list = shift;
	return [] unless (@$id_list);

	my $params = {map { ($_, $id_list->[$_]) } 0..$#$id_list};

	$self->validate_mandatory($params, keys %$params)
	or return;
	$self->validate_integer($params, keys %$params)
	or return;

	my $dbh = $self->dbh;
	my $rows = $dbh->selectall_arrayref(
		"
			SELECT *
			FROM @{[ $dbh->quote_identifier($self->MACHINE_TABLE_NAME) ]}
			WHERE @{[ $dbh->quote_identifier('id') . ' IN (' . join(',', map { '?' } @$id_list) . ')' ]}
		",
		{ 'Slice' => {}, },
		@$id_list,
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return [map { CoffeeManager::Data::Machine->new(%$_) } @$rows];
}

sub register_coffee {
	my $self = shift;
	my $params = { @_ };

	$self->validate_mandatory($params, qw/user_id machine_id timestamp/)
	or return;
	$self->validate_integer($params, qw/user_id machine_id timestamp/)
	or return;

	my @fields = qw/user_id machine_id timestamp/;
	my $dbh = $self->dbh;

	$dbh->do(
		"
			INSERT INTO @{[ $dbh->quote_identifier($self->COFFEE_TABLE_NAME) ]}
			(@{[ join(', ', map { $dbh->quote_identifier($_) } @fields) ]})
			VALUES (@{[ join(', ', map { '?' } @fields) ]})
		",
		undef,
		@$params{@fields},
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return CoffeeManager::Data::Coffee->new(%$params, id => $dbh->last_insert_id);
}

sub list_coffees {
	my $self = shift;
	my $params = { @_ };

	my @fields = grep { exists($params->{$_}) } qw/user_id machine_id/;
	$self->validate_mandatory($params, @fields)
	or return;
	$self->validate_integer($params, @fields)
	or return;

	my $dbh = $self->dbh;
	my $rows = $dbh->selectall_arrayref(
		"
			SELECT *
			FROM @{[ $dbh->quote_identifier($self->COFFEE_TABLE_NAME) ]}
		"
		. ((scalar(@fields)) ? "
			WHERE @{[ join(' AND ', map { $dbh->quote_identifier($_) . ' = ?' } @fields) ]}
		" : "")
		. "ORDER BY @{[ $dbh->quote_identifier('timestamp') ]}",
		{ 'Slice' => {}, },
		@$params{@fields},
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return CoffeeManager::Data::Coffee::Collection->new(@$rows);
}

sub get_caffeine_level {
	my $self = shift;
	my $params = { @_ };

	$self->validate_mandatory($params, qw/user_id timestamp/)
	or return;
	$self->validate_integer($params, qw/user_id timestamp/)
	or return;

	my $dbh = $self->dbh;
	my $field_timestamp = $dbh->quote_identifier('timestamp');
	my $data = $dbh->selectrow_arrayref(
		"
			SELECT SUM(
				CASE $field_timestamp >= ? - 3600
				WHEN TRUE THEN (? - $field_timestamp) * caffeine * 1.0 / 3600
				ELSE caffeine * POW(2, 1.0 * ($field_timestamp + 3600 - ?) / 5 / 3600) END
			)
			FROM
				@{[ $dbh->quote_identifier($self->COFFEE_TABLE_NAME) ]} AS B
				INNER JOIN
				@{[ $dbh->quote_identifier($self->MACHINE_TABLE_NAME) ]} AS D
				ON (B.machine_id = D.id)
			WHERE $field_timestamp < ? AND @{[ $dbh->quote_identifier('user_id') ]} = ?
		",
		undef,
		@$params{qw/timestamp timestamp timestamp timestamp user_id/},
	);
	return $self->db_error($dbh->errstr) if ($dbh->err);
	return $data->[0] || 0;
}

1;
