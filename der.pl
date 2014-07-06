use strict;
use warnings;

use v5.10;
use FindBin qw($Bin);

use File::Slurp;
use Data::Dumper;

my $filename = "E:\\Projects\\Perl\\Der\\text.txt";
my $scalarBytes = read_file($filename, binmode => ':raw');
my $bytes = [ split('', $scalarBytes) ];

for my $byte (@$bytes) {
	say formatByte($byte);
}

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

sub decode {
	my $bytes = shift;
	foreach my $byte ($bytes) {
		
	}
	
	
}