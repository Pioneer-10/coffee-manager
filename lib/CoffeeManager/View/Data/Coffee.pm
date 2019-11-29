package CoffeeManager::View::Data::Coffee;

use strict;
use warnings;
use utf8;

use CoffeeManager::View::Data::DateTime;


sub new {
	my $class = shift;
	my %params = @_;

	return bless {
		(map { ($_, $params{$_}) } qw/id user machine/),
		'timestamp' => CoffeeManager::View::Data::DateTime->new($params{'timestamp'}),
	}, ref($class) || $class;
}

sub id { return shift->{'id'} }
sub user { return shift->{'user'} }
sub machine { return shift->{'machine'} }
sub timestamp { return shift->{'timestamp'} }

1;
