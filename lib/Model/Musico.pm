package Model::Musico;

use base 'Model'; 

use strict;
use Data::Dumper;

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

1;
