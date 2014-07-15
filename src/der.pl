use strict;
use warnings;
use diagnostics;

use v5.10;
use FindBin qw($Bin);

use File::Slurp;
use Data::Dumper;
use MIME::Base64;

#------------------------

my $filename = "$Bin\\data\\webtest.der";

my $scalarBytes = read_file($filename, binmode => ':raw');
my @bytes = split //, $scalarBytes;
my $berTokens = ber_decode(\@bytes);
#say Dumper($berTokens);
ber_formatter_format($berTokens);


=start
my $byte = pack("B*", "10000010");
my $nByte = pack("B*", "11111111");
my $nnByte = pack("B*", "00000000");
my $bytes = [ $byte, $nByte, $nnByte ];
print (ber_getLength($bytes));
=cut




#------------------------


sub ber_getTag {
	my $number = shift;

	my $tagText = <<END;
EOC (End-of-Content)
BOOLEAN
INTEGER
BIT STRING
OCTET STRING
NULL
OBJECT IDENTIFIER
Object Descriptor
EXTERNAL
REAL (float)
ENUMERATED
EMBEDDED PDV
UTF8String
RELATIVE-OID
(reserved)
(reserved)
SEQUENCE and SEQUENCE OF
SET and SET OF
NumericString
PrintableString
T61String
VideotexString
IA5String
UTCTime
GeneralizedTime
GraphicString
VisibleString
GeneralString
UniversalString
CHARACTER STRING
BMPString
(use long-form)
END

	my @tagList = split("\n", $tagText);
	return $tagList[$number];
}

sub ber_getType {
	my $byte = shift;
	my $octet = unpack("B8", $byte);

	my $classBits = substr($octet, 0, 2); #[00]000000
	my $constructedBits = substr($octet, 2, 1); #00[0]00000
	my $tagBits = substr($octet, 3, 5); #000[00000];

	my $classMap = {
		'00' => 'Universal',
		'01' => 'Application',
		'10' => 'Context-Specific',
		'11' => 'Private'
	};

	my $constructedMap = {
		'0' => 'Primitive',
		'1' => 'Constructed'
	};

	$tagBits = "000" . $tagBits; #must pad up to 8 bits so pack can read correctly
	my $tagByte = pack("B8", $tagBits);
	my $tagNumber = unpack("C", $tagByte);
	my $tagName = ber_getTag($tagNumber);

	my $type = {
		class => $classMap->{$classBits},
		constructed => $constructedMap->{$constructedBits},
		tag => $tagName
	};

	#If it is not universal, then we can't know tag type so set these to unknown
	if ($type->{class} ne "Universal") {
		$type->{tag} = "UNKNOWN ($octet)";
		$type->{constructed} = "Primitive";
	}
	return $type;
}

sub ber_getLength {
	my $bytes = shift;
	my $firstByte = shift $bytes;

	my $bitString = unpack("B8", $firstByte);

	#calculate integer from bits 7-1 0[000000]
	my $remainingBits = "0" . substr($bitString, 1, 7);
	my $remainingLengthByte = pack("B8", $remainingBits);
	my $remainingLengthNumber = unpack("C", $remainingLengthByte);

	my $firstBit = substr($bitString, 0, 1); # [0]0000000
	if ($firstBit eq "0") {
		#YAY! Short form, we're done. return the size of the remaining 7 bits.
		return $remainingLengthNumber;
	}
	else {
		#UH-OH, long form. Now we have to do some work :(
		#our 7 bit integer tells us how many remaining octects to string together to form our unsigned integer
		#this means we can have an integer as large as 127 (max 7 bit number) * 8 bits per octet = 1016 bit integer.
		#i've written this implementation to use a maximum of 32bit unsigned integer, if your number is bigger than that...good luck.

		my $octetBuilder = "";

		#no c-style for loops here....
		foreach (1..$remainingLengthNumber) {
			my $nextByte = shift $bytes;
			my $nextBitString = unpack("B8", $nextByte);
			$octetBuilder .= $nextBitString;
		}

		#todo: make constant or readonly
		my $MAX_BIT_LENGTH = 32;
		my $bitsShyOfMax = $MAX_BIT_LENGTH - (length $octetBuilder);
		my $padding = ('0' x $bitsShyOfMax);
		$octetBuilder = $padding . $octetBuilder;

		my $longByte = pack("B*", $octetBuilder);

		#bitstring is built with big-endian so we will use that to get the integer
		my $longNumber = unpack("N", $longByte);

		return $longNumber;
	}
}

