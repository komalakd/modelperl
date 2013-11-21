#!C:\PERL\bin\perl.exe

use strict;

# use lib ('./lib/perl');
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Database;
use HTML::Template;
use Data::Dumper;
use Comunes;

my $q = CGI->new();

my $session = CGI::Session->load();
if( $session->is_expired || $session->is_empty ){
	print $session->header( 
		-location=>'index.cgi' 
	);
}

my $dbh = Database->new();

my $accion     = $q->param('accion');
my $id_reserva = $q->param('id_reserva');
my $id_complejo = 1; #fixme


##########################
######## ACCIONES ########
##########################

if ( $accion eq 'alta' ){

	mostrar_alta();

}elsif ( $accion eq 'acepta_alta' ){

	my $error = registrar_reserva();
	mostrar_alta( $error ) if $error;

}elsif ( $accion eq 'confirma_alta' ){

	my $error = registrar_reserva2();
	registrar_reserva( $error ) if $error;

}elsif ( $accion eq 'ver_reserva' && $id_reserva ){

	my $error = ver_reserva( $id_reserva );
	mostrar_reservas( $error ) if $error;

}elsif ( $accion eq 'acepta_modificacion' && $id_reserva ){

	my $error = modificar( $id_reserva );
	$error 
		? ver_reserva( $id_reserva, $error ) 
		: mostrar_reservas( "Los datos de la reserva se han modificado correctamente." );

}elsif ( $accion eq 'eliminar' && $id_reserva ){

	my $error = eliminar( $id_reserva );
	ver_reserva( $id_reserva, $error ) if $error;
	mostrar_reservas( "La reserva se ha cancelado" );

}else{

	mostrar_reservas();

}

exit 0;


##########################################
######## FUNCIONES PARA RESERVAS #########
##########################################

