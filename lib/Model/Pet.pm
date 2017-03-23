package Model::Pet;

use base 'Model'; 

use strict;
use Data::Dumper;

sub classname {
    return 'Model::Pet';
}

sub table {
    return 'pets';
}

sub pk_fields {
    return qw/id_pet/;
}

sub non_pk_fields {
    return qw/
        nombre
        apodo
        raza
        id_musico
    /;
}

sub relations {
    return {
        'owner' => {
            type   => 'belongs_to',
            model  => 'Model::Musico',
            trough => 'id_musico',
        }
    }
}

1;
