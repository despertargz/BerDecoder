use strict;
use warnings;
use v5.10;

my $hex = "2a864886f70d010105";
my $byteText = pack "H*", $hex;
my @bytes = split //, $byteText;

my $oid = getOid(@bytes);
print $oid;


sub getOid {
    my $bytes = shift;

    my @finalBytes = ();
    while (@bytes) {
        my $num = convertFromVLQ(\@bytes);
        push @finalBytes, $num;
    }

    return join '.', @finalBytes;
}

sub convertFromVLQ {
    my $bytes = shift;

    my $firstByte = shift @$bytes;
    my $bitString = unpack "B*", $firstByte;

    my $firstBit = substr $bitString, 0, 1;
    my $remainingBits = substr $bitString, 1, 7;

    my $remainingByte = pack "B*", '0' . $remainingBits;
    my $remainingInt = unpack "C", $remainingByte;

    if ($firstBit eq '0') {
        return $remainingInt;
    }
    else {
        my $bitBuilder = $remainingBits;

        my $nextFirstBit = "1";
        while ($nextFirstBit eq "1") {
            my $nextByte = shift @$bytes;
            my $nextBits = unpack "B*", $nextByte;

            $nextFirstBit = substr $nextBits, 0, 1;
            my $nextSevenBits = substr $nextBits, 1, 7;

            $bitBuilder .= $nextSevenBits;
        }

        my $MAX_BITS = 32;
        my $missingBits = $MAX_BITS - (length $bitBuilder);
        my $padding = 0 x $missingBits;
        $bitBuilder = $padding . $bitBuilder;

        my $finalByte = pack "B*", $bitBuilder;
        my $finalNumber = unpack "N", $finalByte;
        return $finalNumber;
    }
}

=start
    n  An unsigned short (16-bit) in "network" (big-endian) order.
    v  An unsigned short (16-bit) in "VAX" (little-endian) order.
=cut