sub mostrar_reservas {

	my $error = shift;
	my $dia = $q->param('dia');

	my $cond_dia = '';

	
	if ( $dia ){
		my $dia = join '-', ( split '_', $dia );
	}else{
		$dia = "'2013-02-25'";
	}

	# #fixme
	# my $dias_adyacentes = $dbh->selectall_arrayref(q|
	#     SELECT ADDDATE(?,-1), ADDDATE(?,1)
	# |,undef,$dia,$dia);
	# print STDERR Dumper $dias_adyacentes;
	# my ($hoy,$maniana) = $dias_adyacentes->[0..1];

	my $salas = $dbh->selectall_arrayref(qq|
	    SELECT id_sala, nombre
	    FROM salas
	    WHERE id_complejo = 1 AND estado = 'A'
	|,undef);

	my @ids_salas = map { $_->[0] } @$salas;

	print STDERR Dumper \@ids_salas;	

	my $salas_placeholders = join ',', map { '?' } @ids_salas;

	# Recuperamos los datos de las reservas del dia de hoy fixme!
	my $resultSet = $dbh->selectall_arrayref(qq|
	    SELECT id_reserva, id_musico, id_banda, id_sala, tipo_reserva,
	    TIME(fecha_desde) AS celda, 
		TIMEDIFF(fecha_hasta,fecha_desde) AS diff
	    FROM reservas
	    WHERE fecha_cancelacion IS NULL 
	    AND dia_virtual = $dia
	    AND id_sala IN ($salas_placeholders)
	|,undef,@ids_salas);

	print STDERR Dumper $resultSet;	
 	

	my @reservas;
	foreach my $row (@$resultSet) {
		my %reserva;
		my ($id_reserva,$id_musico,$id_banda,$id_sala,$tipo_reserva,$celda,$diff) = @$row;
		
		my $nombre_musico = $dbh->selectall_arrayref(qq|
		    SELECT CONCAT(nombre,' ',apellido)
		    FROM musicos
		    WHERE id_complejo = 1 AND id_musico = ?
		|,undef,$id_musico)->[0][0];

		my $nombre_banda;
		if ( $id_banda ){
			$nombre_banda = $dbh->selectall_arrayref(qq|
			    SELECT nombre
			    FROM bandas
			    WHERE id_complejo = 1 AND id_banda = ?
			|,undef,$id_banda)->[0][0];
		
			print STDERR Dumper $nombre_banda; 

		}



		$reserva{id_reserva} = $id_reserva;
		$reserva{id_sala} = $id_sala;
		# $reserva{nombre_sala} = $nombre_sala;
		$reserva{id_musico} = $id_musico;
		$reserva{nombre_musico} = $nombre_musico;
		$reserva{id_banda} = $id_banda || '';
		$reserva{nombre_banda} = $nombre_banda || '';
		$reserva{tipo_reserva} = $tipo_reserva;

		my ($hora,$min,$seg) = split ':', $celda;
		$reserva{id_celda} = $hora.$min."_".$id_sala;

		my ($hora,$min,$seg) = split ':', $diff;
		$reserva{cant_celdas} = $hora * 2 + ($min == 30 ? 1 : 0);

		$reserva{clase} = $tipo_reserva eq 'F' ? 'reserva fijo' : 'reserva noFijo';

		push @reservas, \%reserva;
	}

	print STDERR Dumper \@reservas;


	# my $reservas = [
	# 	{ 
	# 		'id_reserva'=> 1,
	# 		'id_celda'=> '1200_1',
	# 		'cant_celdas'=> 2,
	# 		'clase'=> 'reserva fijo',
	# 		'texto'=> 'Reserva 1',
	# 		'musico'=> 'Señor músico',
	# 	},
	# 	{ 
	# 		'id_reserva'=> 2,
	# 		'id_celda'=> '1500_2',
	# 		'cant_celdas'=> 3,
	# 		'clase'=> 'reserva noFijo',
	# 		'texto'=> 'Reserva 2',
	# 		'musico'=> 'Señor músico',
	# 		'banda'=> 'La banda',
	# 	},
	# 	{ 
	# 		'id_reserva'=> 3,
	# 		'id_celda'=> '1200_3',
	# 		'cant_celdas'=> 8,
	# 		'clase'=> 'reserva fijo',
	# 		'texto'=> 'Reserva 3',
	# 		'musico'=> 'Señor músico',
	# 		'banda'=> 'La banda',
	# 	},
	# 	{ 
	# 		'id_reserva'=> 4,
	# 		'id_celda'=> '1700_1',
	# 		'cant_celdas'=> 2,
	# 		'clase'=> 'reserva fijo',
	# 		'texto'=> 'Reserva 4',
	# 		'musico'=> 'Señor músico',
	# 		'banda'=> 'La banda',
	# 	},
	# 	{ 
	# 		'id_reserva'=> 5,
	# 		'id_celda'=> '1400_1',
	# 		'cant_celdas'=> 1,
	# 		'clase'=> 'reserva noFijo',
	# 		'texto'=> 'Reserva 5',
	# 		'musico'=> 'Señor músico',
	# 	}
	# ];


	require JSON;
	my $reservas_json = JSON->new->space_after->encode( \@reservas );

	my @hashes_salas = map { { id_sala => $_->[0], nombre_sala => $_->[1] } } @$salas;

	print STDERR Dumper \@hashes_salas;
	
	# my $salas = [
	# 	{
	# 		id_sala => 1,
	# 		nombre_sala => 'SALA 1',
	# 	},
	# 	{
	# 		id_sala => 2,
	# 		nombre_sala => 'SALA 2',
	# 	},
	# 	{
	# 		id_sala => 3,
	# 		nombre_sala => 'SALA 3',
	# 	},
	# ];


	my @horarios = (11..23,'00'..'01');
	# @horarios = map { ($_.':00',$_.':30') } @horarios;
	@horarios = map { 
		( {hora => $_, min => '00', loop_salas => \@hashes_salas}, {hora => $_, min => '30', loop_salas => \@hashes_salas} )
	} @horarios;


	my $tmpl_reservas = HTML::Template->new(
		filename => 'templates/reservas.html',
		global_vars => 1,
		die_on_bad_params => 0,
	);
	$tmpl_reservas->param(
		RESERVAS => $reservas_json,
		SALAS => \@hashes_salas,
		HORARIOS => \@horarios,
	);

	my $css = q|
		<link href="css/reservas/reservas.css" rel="stylesheet" type="text/css">
	|;

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		CSS => $css,
		TABLA_AMIGOS => $tmpl_reservas->output,
		LISTA_MENU => Comunes::seleccionar_menu('reservas'),
		ALERT => $error
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;

}

