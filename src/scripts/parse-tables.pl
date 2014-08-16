use strict;
use warnings;
use v5.10;

use FindBin;
use File::Slurp;
use Data::Dumper;

use HTML::TreeBuilder;

my $url = shift @ARGV;
my @rows = downloadAllTables($url);
foreach (@rows) {
	say $_;
}

sub downloadAllTables {
	my $url = shift;
	my $delimiter = shift || ",";

	my $tree = HTML::TreeBuilder->new_from_url($url);
	my @rows = $tree->find("tr");
	my $allTableData = [];

	foreach my $row (@rows) {
		my $rowData = [];
		my @tds = $row->content_list();
		foreach my $td (@tds) {
			my $content = $td->content()->[0];
			if (ref($content) eq "HTML::Element") {
				$content = $content->content()->[0];
			}

			push($rowData, $content);
		}

		push($allTableData, $rowData);
	}

	my @result = map { join($delimiter, @{$_}) } @$allTableData;
	return @result;
}


sub getColumnNames {
	my $tree = shift;
	my @ths = $tree->find("th");
	my @columnNames = map { $_->content()->[0] } @ths;
	return @columnNames;
}

#converts td's into array ref of hash refs whose properties are the th's.
sub parseHtmlTable {
	my $filename = shift;

	my $html = read_file($filename);
	my $parser = HTML::TreeBuilder->new();
	my $tree = $parser->parse_file($filename);

	my @headers = getColumnNames($tree);
	my $columnCount = @headers;

	my $objectList = [];
	my @trs = $tree->find("tr");

	#loop rows
	foreach my $tr (@trs) {
		my @tds = $tr->content_list();
		my $object = {};

		#loop columns
		for (my $x = 0; $x < $columnCount; $x++) {
			my $content = $tds[$x]->content()->[0];

			if (ref($content) eq "HTML::Element") {
				$content = $content->content()->[0];
			}

			my $column = $headers[$x];
			$object->{$column} = $content;
		}

		push($objectList, $object);
	}

	return $objectList;
}
