#!C:\PERL\bin\perl.exe
use strict;
use DBI;

package Database;
sub new {
	my $self = shift;
	my $database = "salasrosario";
	my $hostname = "localhost";
	my $port = "3306";
	my $username = "root";
	my $password = '';

	my  $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";

	my $dbh = DBI->connect($dsn, $username, $password) or die("Could not connect!");

	return $dbh;
}

1;