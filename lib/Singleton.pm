package Singleton;

use strict;

{
    my $instances;
    
    sub GetInstance {
        my $class = shift;
        
        $instances->{$class} = $class->new() unless exists $instances->{$class};

        return $instances->{$class};
    }
}

sub new {
    die 'oops! you forgot to add this method! ^^ ';
}

1;
