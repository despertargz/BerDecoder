use MIME::Base64;

sub convertPemToDer {
	my $pem = shift;

	$pem =~ s/-----BEGIN CERTIFICATE-----//;
	$pem =~ s/-----END CERTIFICATE-----//;
	$pem =~ s/\n//g;
	$pem =~ s/\r//g;

	return decode_base64($pem);
}