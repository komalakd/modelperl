package Database;

use strict;
use DBI;

{
my $instance;

sub GetInstance {
    my $self = shift;
    
    return $instance if $instance;

    my $driver   = "mysql";
    my $database = "modelperl";
    my $hostname = "localhost";
    my $port     = "3306";
    my $username = "root";
    my $password = "root";

    my $dsn = "DBI:$driver:database=$database;host=$hostname;port=$port";

    $instance = DBI->connect($dsn, $username, $password) or die("Could not connect!");

    return $instance;
}
}
1;