sub mostrar_alta {

	my $error = shift;

	my $accesorios_db = $dbh->selectall_arrayref(qq|
	    SELECT id_accesorio, descripcion, marca, modelo, precio
	    FROM accesorios 
	    WHERE id_complejo = $id_complejo
	|,undef);

	my @accesorios;
	foreach my $row ( @$accesorios_db) {
		my ($id_accesorio,$descripcion,$marca,$modelo,$precio) = @$row;
		push @accesorios, { 
			id_accesorio => $id_accesorio, 
			nombre       => $descripcion,
			descripcion  => $marca.' - '.$modelo,
			precio       => $precio,
		};
	}

	my $salas_db = $dbh->selectall_arrayref(qq|
	    SELECT id_sala, nombre AS nombre_sala
	    FROM salas
	    WHERE id_complejo = 1 AND estado = 'A'
	    ORDER BY nombre
	|,undef);

	my @salas;
	foreach my $row ( @$salas_db) {
		my ($id_sala,$nombre) = @$row;
		push @salas, { 
			id_sala     => $id_sala, 
			nombre_sala => $nombre, 
		};
	}

	my $formAlta = HTML::Template->new(filename => 'templates/reserva_alta.html');
	$formAlta->param(
		SALAS      => \@salas,
		ACCESORIOS => \@accesorios,
	);
	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formAlta->output,
		ALERT => $error,
		LISTA_MENU => Comunes::seleccionar_menu('reservas'),
		
	);
	
	print "Content-type: text/html\n\n";
	print $escritorio->output;

	return;
}

sub registrar_reserva {

	my $error = shift;

	my $id_sala = $q->param('id_sala');
	my $desde = $q->param('desde');
	my $hasta = $q->param('hasta');
	my $nombre = $q->param('nombre');
	my $apellido = $q->param('apellido');
	my $fijo = $q->param('fijo');
	my $celular = $q->param('celular');
	my $banda = $q->param('banda');
	# my @alquileres = $q->param('alquileres');
	my $tipo_reserva = $q->param('tipo_reserva');


	# fixme
	# my @alquilados = $q->param('check_alquilado');

	# Validar tipos de datos.

	# if ( grep { !$_ } ($id_sala,$desde,$hasta,$nombre,$apellido) ){
	# 	return "Error: Debe ingresar todos los datos obligarios."
	# }

	unless ( $fijo || $celular ){
		return "Error: Debe ingresar al menos un numero de telefono."	
	}

	my ($date_desde,$time_desde) = split ' ', $desde;
	my $desde = join '-', (split '/',$date_desde);
	
	my ($date_hasta,$time_hasta) = split ' ', $hasta;
	my $hasta = join '-', (split '/',$date_hasta);

	# Validar que no haya un ensayo en esas horas.
	
	# return "La sala $id_sala esta reservada dentro de ese intervalo de tiempo.";

	# NO TRATAR ACCESORIOS EN ESTA PANTALLA.

	# Buscar musico
	my $musicos_db = $dbh->selectall_arrayref(q|
	    SELECT id_musico,nombre,apellido,fijo,celular
	    FROM musicos
	|,undef);

	my @musicos;
	foreach my $row (@$musicos_db) {
		my($id_musico_db,$nombre_db,$apellido_db,$fijo_db,$celular_db) = @$row;

		my $coincidencias = 0;
		if (index($nombre_db, $nombre) != -1) {
			$coincidencias++;
		}
		if (index($apellido_db, $apellido) != -1) {
			$coincidencias++;
		}
		if (index($fijo_db, $fijo) != -1) {
			$coincidencias++;
		}
		if (index($celular_db, $celular) != -1) {
			$coincidencias++;
		}

		if ( $coincidencias > 2 ){
			push @musicos, {
				ID_MUSICO => $id_musico_db,
				NOMBRE => $nombre_db,
				APELLIDO => $apellido_db,
				FIJO => $fijo_db,
				CELULAR => $celular_db,
			};
		}
	}

	my @bandas;
	if ( $banda ){# Buscar banda
		my $bandas_db = $dbh->selectall_arrayref(q|
		    SELECT id_banda,nombre
		    FROM bandas
		    WHERE
		    	nombre   LIKE '%?%'
		|,undef,$banda);

		foreach my $row (@$bandas_db) {
			my($id_banda,$nombre) = @$row;
			push @bandas, {
				ID_BANDA => $id_banda,
				NOMBRE => $nombre,
			};
		}
	}

	# REGISTRO BANDA Y MUSICO SI NO MATCHEAN
	if ( scalar @musicos == 0){
		my $r = $dbh->do(q|
		    INSERT INTO musicos
		    (nombre,apellido,celular,fijo,fecha_alta,id_complejo)
		    VALUES
		    (?,?,?,?,NOW(),?)
		|,undef,$nombre,$apellido,$celular,$fijo,$id_complejo);
	}

	if ( scalar @bandas == 0 && $banda){
		my $r = $dbh->do(q|
		    INSERT INTO bandas
		    (nombre,fecha_alta,id_complejo)
		    VALUES
		    (?,NOW(),?)
		|,undef,$nombre,$id_complejo);
	}


	# Mostrar datos ingresados mas tablas de musicos y bandas con options
	my $formModificacion = HTML::Template->new(filename => 'templates/reserva_acepta_alta.html');

	if ( scalar @musicos ){
		$formModificacion->param(
			VARIOS_MUSICOS => \@musicos,
			MUSICOS        => $id_reserva,
		);
	}else{
		$formModificacion->param(
			NOM_Y_AP => $nombre.' '.$apellido,
		);
	}

	if ( scalar @bandas ){
		$formModificacion->param(
			VARIAS_BANDAS => \@bandas,
			BANDAS        => $id_reserva,
		);
	}elsif($banda){
		$formModificacion->param(
			BANDA => $banda,
		);
	}

	$formModificacion->param(
		ID_SALA     => $id_reserva,
		DESDE       => $id_sala,
		HASTA       => $desde,
		TIPO_ENSAYO => $hasta,
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formModificacion->output,
		ALERT        => $error,
		LISTA_MENU   => Comunes::seleccionar_menu('reservas')
	);
	print "Content-type: text/html\n\n";
	print $escritorio->output;


	return '';
}



