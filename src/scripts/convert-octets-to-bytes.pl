use strict;
use warnings;
use diagnostics;
use v5.10;

use File::Slurp;

open my $fh, '<', 'E:\Projects\Perl\Der\demos\helloworld.txt';
my @lines = <$fh>;
chomp @lines;

my $outFile;
open($outFile, '>:raw', "E:\\Projects\\Perl\\Der\\demos\\helloworld.ber") or die "could not open file";
foreach my $line (@lines) {
	my $byte = pack "B*", $line;
	print( unpack( "C", $byte));
	print "\n";
	$outFile->print($byte);
}
close $outFile;