package CoffeeManager::Model::User;

use strict;
use warnings;
use utf8;

use CoffeeManager::Data::User;

use parent qw/CoffeeManager::Model::Base/;

use constant TABLE_NAME => 'user';


sub create_user {
	my $self = shift;
	my $params = { @_ };

	$self->validate_mandatory($params, qw/login password email/)
	or return;
	$self->validate_unique($params, qw/login email/)
	or return;

	my @fields = qw/login password email/;
	my $dbh = $self->dbh;
	$dbh->do(
		"
			INSERT INTO @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			(@{[ join(', ', map { $dbh->quote_identifier($_) } @fields) ]})
			VALUES (@{[ join(', ', map { '?' } @fields) ]})
		",
		undef,
		@$params{@fields},
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return CoffeeManager::Data::User->new(%$params, id => $dbh->last_insert_id);
}

sub validate_unique {
	my $self = shift;
	my $data = shift;
	my @fields = @_
	or return 1;

	$self->validate_mandatory($data, @fields)
	or return;

	my $dbh = $self->dbh;
	my $counts = $dbh->selectrow_hashref(
		"
			SELECT @{[
				join(', ', map {
					qq/SUM(CASE $_ = ? WHEN TRUE THEN 1 ELSE 0 END) AS $_/
				} map {
					$dbh->quote_identifier($_)
				} @fields)
			]}
			FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			WHERE @{[ join(' OR ', map { $dbh->quote_identifier($_) . '=?' } @fields) ]}
		",
		undef,
		@$data{@fields}, @$data{@fields},
	);
	return $self->db_error($dbh->errstr) if ($dbh->err);

	if (my @existing_fields = grep { $counts->{$_} } @fields) {
		return $self->error(CoffeeManager::Error::Validation->new('not_unique', @existing_fields));
	}
	return 1;
}

sub take_user {
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
			FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			WHERE @{[ $dbh->quote_identifier('id') . ' = ?' ]}
		",
		undef,
		$id,
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return unless ($row);
	return CoffeeManager::Data::User->new(%$row);
}

sub list_users {
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
			FROM @{[ $dbh->quote_identifier($self->TABLE_NAME) ]}
			WHERE @{[ $dbh->quote_identifier('id') . ' IN (' . join(',', map { '?' } @$id_list) . ')' ]}
		",
		{ 'Slice' => {}, },
		@$id_list,
	);

	return $self->db_error($dbh->errstr) if ($dbh->err);
	return [map { CoffeeManager::Data::User->new(%$_) } @$rows];
}

1;
