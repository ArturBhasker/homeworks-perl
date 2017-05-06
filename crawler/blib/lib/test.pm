#!/usr/bin/perl -w
use strict;
use warnings;
use Data::Dumper;
use AnyEvent::HTTP;
use DDP;

my ($domain,$START_TIME,$MAX_QUERIES,$MAX_QUEUE,$time,$done,$heads);
my (@condvars);

$START_TIME  = time;
$MAX_QUERIES = 1;
$MAX_QUEUE   = 10;
$heads       = 0;

while (1)
{
  # send dns packets
  for my $i (1..$MAX_QUERIES)
  {
    $domain = <>;
	print $domain;
    # clean off newline
    chomp $domain;
    my $http_url = "http://www.".$domain;
    my $condvar = AnyEvent->condvar;
    push @condvars, $condvar;
    http_request HEAD => $http_url, sub 
                                 {
                                   #warn Dumper @_;
                                      $condvar->send;
                                 };
  }
  
  while (my $condvar = pop @condvars)
  {
    $condvar->recv;
	  	p $condvar;
  }
  $done += $MAX_QUERIES;
  $time = time - $START_TIME;
  print "Tried $done domains, $heads headers found in $time seconds.\n
+";
}
