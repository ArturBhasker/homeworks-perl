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
	my $orig = shift;
	my $main = shift;
	my $cloned;
	if (not ref $orig) {
     		$cloned = $orig;
	}
	elsif(ref $orig eq "ARRAY"){
		for (0..$#$orig)	{
			if (ref $$orig[$_] eq "ARRAY"){
				if ($$orig[$_] eq $orig){
					$$cloned[$_] = $cloned;
				}
				else{
					push @$cloned,clone($$orig[$_],1);
				}
			}
			else{	
				my $t = clone($$orig[$_],1);
				if(defined $t){
					if(clone($$orig[$_],1) eq "9_DES"){
						$cloned = "9_DES";
					}
					else{
						push @$cloned,clone($$orig[$_],1);	
					}
				}
				else{
					push @$cloned,clone($$orig[$_],1);	
				}
			}
		}
		#map {push @$cloned,clone($_)} @$orig;
	}
	elsif (ref $orig eq "HASH") {
		#say "HASH!";
		for (keys %$orig){
			if (ref $$orig{$_} eq "HASH"){
				if ($$orig{$_} eq $orig){
					$$cloned{$_} = $cloned;
				}
				else{
					$$cloned{$_} = clone($orig->{$_},1);
				}
			}
			else{	
				my $t = clone($$orig{$_},1);
				#say defined $t;
				if(defined $t){
					if($t eq "9_DES" and ref $cloned eq "HASH"){
						$cloned = "9_DES";
					}
					else{
						$$cloned{$_} = clone($orig->{$_},1);
					}		
				}
				else{
					$$cloned{$_} = clone($orig->{$_},1);
				}
			}
			
		} 
		#map {$$cloned{$_} = clone($orig->{$_})} keys %$orig;
		
	}
	else{
		$cloned = "9_DES";
	}
	if(defined $cloned){
		if($cloned eq "9_DES" and !$main)
		{	
			$cloned = undef;
		}
	}
	else{
		if(!$main)
		{	
			$cloned = undef;
		}
	}	
	# ...
	# deep clone algorith here
	# ...
	return $cloned;
}

1;
