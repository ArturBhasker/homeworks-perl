#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 15;
use FindBin; use lib "$FindBin::Bin/../lib";

eval "use myconst []";
ok($@, "invalid args checked");

eval "use myconst {}";
ok($@, "invalid args checked");

eval "use myconst a => []";
ok($@, "invalid args checked");

eval "use myconst a => { b => {} }";
ok($@, "invalid args checked");

eval "use myconst a => { b => [] }";
ok($@, "invalid args checked");

eval "use myconst '' => ''";
ok($@, "invalid args checked");

eval "use myconst a => { '' => '' }";
ok($@, "invalid args checked");

eval "use myconst undef() => ''";
ok($@, "invalid args checked");

eval "use myconst a => { 3 => '' }";
ok($@, "invalid args checked");

eval "use myconst 3 => ''";
ok($@, "invalid args checked");

eval qq(use myconst a => { "'" => '' });
ok($@, "invalid args checked");

eval "use myconst '\\\\' => ''";
ok($@, "invalid args checked");

eval qq(use myconst a => { "aaa'bbb" => '' });
ok($@, "invalid args checked");

eval "use myconst 'bbb\@aaa' => ''";
ok($@, "invalid args checked");

{
    no warnings;
    eval "use myconst a => { undef() => '' }";
    ok($@, "invalid args checked");
}
