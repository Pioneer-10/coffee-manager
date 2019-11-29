#!perl

use strict;
use warnings;
use utf8;

use DBI;


my $dbh = DBI->connect('dbi:SQLite:dbname=coffee.db')
or die "DBI->connect(): $DBI::errstr";

$dbh->do("
	CREATE TABLE user (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		login VARCHAR(255) NOT NULL,
		email VARCHAR(255) NOT NULL,
		password VARCHAR(255) NOT NULL
	)
");
die "CreateTable(user): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE UNIQUE INDEX uk_login ON user (login)
");
die "CreateIndex(unique(user.login)): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE UNIQUE INDEX uk_email ON user (email)
");
die "CreateIndex(unique(user.email)): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE TABLE coffee_machine (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name VARCHAR(255) NOT NULL,
		caffeine INTEGER NOT NULL
	)
");
die "CreateTable(coffee_machine): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE TABLE coffee_consumption (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		user_id INTEGER NOT NULL,
		machine_id INTEGER NOT NULL,
		timestamp INTEGER NOT NULL
	)
");
die "CreateTable(coffee_consumption): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE INDEX idx_history ON coffee_consumption (timestamp)
");
die "CreateIndex(coffee_consumption.timestamp): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE INDEX idx_user_history ON coffee_consumption (user_id, timestamp)
");
die "CreateIndex(coffee_consumption.user_id, coffee_consumption.timestamp): $dbh->errstr" if ($dbh->err);

$dbh->do("
	CREATE INDEX idx_machine_history ON coffee_consumption (machine_id, timestamp)
");
die "CreateIndex(coffee_consumption.machine_id, coffee_consumption.timestamp): $dbh->errstr" if ($dbh->err);
