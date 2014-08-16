use strict;
use warnings;

use MIME::Base64;
use File::Slurp;

my $inputFilename = shift @ARGV;
my $outputFilename = shift @ARGV;

my $text = read_file($inputFilename);
my $der = convertPemToDer($text);

open (my $outFileHandle, ">", $outputFilename);
$outFileHandle->print($der);

sub convertPemToDer {
	my $pem = shift;

	$pem =~ s/-----BEGIN CERTIFICATE-----//;
	$pem =~ s/-----END CERTIFICATE-----//;
	$pem =~ s/\n//g;
	$pem =~ s/\r//g;

	return decode_base64($pem);
}