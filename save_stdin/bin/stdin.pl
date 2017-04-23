#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use feature "say";
use DDP;



my $strings = 0;
my $size = 0;
my $file;
GetOptions("file=s" => \$file);


open(my $fh1, '>', $file);
print STDOUT "Get ready\n";

$SIG{INT} = \&prog;
$SIG{STOP} = \&prog3;

                                                                                                                                     
sub prog {
	$SIG{INT} = \&prog2;
  	my $signame = shift;
	print STDERR "Double Ctrl+C for exit";
}
sub prog2{
	close $fh1;
	my $ave = $size/$strings;	
	print STDOUT "$size $strings $ave";
	exit;
}

sub prog3{
	close $fh1;
	my $ave = $size/$strings;	
	print STDOUT "$size $strings $ave";
	exit;
}


while(<>) {
	syswrite($fh1,$_,length $_);
	$SIG{INT} = \&prog;
	$strings = $strings + 1;
	chomp $_;
	$size = $size + length $_;
}
my $ave = $size/$strings;
close $fh1;
print STDOUT "$size $strings $ave";


