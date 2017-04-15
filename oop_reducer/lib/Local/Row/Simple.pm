package Local::Row::Simple;
use strict;
use warnings;
use feature "say";
use Data::Dumper;
use DDP;

sub new{
	my $class = shift;
	my $type = shift;
	my $data = shift;
	my %hash_result;
	my $key;
	my $value;
	while($data =~ /^([^:,]+):([^:,]+),?/){
		$hash_result{$1} = $2;
		$data =~ s/^[^:,]*:[^:,]*,?//;
	} 	
			
	if($data){				
		return undef;
	}
	else{
		return \%hash_result;
	}
}

1;
