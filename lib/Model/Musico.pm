package Model::Musico;

use base 'Model'; 

use strict;
use Data::Dumper;

sub classname {
    return 'Model::Musico';
}

sub table {
    return 'musicos';
}

sub pk_fields {
    return qw/id_musico/;
}

sub non_pk_fields {
    return qw/
        dni
        nombre
        apellido
        telefono_fijo
        telefono_celular
        fecha_alta
        id_complejo
    /;
}

sub relations {
    return {
        'pets' => {
            type   => 'has_many',
            model  => 'Model::Pet',
            trough => 'id_musico',
        }
    }
}

1;
