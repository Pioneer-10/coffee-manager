package CoffeeManager::View::Data::CaffeineLevel;

use strict;
use warnings;
use utf8;

use CoffeeManager::View::Data::DateTime;


sub new {
	my $class = shift;
	my %params = @_;

	return bless {
		'level' => $params{'level'},
		'timestamp' => CoffeeManager::View::Data::DateTime->new($params{'timestamp'}),
	}, ref($class) || $class;
}

sub level { return shift->{'level'} }
sub timestamp { return shift->{'timestamp'} }

1;
