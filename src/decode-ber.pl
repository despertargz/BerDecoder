use strict;
use warnings;
use diagnostics;
use v5.10;

use FindBin qw($Bin);
use File::Slurp;
use Data::Dumper;
use lib $Bin;

use BerDecoder;
use BerFormatter;

my $filename = shift @ARGV;

my $scalarBytes = read_file($filename, binmode => ':raw');
my @bytes = split //, $scalarBytes;

my $berDecoder = BerDecoder->New();
my $berTokens = $berDecoder->Decode(\@bytes);

my $berFormatter = BerFormatter->New();
my $berText = $berFormatter->Format($berTokens, 0, 0);

print $berText;