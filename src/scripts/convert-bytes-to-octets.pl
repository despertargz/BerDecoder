use strict;
use warnings;
use v5.10;

open my $file, "<", 'E:\Projects\Perl\Der\demos\helloworld.ber';
my $bytes = <$file>;
my @bytes = split //, $bytes;

foreach (@bytes) {
	my $octet = unpack "B*", $_;
	print $octet . "\n";
}