sub ber_formatter_format {
	my $berTokens = shift;
	my $indent = shift || 0;

	my $tabs = " " x 4 x $indent;

	#say Dumper($berTokens);
	#say Dumper($berTokens->[0]);
	#my @tokens = @$berTokens;

	foreach my $token (@$berTokens) {
		if ($token->{type}->{constructed} eq "Constructed") {
			#print header for constructed values (if not printed it will just indent showing that it is a collection)
			#say $tabs . "(" . $token->{type}->{class} . "|" . $token->{type}->{tag} . ") [" . $token->{length} . "] ";
			ber_formatter_format($token->{value}, $indent + 1);
		}
		else {
			say $tabs . "(" . $token->{type}->{class} . "|" . $token->{type}->{tag} . ") [" . $token->{length} . "] " . $token->{value};
		}
	}
}

sub ber_getValue {
    my $type = shift; #class berType
    my $bytes = shift; #arrayRef<byte>

    my $value;
    if ($type->{constructed} eq "Constructed") {
        $value = ber_decode($bytes);
    }
    elsif ($type->{tag} eq "OBJECT IDENTIFIER") {
        $value = ber_content_getOid($bytes);
    }
	elsif ($type->{tag} eq "UTF8String" || $type->{tag} eq "PrintableString" || $type->{tag} eq "BMPString") {
		$value = ber_content_getStr($bytes);
	}
    else {
        #dont know how to decode, just return hex representation
        my $joinedValue = join '', @$bytes;
        $value = unpack 'H*', $joinedValue;
    }

    return $value;
}

sub ber_decode {
	my $bytes = shift; #arrayref

	say "starting with " . scalar(@$bytes);

	my $berTokens = [];

	while (@$bytes) {
		my $byte = shift @$bytes;
		#say Dumper($byte);

		my $type = ber_getType($byte);
		#say "type > " . Dumper($type);

		my $length = ber_getLength($bytes);

		my @valueRaw = splice @$bytes, 0, $length;
        my $value = ber_getValue($type, \@valueRaw);

		my $berToken = {
			type => $type,
			length => $length,
			value => $value
		};

		#say Dumper($berToken);
		#say scalar(@$bytes) . " left";
		push @$berTokens, $berToken;
	}

	return $berTokens;
}

sub ber_content_getStr {
	#arrayRef<byte>
	my $bytes = shift;

	return join '', @$bytes;
}

sub ber_content_getOid {
    my $bytes = shift;

    #first 2 nodes are 'special';
    use integer;
    my $firstByte = shift @$bytes;
    my $number = unpack "C", $firstByte;
    my $nodeFirst = $number / 40;
    my $nodeSecond = $number % 40;

    my @finalBytes = ($nodeFirst, $nodeSecond);

    while (@$bytes) {
        my $num = convertFromVLQ($bytes);
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


sub printOctetOld {
	my $octet = shift;

	my $letter = pack("B8", $octet);
	my $number = unpack("C", $letter);
	say "$octet $letter $number";
}

sub convertPemToDer {
	my $pem = shift;

	$pem =~ s/-----BEGIN CERTIFICATE-----//;
	$pem =~ s/-----END CERTIFICATE-----//;
	$pem =~ s/\n//g;
	$pem =~ s/\r//g;

	return decode_base64($pem);
}
