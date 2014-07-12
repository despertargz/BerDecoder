use strict;
use warnings;
use v5.10;

my $bytes_bigEndian = pack("B*", "1111111100000000");
my $bytes_littleEndian = pack("B*", "0000000011111111");

my $integer_bigEndian = unpack("n", $bytes_bigEndian); # An unsigned short (16-bit) in "network" (big-endian) order.
my $integer_littleEndian = unpack("v", $bytes_littleEndian); # An unsigned short (16-bit) in "VAX" (little-endian) order.

say $integer_bigEndian;
say $integer_littleEndian;
