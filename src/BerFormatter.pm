use v5.10;

package BerFormatter;

sub New {
	return bless {};
}

sub Format {
	my $self = shift;
	my $berTokens = shift;
	my $printHeader = shift || 0;
	my $groupOidWithValue = shift || 0;
	my $indent = shift || 0;

	my $oidValue = 0;
	foreach my $token (@$berTokens) {
		#set each iteration for oid groupings
		my $tabs = " " x 4 x $indent;

		if ($token->{type}->{constructed} eq "Constructed") {
			if ($printHeader == 1) {
				say $tabs . "(". $token->{type}->{tag} . ", " . $token->{length}  . ")";
			}
			$self->Format($token->{value}, $printHeader, $groupOidWithValue, $indent + 1);
		}
		else {
			#if this is an oid value, it should be beside the oid key and should not be tabbed.
			if ($oidValue == 1) {
				$tabs = "";
				$oidValue = 0;
			}

			#for 'universal' class use empty string as default
			my $classToPrint = "";

=to debug we want to print out universal
=the next $classToPrint will be removed
			if ($token->{type}->{class} ne "Universal") {
				$classToPrint = $token->{type}->{class} . "|"
			}
=cut

			$classToPrint = $token->{type}->{bits} . "|" . $token->{type}->{class};

			print $tabs . "[". $classToPrint . $token->{type}->{tag} . ", " . $token->{length} . "]: " . $token->{value};

			#end of line char
			if ($groupOidWithValue == 1 && $token->{type}->{tag} eq "OBJECT IDENTIFIER") {
				print " = ";
				$oidValue = 1;
			}
			else {
				print "\n";
			}
		}
	}
}

return 1;