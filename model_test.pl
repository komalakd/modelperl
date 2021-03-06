#!/usr/bin/perl

use strict;
use Data::Dumper;

use lib './lib';
use lib './lib/Model';

use Database;
use Musico;
use Pet;

my $dbh = Database->GetInstance( );

print $/."Comienza!".$/;
open my $fh, '>', 'debug.txt';
run();
close $fh;
print $/."Termina!".$/;
exit 0;

# Casos de prueba:

# [ ] Insertar nuevo musico
# [ ] Actualizar nuevo musico
# [ ] Borrar nuevo musico
# [ ] Modificar musico existente
# [ ] Borrar musico existente
# [ ] Guardar una coleccion de musicos nuevos
# [ ] Guardar una coleccion de musicos existentes
# [ ] Guardar una coleccion de musicos nuevos y existentes
# [ ] Traer listado de musicos

sub run {
    # my $id = testear_insert();
    # my $id2 = testear_insert();
    # testear_update($id);
    # testear_delete($id);
    # testear_coleccion_nueva();
    # testear_coleccion_existente($id2);
    # testear_ambas_colecciones($id2);
    testear_relaciones();
    # testear_query_params();
}

#! Funciones !#

sub testear_insert {
    my $musico = Model::Musico->new( 
        dni              => 34933298,
        nombre           => 'nombre',
        apellido         => 'apellido',
        telefono_fijo    => '123',
        telefono_celular => '456',
        id_complejo      => 1,
    );
    $musico->save();

    return $musico->get('id_musico');
    print $fh $/."testear_insert: ".$/;
    print $fh Dumper( $musico );
}

sub testear_update {
    my $id = shift;
    my $musico = Model::Musico->GetOne(id_musico => [$id]);
    $musico->set(nombre => 'Otro', apellido => 'Otro');
    $musico->save();

    print $fh $/."testear_update: ".$/;
    print $fh Dumper( $musico );
}

sub testear_delete {
    my $id = shift;

    my $musico = Model::Musico->GetOne(id_musico => [$id]);
    $musico->delete();
    $musico->save();

    print $fh $/."testear_delete: ".$/;
    print $fh Dumper( $musico );
}

sub testear_coleccion_nueva {
    my $musicos = get_musicos_nuevos();

    Model::Musico->Save($musicos);

    print $fh $/."testear_coleccion_nueva: ".$/;
    print $fh Dumper( $_ ) foreach @$musicos;
}

sub testear_coleccion_existente {
    my $id = shift;

    my $musicos = get_musicos_guardados( $id );

    Model::Musico->Save($musicos);

    print $fh $/."testear_coleccion_existente: ".$/;
    print $fh Dumper( $_ ) foreach @$musicos;
}

sub testear_ambas_colecciones {
    my $id = shift;
    my $musicos1 = get_musicos_nuevos();
    my $musicos2 = get_musicos_guardados($id);
    my @musicos = (@$musicos1,@$musicos2);

    Model::Musico->Save(\@musicos);

    print $fh $/."testear_ambas_colecciones: ".$/;
    print $fh Dumper( $_ ) foreach @musicos;    
}

sub get_musicos_nuevos {
    my $musico1 = Model::Musico->new( 
        dni => 11111111,
        nombre => 'nombre1',
        apellido => 'apellido1',
        telefono_fijo => '111',
        telefono_celular => '111',
        id_complejo => 1,
    );
    my $musico2 = Model::Musico->new( 
        dni => 22222222,
        nombre => 'nombre2',
        apellido => 'apellido2',
        telefono_fijo => '222',
        telefono_celular => '222',
        id_complejo => 1,
    );
    my $musico3 = Model::Musico->new( 
        dni => 33333333,
        nombre => 'nombre3',
        apellido => 'apellido3',
        telefono_fijo => '333',
        telefono_celular => '333',
        id_complejo => 1,
    );

    $musico2->set(dni => 99999999);
    $musico3->delete();
    
    my @musicos = ($musico1,$musico2,$musico3);
    return \@musicos;
}

sub get_musicos_guardados {
    my $id = shift;

    my $musico1 = Model::Musico->GetOne( id_musico => [$id]);

    return [ $musico1 ];
}

sub testear_query_params {
    my $params = Model->QueryParams(
        where => { id_musico => [4,5], caca => ['mucha','poca'] },
        page_number => 2,
    );
    print Dumper($params);
}

sub testear_getall {
    my $params = Model::Musico->GetAll(
        where => { id_musico => [4,5], telefono_fijo => [43424252] },
        page_number => 3,
    );
    print Dumper($params);
}

sub testear_relaciones {
    my $musico = Model::Musico->new( 
        dni              => 34933298,
        nombre           => 'nombre',
        apellido         => 'apellido',
        telefono_fijo    => '123',
        telefono_celular => '456',
        id_complejo      => 1,
    );
    $musico->save();

    my $id_musico =  $musico->get('id_musico');

    my $mascota = Model::Pet->new( 
        nombre    => 'rocko',
        apodo     => 'coquito',
        raza      => 'beagle',
        id_musico => $id_musico,
    );
    $mascota->save();

    my $id_mascota =  $mascota->get('id_mascota');
    
    print $fh $/."testear_relaciones: ".$/;
    print $fh Dumper( $musico->get_related( 'pets' ) );
    # print $fh Dumper( $mascota->get_related( 'owner' ) );   

}