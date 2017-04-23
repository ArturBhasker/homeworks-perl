package VFS;
use utf8;
use strict;
use warnings;
#use 5.010;
use feature "say";
use File::Basename;
use File::Spec::Functions qw{catdir};
use JSON::XS;
use DDP;
use Data::Dumper;
no warnings 'experimental::smartmatch';
no warnings 'experimental';
use Encode qw(encode decode);
use Digest::SHA qw(sha1 sha1_hex);




sub mode2s {
	my $access = shift;
	my ($oe,$or,$ow,$uw,$ue,$ur,$gw,$ge,$gr);
	$oe = $access%2;
	$oe = $oe == 1 ?"true":"false";
	$access = int($access/2);
	$ow = $access%2;
	$ow = $ow == 1 ?"true":"false";
	$access = int($access/2);
	$or = $access%2;
	$or = $or == 1 ?"true":"false";
	$access = int($access/2);
	$ge = $access%2;
	$ge = $ge == 1 ?"true":"false";
	$access = int($access/2);
	$gw = $access%2;
	$gw = $gw == 1 ?"true":"false";
	$access = int($access/2);
	$gr = $access%2;
	$gr = $gr == 1 ?"true":"false";
	$access = int($access/2);
	$ue = $access%2;
	$ue = $ue == 1 ?"true":"false";
	$access = int($access/2);
	$uw = $access%2;
	$uw = $uw == 1 ?"true":"false";
	$access = int($access/2);
	$ur = $access;		
	$ur = $ur == 1 ?"true":"false";
	my $result = qq("mode":{"user":{"write":$uw,"read":$ur,"execute":$ue},"other":{"execute":$oe,"read":$or,"write":$ow},"group":{"write":$gw,"read":$gr,"execute":$ge}});
	return $result;
}

sub parse {
	my $text = shift;
	my $symb;
	my $number;
	my $size;
	my $text_part;
	my $access;
	my $sha1;
	my $result_text = " ";
	my $hash;
	unless(substr($text,0,1) eq "D" or substr($text,0,1) eq "Z"){
		die "The blob should start from 'D' or 'Z'";
	}
	if(not substr($text,length($text) - 1,1) eq "Z"){		
		die "Garbage ae the end of the buffer";
	}
	while(1){
		$symb = substr($text,0,1,"");
		if ($symb eq "Z"){
			last;
		}
		elsif($symb eq "D"){
			$number = unpack("n",substr($text,0,2,""));
			$text_part = decode("utf-8",substr($text,0,$number,""));
			$access =  unpack("n",substr($text,0,2,""));
			if (substr($result_text,length($result_text) - 1,1) eq "}"){
				$result_text = $result_text.q(,);
			}
			$result_text = $result_text.q({"type":"directory","name":").$text_part.q(",);
			$text_part = mode2s($access);
			$result_text = $result_text.$text_part;
		}	
		elsif($symb eq "F"){
			$number = unpack("n",substr($text,0,2,""));
			$text_part = decode("utf-8",substr($text,0,$number,""));
			$access = unpack("n",substr($text,0,2,""));
			$size = unpack("N",substr($text,0,4,""));
			$sha1 = unpack("H*",substr($text,0,20,""));
			if (substr($result_text,length($result_text) - 1,1) eq "}"){
				$result_text = $result_text.q(,);
			}
			$result_text = $result_text.q({"type":"file","name":").$text_part.q(",);
			$text_part = mode2s($access);
			$result_text = $result_text.$text_part.q(,"hash":").$sha1.q(","size" : ").$size.q(");
			$result_text = $result_text.q(});
		}
		elsif($symb eq "I"){
			$result_text = $result_text.q(,"list":[);
		}
		elsif($symb eq "U"){
			$result_text = $result_text.q(]});
		}
	}
	if(not $result_text eq " "){
		$result_text = encode("utf-8",$result_text);
		$hash = JSON::XS->new->utf8->decode($result_text);
	}else{
		$hash = {};
	}
	return $hash;
}


1;
