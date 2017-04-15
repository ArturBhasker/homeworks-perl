package Local::Reducer::MaxDiff;
use strict;
use warnings;
use feature "say";
use Data::Dumper;
use DDP;
{
	no strict "subs";
	use base Local::Reducer;
}

sub reduce_n{
	my $object = shift;
	my $top;
	my $bottom;
	my $count = shift;	
	my $init = $object -> {initial_value};	
	for my $n ($init..($init + $count-1)){	
		if(not defined $object -> {source} -> [$n] -> {error} and defined $object -> {source} -> [$n] -> {$object -> {top}} and defined $object -> {source} -> [$n] -> {$object -> {bottom}}){	# <- this string defining errors and top and bottom values	
			if($object -> {source} -> [$n] -> {$object -> {top}}=~ /^[+-]?\d+$/ and $object -> {source} -> [$n] -> {$object -> {bottom}}=~ /^[+-]?\d+$/){ # <- this string check top and bottom for numeric value
				$top = $object -> {source} -> [$n] -> {$object -> {top}};
				$bottom = $object -> {source} -> [$n] -> {$object -> {bottom}}
			}
		}
		else{
			$top = 0;
			$bottom = 0;
		}
		if($n > 0){
			if(($top - $bottom) > $object -> {source} -> [$n - 1] -> {diff}){
				$object -> {source} -> [$n] -> {diff} = $top - $bottom;
			}
			else{
				$object -> {source} -> [$n] -> {diff} = $object -> {source} -> [$n - 1] -> {diff};
			}
		}
		else{
			$object -> {source} -> [$n] -> {diff} = $top - $bottom;
		}
		$object -> {initial_value} = $n + 1;
	}
	return $object -> {source} -> [$object -> {initial_value} - 1] -> {diff};
}

sub reduced{
	my $object = shift;
	return $object -> {source} -> [$object -> {initial_value}-1] -> {diff};
}

sub reduce_all{
	my $object = shift;
	my $num_of_elements = scalar @{$object -> {source}};
	my $init = $object -> {initial_value};
	return $object->reduce_n($num_of_elements - $init);
}
	


1;