sub registrar_reserva2 {

	# tomar los resultados de la pantalla
	# mas musico y banda

	my $id_sala = $q->param('id_sala');
	my $id_musico = $q->param('id_musico');
	my $id_banda = $q->param('id_banda');
	my $desde = $q->param('desde'),;
	my $hasta = $q->param('hasta');
	my $tipo_reserva =	$q->param('tipo_reserva');

	my @alquilados = $q->param('check_alquilado');

	# to-do
	# Validar tipos de datos.

	# print STDERR "param->hasta";
	# print STDERR Dumper $hasta;

	my ($date_desde,$time_desde) = split ' ', $desde;
	my $desde = join ( '-', reverse (split '/',$date_desde) );
	$desde .= ' '.$time_desde . ':00';
	
	# Calculamos dia virtual:
	my ($hora,$min) = split ':',$time_desde;
	my $dia_virtual;
	print STDERR "HORA->";
	print STDERR Dumper ($hora);
	if ( int($hora) <= 11 ){
		$dia_virtual = "'$desde'";
	}else{
		$dia_virtual = "ADDDATE('$desde',-1)"; # RESTAR 1
	}

	my ($date_hasta,$time_hasta) = split ' ', $hasta;
	my $hasta = join ( '-', reverse (split '/',$date_hasta) );	
	$hasta .= ' '.$time_hasta . ':00';



	if ( grep { !$_ } ($id_sala,$id_musico,$desde,$hasta) ){
		return "Error: Debe ingresar todos los datos obligarios."
	}

	# Validar existencia del musico, banda (si ingresa), sala, disponibilidad de horario y accesorios

	print STDERR "DIA VIRTUAL:";
	print STDERR Dumper $dia_virtual;

	my $r = $dbh->do(qq|
	    INSERT INTO reservas
	    (id_sala,id_musico,id_banda,fecha_desde,fecha_hasta,dia_virtual,fecha_reserva,tipo_reserva)
	    VALUES
	    (?,?,?,?,?,$dia_virtual,NOW(),?)
	|,undef,$id_sala,$id_musico,$id_banda?$id_banda:'',$desde,$hasta,$tipo_reserva?'F':'N');

	foreach my $id_accesorio (@alquilados) {
		
		my $r = $dbh->do(qq|
		    INSERT INTO alquileres
		    (id_reserva,id_accesorio)
		    VALUES
		    (?,?)
		|,undef,$id_reserva,$id_accesorio);

	}

	return '';

}



