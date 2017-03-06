use strict;
use warnings;
use feature "say";


my @list = qw(письма и телеграммы сгорели очень быстро и дотла
                были их килограммы теперь осталась только лишь зола);
 
my @result = grep /и/i, @list;
my $result_num = grep /и/i, @list;
foreach (@result) {print $_." "};
 
print "\n".$result_num."\n";
