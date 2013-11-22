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
	# testear_insert();
	# testear_update();
	testear_delete();
	# testear_coleccion_nueva();
	# testear_coleccion_existente();
	# testear_ambas_colecciones();
	# testear_query_params();
}

#! Funciones !#

sub testear_insert {
	my $musico = Musico->new( 
		dni => 34933298,
		nombre => 'nombre',
		apellido => 'apellido',
		telefono_fijo => '123',
		telefono_celular => '456',
		id_complejo => 1,
	);
	$musico->save();
	
	print $fh $/."testear_insert: ".$/;
	print $fh Dumper( $musico );
}

sub testear_update {
	my $musico = Musico->GetOne(1);
	$musico->set(nombre => 'Otro', apellido => 'Otro');
	$musico->save();

	print $fh $/."testear_update: ".$/;
	print $fh Dumper( $musico );
}

sub testear_delete {
	my $musico = Musico->GetOne(1);
	$musico->delete();
	$musico->save();

	print $fh $/."testear_delete: ".$/;
	print $fh Dumper( $musico );
}

sub testear_coleccion_nueva {
	my @musicos = get_musicos_nuevos();
	Musico->Save(\@musicos);

	print $fh $/."testear_coleccion_nueva: ".$/;
	print $fh Dumper( $_ ) foreach @musicos;
}

sub testear_coleccion_existente {
	my @musicos = get_musicos_guardados();
	Musico->Save(\@musicos);

	print $fh $/."testear_coleccion_existente: ".$/;
	print $fh Dumper( $_ ) foreach @musicos;
}

sub testear_ambas_colecciones {
	my @musicos1 = get_musicos_nuevos();
	my @musicos2 = get_musicos_guardados();
	my @musicos = (@musicos1,@musicos2);

	Musico->Save(\@musicos);

	print $fh $/."testear_ambas_colecciones: ".$/;
	print $fh Dumper( $_ ) foreach @musicos;	
}

sub get_musicos_nuevos {
	my $musico1 = Musico->new( 
		dni => 11111111,
		nombre => 'nombre1',
		apellido => 'apellido1',
		telefono_fijo => '111',
		telefono_celular => '111',
	);
	my $musico2 = Musico->new( 
		dni => 22222222,
		nombre => 'nombre2',
		apellido => 'apellido2',
		telefono_fijo => '222',
		telefono_celular => '222',
	);
	my $musico3 = Musico->new( 
		dni => 33333333,
		nombre => 'nombre3',
		apellido => 'apellido3',
		telefono_fijo => '333',
		telefono_celular => '333',
	);

	$musico2->set(dni => 99999999);
	$musico3->delete();
	
	my @musicos = ($musico1,$musico2,$musico3);
	return \@musicos;
}

sub get_musicos_guardados {
	my $musico1 = Musico->GetOne(dni => 44444444);
	my $musico2 = Musico->GetOne(dni => 55555555);
	my $musico3 = Musico->GetOne(dni => 66666666);

	my @musicos = ($musico1,$musico2,$musico3);
	return (\@musicos);
}

# sub testear_query_params {
# 	my $params = Model->QueryParams(
# 		where => { id_musico => [4,5], caca => ['mucha','poca'] },
# 		page_number => 2,
# 	);
# 	print Dumper($params);
# }

sub testear_getall {
	my $params = Musico->GetAll(
		where => { id_musico => [4,5], telefono_fijo => [43424252] },
		page_number => 3,
	);
	print Dumper($params);
}
