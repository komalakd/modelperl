#!C:\PERL\bin\perl.exe

use strict;
use Data::Dumper;

use Database;
use Musico;

my $dbh = Database->new( );

print $/."Comienza!".$/;
open my $fh, '>', 'debug.txt';
run();
close $fh;
print $/."Termina!".$/;
exit 0;

sub run {
	testear_getall();
}

#! Funciones !#

sub testear_getall {
	print 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
	my $params = Musico->GetAll(
		where => { id_musico => [4,5], telefono_fijo => [43424252] },
		page_number => 3,
	);
	print Dumper($params);
}