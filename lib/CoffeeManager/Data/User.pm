package CoffeeManager::Data::User;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my %params = @_;

	return bless {
		map { ($_, $params{$_}) } qw/id login password email/
	}, ref($class) || $class;
}

sub id { return shift->{'id'} }
sub login { return shift->{'login'} }
sub password { return shift->{'password'} }
sub email { return shift->{'email'} }

1;
