package Local::Source::Array;
use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;
use feature "say";
use DDP;


sub new{
	my $class = shift;
	my $type = shift;
	my $array = $_[0];
	bless $array,$class;
	our $str = 0;
	return $array;
}

sub next{
	our $str;
	my @array = @_;
	my $elem = $array[0] -> [$str];
	$str = $str + 1;
	return $elem;
}

1;
