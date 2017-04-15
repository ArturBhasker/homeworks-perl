package Local::Row::JSON;
use strict;
use warnings;
use feature "say";
use Data::Dumper;
use DDP;
use JSON;

sub new{
	my $class = shift;
	my $type = shift;
	my @data = @_;
	my $ret = 0;
	my %hash;
	for (@data){
		eval('if(ref decode_json($_) eq "HASH"){%hash = %{decode_json($_)};}');
		if($@ or ref decode_json($_) ne "HASH"){
			$ret = 1;
			$@ = undef;
		}
	}
	if ($ret){
		return undef;
	}
	else{
		bless \%hash,$class;
		return \%hash;
	}
}

sub get{
	my $object = shift;
	my $name = shift;
	my $default = shift;
	if ($object -> {$name}){
		return $object -> {$name};
	}
	else{
		return $default;
	}
}


1;
