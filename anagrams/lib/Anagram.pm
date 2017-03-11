package Anagram;

use 5.010;
use strict;
use warnings;
use utf8;
#use open qw(:std :utf8);
use Encode qw(encode decode);

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функцию поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
    'пятак'  => ['пятак', 'пятка', 'тяпка'],
    'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub anagram {
	my $words_list = shift;
	my %result;
	my %words;
	my %symbols;
	my %anagrams;
	my @dictionary;
	@words{@$words_list}=@$words_list;
	for(keys %words){
		my $word = decode("utf8",$words{$_});
		$word = lc $word;
		my @symbs;
		for my $i (0..(length $word)-1){
			push @symbs,substr($word,$i,1);
		}
		$symbols{$_} = \@symbs;
		push @dictionary,$word;
		@symbs = sort @symbs;
		$word = encode("utf8",$word);
		$anagrams{$word} = \@symbs;
		
	}
	@dictionary = sort @dictionary;
	for (@dictionary){
		$_ = encode("utf8",$_);
	}
	
	for (0..length @dictionary-1){
		if ($dictionary[$_+1] eq $dictionary[$_]){
			splice(@dictionary,$_,1);
			$_--;
		}
	}
	for my $ch_word (@dictionary){
		checking: for my $main_word (@dictionary){
			join @{$anagrams{$ch_word}};
			if (@{$anagrams{$main_word}} == @{$anagrams{$ch_word}}){
				push @{$result{$main_word}},$ch_word;
				last checking;
			}
		}
				
	}
	for(keys %result){  
		if (not defined @{$result{$_}}[1]){
				say $result{$_};
				delete $result{$_};
		}
	}
		    
	


	#
    # Поиск анограмм
    #

    	return \%result;
}

1;
