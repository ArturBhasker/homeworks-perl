package Crawler;

use 5.010;
use strict;
use warnings;
use feature "say";
use DDP;

use AnyEvent::HTTP;
use FindBin;
use lib "$FindBin::Bin/../blib/lib";
use lib "$FindBin::Bin/../lib";
use Web::Query;
use URI;
use HTML::Parser;

=encoding UTF8

=head1 NAME

Crawler

=head1 SYNOPSIS

Web Crawler

=head1 run($start_page, $parallel_factor)

Сбор с сайта всех ссылок на уникальные страницы

Входные данные:

$start_page - Ссылка с которой надо начать обход сайта

$parallel_factor - Значение фактора паралельности

Выходные данные:

$total_size - суммарный размер собранных ссылок в байтах

@top10_list - top-10 страниц отсортированный по размеру.

=cut


package MyParser;
	use base qw(HTML::Parser);
	use DDP;
	my @HT;
	sub start { 
		my ($self, $tagname, $attr, $attrseq, $origtext) = @_;
		if ($tagname eq 'a') {
			if(defined $attr->{href}){
				if (substr($attr->{href},0,1) eq "/" or substr($attr->{href},0,4) eq "http"){
					push @HT,$attr->{href};
				}
			}
		}
	}
	sub ret{
		return \@HT;
	}
	sub clear{
		 $#HT = -1;
	}





package Crawler;



sub run{
	my $ref_restrict = 1000;
	my ($start_page, $parallel_factor) = @_;
	#$parallel_factor = 100;
	$start_page or die "You must setup url parameter";
	$parallel_factor or die "You must setup parallel factor > 0";
	my $total_size = 0;
	my @top10_list;
	if(substr($start_page,length($start_page)-1,1) eq "/"){
		chop $start_page;
	}



	my $actual_ref;
	my @refs; 
	my @refs_sorted;
	push @refs, $start_page;
	my $cv = AnyEvent->condvar;
	my $done;
	my %url_info; #here are info of size of url
	my $i = 0; 
	my $next;
	$cv->begin;
	$next = sub {
		my @refs_sorted;
		my $num_of_urls = 0;
		if(not defined $refs[$i]){
			$cv->end;
			return;
		}
		p $cv;
		my $actual_ref = $refs[$i];
		p $actual_ref;
		say scalar keys %url_info; #this says and p just for indication
		say $i;
		say scalar @refs;
		my $uri = URI->new($actual_ref);		
		my ($body,$hdr) = @_;
		if(defined $hdr -> {"content-type"}) {
			$hdr -> {"content-type"} =~ /^(.*);/; #here are we get the type of URL
			$done = $1;
		}
		$url_info{$actual_ref} = $hdr->{"content-length"}; #get info of size
		unless(defined $done){
			$done = 0;
		}
		if ($done eq "text/html" and scalar keys %url_info < $ref_restrict){		
			my $parser = MyParser->new;
			$parser->parse($body);
			for(@{$parser->ret()}) {
				my $exist_ref_check = 1;
				if(substr($_,0,4) ne "http"){
					$_ =$uri->scheme."://".$uri->host.$_; #convert url for normal type
				}
				for my $exist (@refs) {
					if($_ eq $exist or substr($_,0,length $start_page) ne $start_page){
						$exist_ref_check = 0; #checkeing url for repeating
						last;
					}
				}
				if ($exist_ref_check and scalar keys %url_info < $ref_restrict){
					push @refs,$_;
					$url_info{$_} = undef;
				}
			}
		}elsif(scalar keys %url_info == $ref_restrict){	#this situation provided when we have 1000+ URLs
			my $j = 1;
			for(keys %url_info){
				$refs[$i + $j] = $_;
				$j++;
			}
			$#refs = $i + $j;
			$url_info{"garbage_key"} = 0;
		}
		if($i < $parallel_factor){ 
			while($i < $parallel_factor and defined $refs[$i+1]){
				$actual_ref = $refs[++$i];
				if(substr($actual_ref,0,4) ne "http"){
					$actual_ref = $uri->scheme."://".$uri->host.$actual_ref;
				}
				$cv->begin;
				http_request GET => $actual_ref, timeout => 1, $next;
			}
		}else{	
			$actual_ref = $refs[++$i];
			if(defined $actual_ref){
				if(substr($actual_ref,0,4) ne "http"){
					$actual_ref = $uri->scheme."://".$uri->host.$actual_ref;
				}
				$cv->begin;
				http_request GET => $actual_ref, timeout => 1, $next;
			}
		}
		$cv->end;				
	};
	http_request GET => $start_page, timeout => 1, $next;	
	$cv->recv;

	
	p %url_info;
	my @top = sort {$url_info{$b} <=> $url_info{$a}} keys %url_info;
	for(values %url_info){
		$total_size = $total_size + $_;
	}
	@top10_list = @top[0..9];		
	p @top;
	p @top10_list;
	p $total_size;
	return $total_size, @top10_list;
}




1;


#Solar Orbiter; Solar Probe Plus
