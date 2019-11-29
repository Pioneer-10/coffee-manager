package CoffeeManager::Data::Coffee;

use strict;
use warnings;
use utf8;


sub new {
	my $class = shift;
	my %params = @_;

	return bless {
		map { ($_, $params{$_}) } qw/id user_id machine_id timestamp/
	}, ref($class) || $class;
}

sub id { return shift->{'id'} }
sub user_id { return shift->{'user_id'} }
sub machine_id { return shift->{'machine_id'} }
sub timestamp { return shift->{'timestamp'} }


package CoffeeManager::Data::Coffee::Collection;

sub new {
	my $class = shift;

	my $data = [];
	foreach my $item (@_) {
		push(@$data, {map { ($_, $item->{$_}) } qw/id user_id machine_id timestamp/});
	}
	return bless $data, ref($class) || $class;
}

sub user_id { return [map { $_->{'user_id'} } map { @$_ } shift] }
sub machine_id { return [map { $_->{'machine_id'} } map { @$_ } shift] }

1;
