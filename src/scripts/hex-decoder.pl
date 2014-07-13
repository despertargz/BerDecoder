use strict;
use warnings;

while (1) {
    my $input = <STDIN>;
    chomp $input;

    my $byte = pack "H*", $input;
    my $number = unpack "C", $byte;
    my $bitstring = unpack "B*", $byte;
    print " =$number $bitstring\n";
}
