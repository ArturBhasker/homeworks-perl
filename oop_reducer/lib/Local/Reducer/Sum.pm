package Local::Reducer::Sum;
use strict;
use warnings;
use feature "say";
use Data::Dumper;
use DDP;
use Local::Row::JSON;

{
	no strict "subs";
	use base Local::Reducer;
}

sub reduce_n{
	my $object = shift;
	my $result;
	my $count = shift;
	my $init = $object -> {initial_value};
	if ($object -> {initial_value} > 0){
		$result = $object -> {source} -> [$init-1] -> {sum};
	}
	else{
		$result = 0;
	}
	for my $n ($init..($init + $count-1)){	
		if(not defined $object -> {source} -> [$n] -> {error} and defined $object -> {source} -> [$n] -> {$object -> {field}}){		
			if($object -> {source} -> [$n] -> {$object -> {field}}=~ /^[+-]?\d+$/){
				$result = $result + ($object -> {source} -> [$n] -> {$object -> {field}});
			}
		}
		$object -> {source} -> [$n] -> {sum} = $result;
		$object -> {initial_value} = $n + 1;
	}
	return $result;
}

sub reduced{
	my $object = shift;
	return $object -> {source} -> [$object -> {initial_value}-1] -> {sum};
}

sub reduce_all{
	my $object = shift;
	my $num_of_elements = scalar @{$object -> {source}};
	my $init = $object -> {initial_value};
	return $object->reduce_n($num_of_elements - $init);
}
	




#Вот ещё один happy end, история о любви
#С сюжетом знакомым в РУДНе давно:
#Армянка с индусом - победило добро!
#И неважно откуда ты,
#В какой ты стране живёшь:
#Если ты веришь сильно и ждёшь,
#Обязательно счастье своё обретёшь!

1;
