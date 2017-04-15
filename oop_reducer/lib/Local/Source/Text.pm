package Local::Source::Text;
use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use warnings;
use feature "say";
use DDP;


sub new{
	my $class = shift;
	my $type = shift;
	my @array;
	my $text = $_[0];
	my $delimiter = $_[2];
	unless ($delimiter){$delimiter = "\n";}
	while($text =~ /^((.*?)$delimiter)/){
		push @array,$2;
		$text =~ s/^$1//;
	}
	$text =~ /^(.*)/;
	push @array,$1;
	our $str = 0;
	bless \@array,$class;
	return \@array;
}

sub next{
	our $str;
	my @array = @_;
	my $elem = $array[0] -> [$str];
	$str = $str + 1;
	return $elem;
}

1;
