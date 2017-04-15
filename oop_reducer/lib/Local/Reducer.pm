package Local::Reducer;

use strict;
use warnings;
use feature "say";
use Data::Dumper;
use DDP;
use Local::Row::JSON;
=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my $class = shift;
	my @data_array = @_;
	my %datas;
	my $key;
	for my $i (0..scalar @data_array){
  		if ( $i % 2 ){
    			$datas{$key} = $data_array[$i];
  		} else {
    			$key = $data_array[$i];
  		}
	}
	my $string;
	my @string_arrays;
	$string = $datas{source}-> next;
	my $i = 0;
	while($i < scalar @{$datas{source}}){
		my @class_string;
		push @class_string,"str";
		push @class_string,$string;
		bless \@class_string,$datas{row_class};
		push @string_arrays,($datas{row_class}->new(@class_string));
		$string = $datas{source}-> next;
		$i = $i + 1;
	}
	$datas{source} = \@string_arrays;
	bless \%datas,$class;
	return \%datas;
	
}

1;
