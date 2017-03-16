#!/usr/bin/perl

use strict;
use warnings;
use feature "say";

#say @ARGV;
my $filepath = $ARGV[0];
die "USAGE:\n$0 <log-file.bz2>\n"  unless $filepath;
die "File '$filepath' not found\n" unless -f $filepath;

my $parsed_data = parse_file($filepath);
report($parsed_data);
exit;

#say "hrl";

sub parse_file {
    my $file = shift;

    # you can put your code here
    my %requests;
    my $total = 0;
    my $result;
    open my $fd, "-|", "bunzip2 < $file" or die "Can't open '$file': $!";
    while (my $log_line = <$fd>) {
	#print $log_line;
	$log_line =~ /^(.*)\s*\[(.*)\].*"(.*)"\s(\d*)\s(\d*)\s"(.*)".*"(.*)".*"(.*)"$/;
	#print $log_line;
	my $us_num = $1; #adress of user number
	my $time = $2;	#date and time
	#say $3;	#info about request
	my $status = $4; #status of request
	my $pressed_bytes = $5;	#count of sent pressed information(Kbytes)	
	#say $6; #adress of link
	#say $7;	#info about user
	my $coef = $8; #coef of pressing

#########################
#########################
	
	if($requests{$us_num} -> {"count"}){
		$requests{$us_num} -> {"count"}++;
	}
	else{
		$requests{$us_num} -> {"count"} = 1;
	}
	#say $requests{$us_num} -> {"count"};
	$time =~  /^(\d*\/\w*\/\d*:\d*:\d*):\d*/;
	#say $1;
	if($requests{$us_num} -> {"time"} -> {$1}){
		$requests{$us_num} -> {"time"} -> {$1}++;
	}
	else
	{
		$requests{$us_num} -> {"time"} -> {$1} = 1;
	}
	
	if($status == 200 and $requests{$us_num} -> {"data200"}){
		if($coef eq "-"){
			$coef = 1;
		}
		$requests{$us_num} -> {"data200"} = $requests{$us_num} -> {"data200"} + $coef*$pressed_bytes;
	}
	elsif($status == 200){
		if($coef eq "-"){
			$coef = 1;
		}
		$requests{$us_num} -> {"data200"} = $coef*$pressed_bytes;
	}
	
	if($requests{$us_num} -> {"data_st"} -> {$status}){
		$requests{$us_num} -> {"data_st"} -> {$status} = $requests{$us_num} -> {"data_st"} -> {$status} + $pressed_bytes;
	}
	else{
		$requests{$us_num} -> {"data_st"} -> {$status} = $pressed_bytes;
	}
	
    }
    close $fd;
    my %avg;
    for my $i (keys %requests){
		for($requests{$i} -> {"time"}){
			#my $rpm;
			my $t = keys %$_;
			my $reqs = 0;
			map { $reqs += $_ } values %$_;
			$avg{$i} = $reqs/$t;
		}
    }
    my @top10;
    my %top_count;
    for(keys %requests){
		$top_count{$_} = $requests{$_} -> {"count"};
    }
    @top10 = (sort{$top_count{$b}<=>$top_count{$a}} keys %top_count)[0..9];
	print("IP	count	avg	data	data_200	data_301	data_302	data_400	data_403	data_404	data_408	data_414	data_499	data_500\n");
    my @statuses = ("200", "301", "302", "400", "403", "404", "408", "414", "499", "500");
    ##print total##
    ###############
    	print "total\t";
	my $tc = 0;
	map {$tc += $top_count{$_}} keys %requests;
	print "$tc\t";
	my %time;
	my $avg_t = 0;
	for my $i (keys %requests){
		my $times = $requests{$i} -> {"time"};
		for(keys %$times){
			$time{$_} = 0;
			#say $_;			
			#map { $reqs += $_ } values %$_;
		}
    	}
	#say scalar keys %time;
	$avg_t = $tc/(keys %time);
	print sprintf("%7.2f\t",$avg_t);
	my $data_t = 0;	
	map {
		if($requests{$_} -> {"data200"}){ $data_t += $requests{$_} -> {"data200"}/1024;}} keys %requests;
	if ($data_t){
		$data_t = int($data_t);
	}
	else{
		$data_t = 0;
	}
	print "$data_t\t";
	for my $i (@statuses){
		my $st_t = 0;
		map{
			if($requests{$_} -> {"data_st"} -> {$i}){$st_t += $requests{$_} -> {"data_st"} -> {$i};}} keys %requests;
		$st_t = int($st_t/1024);
		if($st_t){
			print $st_t;
		}
		else{
			print 0;
		}
		print "\t";
	}
    	print "\n";
    ##end print total##
    ###################
    for(@top10){
	print "$_\t";
	if("$top_count{$_}"){
		my $tc = $top_count{$_};
		print "$tc\t";
		}
	else{
		print "0";
	}
	print sprintf("%.2f\t",$avg{$_});
	my $data = int(($requests{$_} -> {"data200"})/1024);
	if($data){
		print $data;
	}
	else{
		print "0";
	}
	print "\t";
	for my $i (@statuses){
		#my $st = int(($requests{$_} -> {"data_st"} -> {$i})/1024);
		if($requests{$_} -> {"data_st"} -> {$i}){
			my $st = int(($requests{$_} -> {"data_st"} -> {$i})/1024);
			print $st;
		}
		else{
			print 0;
		}
		print "\t";
	}
	print "\n";
    }
    return $result;
}

sub report {
    my $result = shift;
    # you can put your code here
}
