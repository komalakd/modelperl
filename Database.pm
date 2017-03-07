package Database;

use strict;
use DBI;

sub new {
	my $self = shift;
    my $driver   = "mysql";
	my $database = "modelperl";
	my $hostname = "localhost";
	my $port     = "3306";
	my $username = "root";
	my $password = "root";

	my $dsn = "DBI:$driver:database=$database;host=$hostname;port=$port";

	return DBI->connect($dsn, $username, $password) or die("Could not connect!");
}

1;