sub ver_reserva {
	
	my $id_reserva = shift;
	my $error = shift;

	my $r = $dbh->selectall_arrayref(qq|
	    SELECT id_sala, id_musico, id_banda, fecha_desde, fecha_hasta
	    FROM reservas
	    WHERE id_reserva = ?
	|,undef,$id_reserva);
	
	return "Error: No existe reserva." if scalar @$r == 0;

	my ($id_sala,$id_musico,$id_banda,$desde,$hasta) = @{ $r->[0] };

	my $r2 = $dbh->selectall_arrayref(qq|
	    SELECT nombre, apellido, telefono_fijo, telefono_celular
	    FROM musicos
	    WHERE id_musico = ?
	|,undef,$id_musico);

	print STDERR Dumper($id_musico);
	
	return "Error: No existe musico." if scalar @$r2 == 0;

	my $musico = $r2->[0][1] . ', ' . $r2->[0][0];

	my $banda;
	if ( $id_banda ){
		my $r3 = $dbh->selectall_arrayref(qq|
		    SELECT nombre
		    FROM bandas
		    WHERE id_banda = ?
		|,undef,$id_banda);
		
		return "Error: No existe banda." if scalar !@$r3;

		$banda = $r3->[0][0];
	}

	#fixme
	my $r4 = $dbh->selectall_arrayref(qq|
	    SELECT id_accesorio, descripcion, marca, modelo, precio
		FROM accesorios
	    WHERE id_complejo = ?
	|,undef,1);

	my $r5 = $dbh->selectall_arrayref(qq|
	    SELECT id_accesorio
		FROM alquileres 
	    WHERE id_reserva = ?
	|,undef,$id_reserva);

	print STDERR Dumper $r5;

	my %alquilados;
	foreach my $alquilado ( @$r5 ){
		$alquilados{$alquilado->[0]} = 1;
	}

	print STDERR Dumper $r4;

	my @accesorios_loop;
	foreach my $row (@$r4) {
		my ($id_accesorio,$descripcion,$marca,$modelo,$precio) = @$row;
		my $accesorios;
		$accesorios->{id_accesorio} = $id_accesorio,
		$accesorios->{nombre} = $descripcion,
		$accesorios->{descripcion} = $marca.' - '.$modelo,
		$accesorios->{precio} = $precio,
		$accesorios->{alquilado} = (defined $alquilados{$id_accesorio}) ? 1 : 0,
		push @accesorios_loop, $accesorios;
	}


	my $formModificacion = HTML::Template->new(filename => 'templates/reserva_modificacion.html');

	$formModificacion->param(
		ID_RESERVA => $id_reserva,
		ID_SALA    => $id_sala,
		MUSICO     => $musico,
		DESDE      => $desde,
		HASTA      => $hasta,
		ACCESORIOS => \@accesorios_loop,
	);
	$formModificacion->param( BANDA => $banda ) if $id_banda;

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formModificacion->output,
		ALERT        => $error,
		LISTA_MENU   => Comunes::seleccionar_menu('reservas')
	);
	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
	return;
}

# por ahora solo se estan modificando los alquileres! ^^
sub modificar {

	my $id_reserva = shift;

	my @alquilados = $q->param('check_alquilado');

	my $accesorios_complejo = $dbh->selectall_hashref(qq|
	    SELECT id_accesorio
	    FROM accesorios 
	    WHERE id_complejo = $id_complejo AND estado = 'D'
	|,'id_accesorio');

	if ( grep { ! defined $accesorios_complejo->{$_} } @alquilados ){
		return "Error: Los accesorios seleccionados no son validos.";
	}

	my $r = $dbh->do(q|
	    DELETE from alquileres where id_reserva = ?
	|,undef,$id_reserva);

	foreach my $accesorio (@alquilados) {
		my $r = $dbh->do(q|
		    INSERT INTO alquileres (id_reserva,id_accesorio)
		    VALUES (?,?)
		|,undef,$id_reserva,$accesorio);
	}
	
	return '';
}


sub eliminar {
	my $id_reserva = shift;

	# fixme -> validar que falten mas de 48hs para el ensayo
	my $eliminacion_valida = $dbh->selectall_arrayref(q|
	    SELECT s.id_complejo 
	    FROM reservas r
	    JOIN salas s
	    ON r.id_sala = s.id_sala
	    WHERE id_reserva = ? AND s.id_complejo = ?
	|,undef,$id_reserva, $id_complejo);

	return "Error al eliminar: La reserva $id_reserva no es valida." if !@$eliminacion_valida;

	my $r2 = $dbh->do(q|
	    DELETE FROM alquileres 
	    WHERE id_reserva = ?
	|,undef,$id_reserva);

	my $r2 = $dbh->do(q|
	    UPDATE reservas
	    SET fecha_cancelacion = NOW()
	    WHERE id_reserva = ?
	|,undef,$id_reserva);

	# return $r3 ? '' : "Error al eliminar: No existe musico con id_musico $id_musico.";

	# my $r2 = $dbh->do(qq|
	#     SELECT nombre 
	#     FROM funciones
	#     WHERE id_musico = ? AND id_complejo = ?
	# |,undef,$id_musico,$id_complejo);

	# if ( @$r2 ){
	# 	my $nombre_musico = $r2->[0][0];
	# 	return "Error: No se puede eliminar el musico $nombre_musico porque existen descuentos asignados para la misma." ;
	# }



}
