package DeepClone;

use 5.010;
use strict;
use warnings;

=encoding UTF8

=head1 SYNOPSIS

Клонирование сложных структур данных

=head1 clone($orig)

Функция принимает на вход ссылку на какую либо структуру данных и отдаюет, в качестве результата, ее точную независимую копию.
Это значит, что ни один элемент результирующей структуры, не может ссылаться на элементы исходной, но при этом она должна в точности повторять ее схему.

Входные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив и хеш, могут быть любые из указанных выше конструкций.
Любые отличные от указанных типы данных -- недопустимы. В этом случае результатом клонирования должен быть undef.

Выходные данные:
* undef
* строка
* число
* ссылка на массив
* ссылка на хеш
Элементами ссылок на массив или хеш, не могут быть ссылки на массивы и хеши исходной структуры данных.

=cut


sub clone {
	#say "start";
	my $orig = shift;
	my @refs = shift;
	my $main = shift;
	my $do = 1;
	my $cloned;
	if (not ref $orig) {
     		$cloned = $orig;
		#say ref $orig;
	}
	elsif(ref $orig eq "ARRAY"){
		if($refs[0]){
			push @refs,$orig;
			#say join ",",@refs;
		}
		else{
			$refs[0] = $orig;
			#say @refs;
		}
		for my $i (0..$#$orig)	{
			for(@refs){
				if(defined $$orig[$i] and defined $_){
					#print $$orig[$i];
					if($$orig[$i] eq $_){
						$do = 0;
					}	
				}
			}
			if($do){
				$$cloned[$i] = clone($$orig[$i],@refs,1);
				if (defined clone($$orig[$i],@refs,1)){
					if ((ref clone($$orig[$i],@refs,1) ne "ARRAY") and (ref clone($$orig[$i],@refs,1) ne "HASH") and (ref clone($$orig[$i],@refs,1))){
						#say "ttt $cloned";
						$cloned = clone($$orig[$i],@refs,1);
						#say $cloned;
						last;
					}
				}
			}
			else{
				$$cloned[$i] = $$orig[$i];
			}
		}
		#say $cloned;	
		#map {push @$cloned,clone($_)} @$orig;
	}
	elsif (ref $orig eq "HASH") {
		if($refs[0]){
			push @refs,$orig;
			#say join ",",@refs;
		}
		else{
			$refs[0] = $orig;
			#say @refs;
		}
		
		for my $i (keys %$orig){
			for(@refs){
				if(defined $$orig{$i} and defined $_){
					#print $$orig[$i];
					if($$orig{$i} eq $_){
						$do = 0;
					}	
				}
			}
			if($do){
				$$cloned{$i} = clone($$orig{$i},@refs,1);
				if (defined $$orig{$i}){
				#say $$orig{$i};
				#say $$orig{$i};
					if ((ref clone($$orig{$i},@refs,1) ne "ARRAY") and (ref clone($$orig{$i},@refs,1) ne "HASH") and (ref clone($$orig{$i},@refs,1))){
						#delete $cloned;
						$cloned = clone($$orig{$i},@refs,1);
						#say $cloned;
						last;
					}
				}	
			}
			else{
				$$cloned{$i} = $$orig{$i};
			}
		}
		#say $cloned;
		#say %$cloned;
		#say values %$cloned; 
		#map {$$cloned{$_} = clone($orig->{$_})} keys %$orig;
		
	}
	else{
			
		$cloned = $orig;
	}
	if(defined $cloned and !$main){
#			if (ref $cloned eq "CODE"){
			if((ref $cloned ne "ARRAY") and (ref $cloned ne "HASH") and (ref $cloned)){	
				$cloned = undef;
			}
		}
	else{
		if(!$main){	
			$cloned = undef;
		}
	}
#	say $cloned;
		
	# ...
	# deep clone algorith here
	# ...
	return $cloned;
}

1;
