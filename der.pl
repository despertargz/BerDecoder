use strict;
use warnings;

use FindBin qw($Bin);
use File::Slurp;

my @octets = getOctets("$Bin\\text.txt");

$, = "\n";
print @octets;

sub getOctets {
	my $filename = shift;
	
	my $text = read_file($filename, binmode => ':raw');
	my $onesAndZeros = unpack("B*", $text);
	my @octets = ( $onesAndZeros =~ m/.{8}/g );
	
	return @octets;
}

sub printOctet {
	my $octet = shift;
}