#!C:\PERL\bin\perl.exe

# use strict;

# use lib ('./lib/perl');
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Database;
use HTML::Template;
use Data::Dumper;
use Comunes;

my $q = CGI->new();

$session = CGI::Session->load();
if( $session->is_expired || $session->is_empty ){
	print $session->header( 
		-location=>'index.cgi' 
	);
}

my $dbh = Database->new();

my $accion     = $q->param('accion');
my $id_amigo   = $q->param('id_amigo');
my $id_funcion = $q->param('id_funcion');


##########################
######## ACCIONES ########
##########################

if ( $accion eq 'alta' ){

	mostrar_alta();

}elsif ( $accion eq 'acepta_alta' ){

	my $error = registrar_funcion();
	$error 
		? mostrar_alta($error) 
		: mostrar_funciones();

}elsif ( $accion eq 'modificacion' && $id_funcion ){

	my $error = mostrar_modificacion( $id_funcion );
	mostrar_funciones( $error );#if $error;

}elsif ( $accion eq 'acepta_modificacion' && $id_funcion ){

	my $error = modificar( $id_funcion );
	$error 
		? mostrar_modificacion( $id_funcion, $error ) 
		: mostrar_funciones( "Los datos de la funcion se han modificado correctamente." );

}elsif ( $accion eq 'eliminar' && $id_funcion ){

	my $error = eliminar( $id_funcion );
	# mostrar_funciones( $error ) if $error;
	mostrar_funciones(  );

}else{

	mostrar_funciones();

}

exit 0;


##########################################
######## FUNCIONES PARA FUNCIONES ########
##########################################

sub mostrar_funciones {

	my $error = shift;

	# Recuperamos los datos de las funciones (que no fueron eliminadas)
	my $resultSet = $dbh->selectall_hashref(qq|
	    SELECT f.id_funcion, nombre, descripcion, ultima_fecha, descuento, COUNT(d.id_funcion) AS cant_descuentos
	    FROM funciones f
	    LEFT JOIN descuentos_pedidos d
	    ON f.id_funcion = d.id_funcion 
	    WHERE estado = 'A'
	    GROUP BY f.id_funcion
	|,'id_funcion');

	# my $amigos;
	# my $cantAmigos = %$resultSet;

	my @arreglo;
	foreach my $k ( keys %$resultSet ){
		# print Dumper( $resultSet->{$k} )."\n";
		push @arreglo,$resultSet->{$k};
	}

	my $tmplColumnaIzq = HTML::Template->new(filename => 'templates/funciones.htm');
	$tmplColumnaIzq->param(
		ROWS => \@arreglo
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		TABLA_AMIGOS => $tmplColumnaIzq->output,
		LISTA_MENU => Comunes::seleccionar_menu('funciones'),
		ALERT => $error
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;

}

sub mostrar_alta {

	my $error = shift;
	my $formAlta = HTML::Template->new(filename => 'templates/funciones_alta.html');

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formAlta->output,
		ALERT => $error,
		LISTA_MENU => Comunes::seleccionar_menu('funciones')
	);
	
	print "Content-type: text/html\n\n";
	print $escritorio->output;

	return;
}

sub registrar_funcion {

	my ($nombre,$descripcion,$ultima_fecha,$descuento) = 
		( $q->param('nombre'),$q->param('descripcion'),$q->param('ultima_fecha'),$q->param('descuento') );

	if ( grep { !$_ } ($nombre,$descripcion,$ultima_fecha,$descuento) ){
		return "Error: Debe ingresar todos los datos obligarios."
	}

	# my $r1 = $dbh->selectall_arrayref(qq|
	#     SELECT id_amigo 
	#     FROM amigos 
	#     WHERE dni = ?
	# |,undef,$dni);

	# return "Error al intentar dar de alta el amigo: Ya existe un amigo con el DNI ingresado." if @$r1 != 0;

	my $r = $dbh->do(qq|
	    INSERT INTO funciones (nombre, descripcion, ultima_fecha, descuento)
	    VALUES (?, ?, ?, ?)
	|,undef,$nombre,$descripcion,$ultima_fecha,$descuento);

	return '';
}

sub mostrar_modificacion {
	
	my $id_funcion = shift;
	my $error = shift;

	
	my $r = $dbh->selectall_arrayref(qq|
	    SELECT nombre, descripcion, ultima_fecha, descuento 
	    FROM funciones 
	    WHERE id_funcion = ?
	|,undef,$id_funcion);
	
	return "Error: No existe un amigo con id_amigo $id_amigo." if scalar !@$r;

	my $formModificacion = HTML::Template->new(filename => 'templates/funciones_modificacion.html');

	$formModificacion->param(
		ID_FUNCION  => $id_funcion,
		NOMBRE      => $r->[0][0],
		DESCRIPCION => $r->[0][1],
		UFECHA      => $r->[0][2],
		DESCUENTO   => $r->[0][3],
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formModificacion->output,
		ALERT        => $error,
		LISTA_MENU   => Comunes::seleccionar_menu('funciones')
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
	return;
}


sub modificar {

	my $id_funcion = shift;

	my ($nombre,$descripcion,$ultima_fecha,$descuento) = 
		( $q->param('nombre'),$q->param('descripcion'),$q->param('ultima_fecha'),$q->param('descuento') );

	if ( grep { !$_ } ($nombre,$descripcion,$ultima_fecha,$descuento) ){
		return "Error: Debe ingresar todos los datos obligarios."
	}

	my $r1 = $dbh->selectall_arrayref(qq|
	    SELECT nombre, descripcion, ultima_fecha, descuento 
	    FROM funciones 
	    WHERE id_funcion = ? AND estado = 'A'
	|,undef,$id_funcion);
	
	return "Error: No existe una funcion con id_funcion $id_funcion." if scalar !@$r1;

	my $r2 = $dbh->do(qq|
	    UPDATE funciones SET nombre = ?, descripcion = ?, ultima_fecha = ?, descuento = ?
	    WHERE id_funcion = ?
	|,undef,$nombre,$descripcion,$ultima_fecha,$descuento,$id_funcion);

	return '';
}


sub eliminar {
	my $id_funcion = shift;

	my $r1 = $dbh->do(qq|
	    SELECT f.nombre 
	    FROM funciones f
	    WHERE f.id_funcion = ?
	    AND estado != 'A'
	|,undef,$id_funcion);

	return "Error al eliminar: No existe funcion con id_funcion $id_funcion." if @$r1;

	my $r2 = $dbh->do(qq|
	    SELECT f.nombre 
	    FROM funciones f
	    JOIN descuentos_pedidos d
	    ON f.id_funcion = d.id_funcion
	    WHERE f.id_funcion = ?
	|,undef,$id_funcion);

	if ( @$r2 ){
		my $nombre_funcion = $r2->[0][0];
		return "Error: No se puede eliminar la funcion $nombre_funcion porque existen descuentos asignados para la misma." ;
	}

	my $r3 = $dbh->do(qq|
	    UPDATE funciones 
	    SET estado = 'D' 
	    WHERE id_funcion = ?
	|,undef,$id_funcion);

	return '';
}
