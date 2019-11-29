package CoffeeManager::Data::Machine;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my %params = @_;

	return bless {
		map { ($_, $params{$_}) } qw/id name caffeine/
	}, ref($class) || $class;
}

sub id { return shift->{'id'} }
sub name { return shift->{'name'} }
sub caffeine { return shift->{'caffeine'} }

1;
