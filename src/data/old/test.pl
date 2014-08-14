use strict;
use warnings;
use v5.10;

use LWP::Simple;

#print get("http://pic.dhe.ibm.com/infocenter/zos/v1r13/index.jsp?topic=%2Fcom.ibm.zos.r13.gska100%2Fsssl2oids.htm");

my $hex = "18496e7465726e6574205769";
print pack("H*", $hex);
