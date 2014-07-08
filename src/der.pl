use strict;
use warnings;

use v5.10;
use FindBin qw($Bin);

use File::Slurp;
use Data::Dumper;
use MIME::Base64;

#------------------------

my $filename = "$FindBin::Bin\\data\\webtest.der";
print $filename;
my $scalarBytes = read_file($filename, binmode => ':raw');
my @bytes = split('', $scalarBytes);
ber_decode(\@bytes);


#------------------------

sub getTextOctets {
	my $filename = shift;
	
	my $text = read_file($filename, binmode => ':raw');
	my $onesAndZeros = unpack("B*", $text);
	my @octets = ( $onesAndZeros =~ m/.{8}/g );
	
	return @octets;
}

sub formatByte {
	my $byte = shift;

	my $bitString = unpack("B8", $byte);
	my $number = unpack("C", $byte);
	my $letter = $byte;
	
	return "$bitString $letter $number";
}

sub ber_getType {
	my $byte = shift;
	my $octet = unpack("B8", $byte);
	say $octet;
	
	my $classBits = substr($octet, 0, 2);
	my $constructedBits = substr($octet, 2, 1);
	my $tagBits = substr($octet, 3, 5);
	
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
	
	my $type = {
		class => $classBits,
		constructed => $constructedBits,
		tag => 1
	};
	
}

sub ber_getLength {
}

sub ber_decode {
	#arrayref
	my $bytes = shift;
	
	my $bytesLength = @$bytes;
	for (my $x = 0; $x < $bytesLength; $x++) {
		my $byte = $bytes->[$x];
		my $type = ber_getType($byte);
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