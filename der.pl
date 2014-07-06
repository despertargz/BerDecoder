use strict;
use warnings;

use v5.10;
use FindBin qw($Bin);

use File::Slurp;
use Data::Dumper;
use MIME::Base64;

#------------------------

my $filename = "E:\\Projects\\Perl\\Der\\text.txt";
my $certFile = "E:\\Projects\\Perl\\Der\\webtest.cer";

my $pemContent = read_file($certFile);
my $der = convertPemToDer($pemContent);
write_file("E:\\Projects\\Perl\\Der\\webtest.der", $der);

#my $scalarBytes = read_file($filename, binmode => ':raw');
#my $bytes = [ split('', $scalarBytes) ];



#------------------------

sub getTextOctets {
	my $filename = shift;
	
	my $text = read_file($filename, binmode => ':raw');
	my $onesAndZeros = unpack("B*", $text);
	my @octets = ( $onesAndZeros =~ m/.{8}/g );
	
	return @octets;
}

sub printOctetOld {
	my $octet = shift;
	
	my $letter = pack("B8", $octet);
	my $number = unpack("C", $letter);
	say "$octet $letter $number";
}

sub formatByte {
	my $byte = shift;

	my $bitString = unpack("B8", $byte);
	my $number = unpack("C", $byte);
	my $letter = $byte;
	
	return "$bitString $letter $number";
}

sub ber_getType {
}

sub ber_getLength {
}

sub ber_decode {
	#arrayref
	my $bytes = shift;
	
	my $bytesLength = @$bytes;
	for (my $x = 0; $x <= $bytesLength; $x++) {
		#@$bytes[$x];
	}
	
	
}

sub convertPemToDer {
	my $pem = shift;
	
	$pem =~ s/-----BEGIN CERTIFICATE-----//;
	$pem =~ s/-----END CERTIFICATE-----//;
	$pem =~ s/\n//g;
	$pem =~ s/\r//g;
	
	return decode_base64($pem);
}