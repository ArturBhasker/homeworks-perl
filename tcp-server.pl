#!/usr/bin/perl -w

use strict;
use warnings;
use IO::Socket::INET;
use AnyEvent::HTTP;
use feature "say";
use DDP;

# auto-flush on socket
$| = 1;



# create a connecting socket
my $socket = new IO::Socket::INET (
    LocalHost => '0.0.0.0',
    LocalPort => '7775',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";
while(1){
	my $client_socket = $socket->accept();
	# waiting for a new client connection

	# get information about a newly connected client
	my $client_address = $client_socket->peerhost();
	my $client_port = $client_socket->peerport();
	print "connection from $client_address:$client_port\n";
	
	my $url;
	my ($body,$hdr);
	while(1)
	{	
 	
		# read up to 1024 characters from the connected client
		my $data;# = "";
		$client_socket->send("try:");
		$client_socket->recv($data, 1024);
		my $cv = AnyEvent->condvar;
		chomp $data;
		my $command;
		if($data =~ /^(\S+)\s(.*)$/){
			$command = $1;
			if($command eq "URL"){
				$url = $2;
			}
		}else{
			$command = $data;
		}
		#say $command;
		#p $command;
		if($command eq "URL"){
			$client_socket->send("ok!\n");
		}elsif($command eq "HEAD"){
			http_request HEAD => $url, timeout => 1, sub{
				my $hdr=$_[1];
				for (keys %$hdr){
					$client_socket->send($_."\t".$hdr->{$_}."\n");
				}
				$cv->send;
			};
			$cv->recv;
		}elsif($command eq "GET"){
			http_request GET => $url, timeout => 1, sub{
				my $body = $_[0];
				$client_socket->send($body);
				$cv->send;
			};
			$cv->recv;
		}elsif($command eq "FIN"){
			$client_socket->send("Bye!\n");
			shutdown($client_socket, 1);
			print "disconnect from  $client_address:$client_port\n";
			last;
		}
		
		
	}
}
 
$socket->close();
