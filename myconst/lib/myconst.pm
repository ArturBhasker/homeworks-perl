package myconst;
use warnings;
use Scalar::Util 'looks_like_number';
use DDP;
use 5.020;
=encoding utf8
=head1 NAME

myconst - pragma to create exportable and groupped constants

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';
my @vars;
sub import{
	my ($package, $filename, $line)= caller;
	my $this_name = shift;
	my @vars_input = @_;
	for my $i (0..((scalar @vars_input)/2-1)){
		if (ref $vars_input[2*$i+1] eq 'HASH'){
			for (keys %{$vars_input[2*$i+1]}){
    				push @vars, {value => $vars_input[2*$i+1]->{$_},
    				name => $_,
    				group => $vars_input[2*$i]};
			}
		}elsif (ref $vars_input[2*$i+1] eq ''){
			push @vars, {value => $vars_input[2*$i+1],
			name => $vars_input[2*$i],
			group => 'all'};
		}else {
			die;
		}
	}
	my $eval_str='';
	my @export_vars;
	for my $iter (@vars){
		if (ref $iter->{name} eq "ARRAY"){
    			die;
		}
		no warnings;
		eval 'sub '.$package.'::'.$iter->{name}.'(){ return $iter->{value};}';
	}
	eval 'sub '.$package.'::import{
		no warnings;
		my $this_name = shift;
		my $package = caller;
		if (not @_){
			eval \''.$eval_str.'\';
		}else{
			for my $get_str (@_){
	    			if($get_str =~ /^:all/){
 					for my $var (@vars){
						eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
    					}
    				}elsif($get_str =~ /^:/ and not $get_str =~ /^:all/){
					my @group_var = grep {":"."$_->{group}" eq $get_str}@vars;
    					for my $var (@group_var){
						eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
					}
				}else{
	    				for my $var (@vars){
	    					if ($var->{name} eq $get_str){
    							eval \'sub \'.$package.\'::\'.$var->{name}.\'(){return $var->{value};} \';
    						}
    					}
				}
			}
		}
	}';
}

1;
