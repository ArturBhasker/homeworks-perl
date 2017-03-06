package SecretSanta;

use 5.010;
use strict;
use warnings;
use DDP;
use List::Util qw/shuffle/;
#use feature 'say'

sub calculate {
	my @members = @_;
	my @res;
	my @member;
	my @DoubleMember;
	for my $i (@members){
		if (ref(\$i) eq "SCALAR"){
			push(@member,$i);
		}
		else {
			push(@DoubleMember,$i);
		}
	}
	for (@DoubleMember){
		push(@member,@$_);
		}
	my %pairs;
	for(@DoubleMember)	{
		$pairs{@$_[1]}=@$_[0];
		$pairs{@$_[0]}=@$_[1];
		}
	my %Santa_s;
	FINDING: while (1)	{
		my @presents = shuffle @member;	
		@Santa_s{@member} = @presents;
		my $k = 0;
		my $comp;
		for (@member){
			my $win = $Santa_s{$_};
			if ($win eq $_){
				redo FINDING;
			}
			else	{
				if ($pairs{$_}){
					$comp = $pairs{$_};
					if($pairs{$_} eq $win)	{
						redo FINDING;
					}
				}
			}		
		}	
	last;
	}	
	# ...
	#	push @res,[ "fromname", "toname" ];
	# ...
	for my $key ( keys %Santa_s )	{
		my $value = $Santa_s{$key};
		push @res,[$key,$value];
	}
	return @res;
}

1;
