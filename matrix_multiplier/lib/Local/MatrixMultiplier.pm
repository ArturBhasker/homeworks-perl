package Local::MatrixMultiplier;

use strict;
use warnings;
use DDP;
use feature "say";
use POSIX qw(:sys_wait_h);

sub mult {
	my ($start,$end,$k,$j);
	my $res_point = 0;
	my ($mat_a, $mat_b, $max_child) = @_;
	my $res = [];
	my $length_a = scalar @$mat_a;
	my $length_b = scalar @$mat_b;
	die 'Wrong matrix' if scalar $length_b != $length_a;
	for(@$mat_a){
		die 'Wrong matrix' if scalar @$_ != $length_a;
	}
	for(@$mat_b){
		die 'Wrong matrix' if scalar @$_ != $length_b;
	}
	my $size = $length_a*$length_a;
	my $part = int($size/$max_child+1);
	for my $i(0..$max_child-1){
		my ($r, $w);
		pipe($r, $w);
		my $pid = fork();
		if($pid){
			close($w);
			while(<$r>){
				$_ =~ /(\d*),(\d*),(\d*)/;
				$res->[$3][$2] = $1;
			}
			close $r;
		}
		else {
			die "Cannot fork $!" unless defined $pid;
			close($r);
			if ($i == $max_child-1) {
				$start = $part*$i;
				$end = $length_a*$length_a - 1;
			}else {
				$start = $i*$part;
				$end = ($i + 1)*$part - 1;
			}
			for($start..$end){
				$j = int(($_) / $length_a);
				$k = ($_) % $length_a;
				for(0..$length_a - 1){
					$res_point = $res_point + $mat_a -> [$k] -> [$_] * $mat_b -> [$_] -> [$j];
				}
				say $w "$res_point,$j,$k";
				$res_point = 0;	
			}
			close $w;
			exit;
		}
	}
	return $res;
}

1;
