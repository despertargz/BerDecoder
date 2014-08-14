use strict;
use warnings;

my $outFile;
open($outFile, '>', "E:\\Projects\\Perl\\Der\\demos\\helloworld.ber") or die "could not open file";
$outFile->print("does this work?");
close $outFile;