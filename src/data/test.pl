use strict;
use warnings;
use v5.10;

my $bytes = pack("B*", "0111111011111111");

#little-endian 16-bit
#outputs 32511
say unpack("v", $bytes);

#big-endian 16-bit
#outputs 65406
say unpack("n", $bytes);
