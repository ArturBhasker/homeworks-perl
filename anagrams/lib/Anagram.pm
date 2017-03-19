package Anagram;

use 5.010;
use strict;
use warnings;
use utf8;
#use open qw(:std :utf8);
use Encode qw(encode decode);
#binmode STDOUT, ":encoding(UTF-8)";

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
		my @symbs = split '', $word;
		$symbols{$_} = \@symbs;
		push @dictionary,$word;
		@symbs = sort @symbs;
		$word = encode("utf8",$word);
		$anagrams{$word} = \@symbs;
		
	}
	@dictionary = sort @dictionary;
	@dictionary = map { encode("utf8",$_) } @dictionary;
	
	
	my %uniq;
	@dictionary = grep { !$uniq{$_}++ } @dictionary;
	
	for my $ch_word (@dictionary){
		checking: for my $main_word (@dictionary){
			my $main = $anagrams{$main_word};
			my $check = $anagrams{$ch_word};
			if (encode("utf8",join "",@$main) eq encode("utf8",join "",@$check)){
				push @{$result{$main_word}},$ch_word;
				last checking;
			}
		}
				
	}
	for(keys %result){  
		if (not defined @{$result{$_}}[1]){
				delete $result{$_};
		}
	}
		    
	


	#
    # Поиск анограмм
    #

    	return \%result;
}

1;
