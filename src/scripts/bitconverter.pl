use strict;
use warnings;
use v5.10;
use File::Slurp;


my $filename = shift @ARGV;
my $bytesString = read_file($filename, binmode => ':raw');
my @bytes = split //, $bytesString;
foreach my $byte (@bytes) {
	my $octet = formatByte($byte);
	say $octet;
}

sub formatByte {
	my $byte = shift;

	my $bitString = unpack("B8", $byte);

	#todo: add flag to display number and letter of byte
	#my $number = unpack("C", $byte);
	#my $letter = $byte;

	return $bitString;
}
