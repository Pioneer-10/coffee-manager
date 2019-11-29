package CoffeeManager::View::Data::CoffeeHistory;

use strict;
use warnings;
use utf8;

use CoffeeManager::View::Data::Coffee;


sub new {
	my $class = shift;
	my $coffee_history = shift;
	my $users = shift;
	my $machines = shift;

	my $user_map = {map { ($_->id, $_) } @$users};
	my $machine_map = {map { ($_->id, $_) } @$machines};

	my $data = [];
	foreach my $item (@$coffee_history) {
		push(@$data, CoffeeManager::View::Data::Coffee->new(
			id => $item->{'id'},
			user => $user_map->{ $item->{'user_id'} },
			machine => $machine_map->{ $item->{'machine_id'} },
			timestamp => $item->{'timestamp'},
		));
	}

	return bless $data, ref($class) || $class;
}

1;
