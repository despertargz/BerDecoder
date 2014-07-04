use strict;
use warnings;
use v5.10;
use FindBin qw($Bin);

use File::Slurp;

my @octets = getOctets("$Bin\\text.txt");
foreach my $octet (@octets) {
	printOctet($octet);
}

#$, = "\n";
#print @octets;

sub getOctets {
	my $filename = shift;
	
	my $text = read_file($filename, binmode => ':raw');
	my $onesAndZeros = unpack("B*", $text);
	my @octets = ( $onesAndZeros =~ m/.{8}/g );
	
	return @octets;
}

sub printOctet {
	my $octet = shift;
	
	my $letter = pack("B8", $octet);
	my $number = unpack("C", $letter);
	say "$octet $letter $number";
}