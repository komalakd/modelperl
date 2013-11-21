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

open $fh, '>>', 'debug.txt';

my $q = CGI->new();



$session = CGI::Session->load();
if( $session->is_expired || $session->is_empty ){
	print $session->header( 
		-location=>'index.cgi' 
		# -cache_control=>"no-cache, no-store, must-revalidate"
	);
}
# Continua script si esta logueado.


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

	my $error = registrar_amigo();
	$error 
		? mostrar_alta($error) 
		: mostrar_escritorio();

}elsif ( $accion eq 'modificacion' && $id_amigo ){

	my $error = mostrar_modificacion( $id_amigo );
	mostrar_escritorio( $error );#if $error;

}elsif ( $accion eq 'acepta_modificacion' && $id_amigo ){

	my $error = modificar_amigo( $id_amigo );
	$error 
		? mostrar_modificacion( $id_amigo, $error ) 
		: mostrar_escritorio( "Los datos del amigo se han modificado correctamente." );

}elsif ( $accion eq 'eliminar' && $id_amigo ){

	my $error = eliminar_amigo( $id_amigo );
	mostrar_escritorio( $error );

}elsif ( $accion eq 'ver_detalle' && $id_amigo ){

	my $error;# = ver_detalle( $id_amigo );
	mostrar_detalle( $error, $id_amigo );

}elsif ( $accion eq 'asignar_descuento' && $id_amigo && $id_funcion){

	# my $error = ver_detalle( $id_amigo );
	my $error = asignar_descuento( $id_amigo, $id_funcion );
	$error 
		? mostrar_detalle( $error ) 
		: mostrar_detalle( "Se ha registrado el pedido de descuento del amigo $id_amigo para la funcion $id_funcion." );

}elsif ( $accion eq 'alta_funcion' ){

	mostrar_alta_funcion();

}else{

	mostrar_escritorio();

}


close $fh;

exit 0;



##################################
######## FUNCIONES AMIGOS ########
##################################

sub mostrar_alta {
	my $error = shift;
	my $formAlta = HTML::Template->new(filename => 'templates/escritorio_alta.html');

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formAlta->output,
		ALERT => $error,
		LISTA_MENU => Comunes::seleccionar_menu('amigos')
	);
	
	print "Content-type: text/html\n\n";
	print $escritorio->output;

	return;

}

sub registrar_amigo {
	
	my ($dni,$nombre,$apellido,$mail,$telefono) = 
		( $q->param('dni'), $q->param('nombre'),$q->param('apellido'),$q->param('mail'),$q->param('telefono') );

	if ( !$dni || !$nombre || !$apellido || !$mail || !$telefono ){
		return "Error: Debe ingresar todos los datos obligarios."
	}

	my $r1 = $dbh->selectall_arrayref(qq|
	    SELECT id_amigo FROM amigos WHERE dni = ?
	|,undef,$dni);

	return "Error al intentar dar de alta el amigo: Ya existe un amigo con el DNI ingresado." if @$r1 != 0;

	my $r2 = $dbh->do(qq|
	    INSERT INTO amigos (dni, nombre, apellido, mail, estado, telefono, fecha_registro)
	    VALUES (?, ?, ?, ?, 'A', ?, NOW() )
	|,undef,$dni,$nombre,$apellido,$mail,$telefono);

	return '';

}

sub mostrar_modificacion {

	my $id_amigo = shift;
	my $error = shift;

	my $r = $dbh->selectall_arrayref(qq|
	    SELECT dni,nombre,apellido,mail,telefono FROM amigos WHERE id_amigo = ?
	|,undef,$id_amigo);
	
	return "Error: No existe un amigo con id_amigo $id_amigo." if scalar @$r == 0;

	my ($dni,$nombre,$apellido,$mail,$telefono) = @{ $r->[0] };

	my $formModificacion = HTML::Template->new(filename => 'templates/escritorio_modificacion.html');

	$formModificacion->param(
		ID_AMIGO => $id_amigo,
		DNI      => $dni,
		NOMBRE   => $nombre,
		APELLIDO => $apellido,
		MAIL     => $mail,
		TELEFONO => $telefono,
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formModificacion->output,
		ALERT => $error,
		LISTA_MENU => Comunes::seleccionar_menu('amigos')
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
	return;

}

sub modificar_amigo {

	my $id_amigo = shift;

	my ($dni,$nombre,$apellido,$mail,$telefono) = 
		( $q->param('dni'), $q->param('nombre'),$q->param('apellido'),$q->param('mail'),$q->param('telefono') );


	if ( grep { !$_ } ($dni,$nombre,$apellido,$mail,$telefono) ){
		return "Error: Debe ingresar todos los datos obligarios."
	}

	my $r1 = $dbh->selectall_arrayref(qq|
	    SELECT id_amigo,dni FROM amigos WHERE dni = ? AND id_amigo <> ?
	|,undef,$dni,$id_amigo);

	if ( $r1->[0]->[1] == $dni ){
		return "Error: Ya existe un amigo con el DNI ingresado." if @$r1 != 0;
	}

	my $r2 = $dbh->do(qq|
	    UPDATE amigos SET dni = ?, nombre = ?, apellido = ?, mail = ?, telefono = ?
	    WHERE id_amigo = ?
	|,undef,$dni,$nombre,$apellido,$mail,$telefono,$id_amigo);

	return '';

}


sub eliminar_amigo {
	my $id_amigo = shift;

	my $r1 = $dbh->selectall_arrayref(qq|
	    SELECT nombre, descripcion, ultima_fecha, descuento 
	    FROM funciones 
	    WHERE id_funcion = ? AND estado = 'A'
	|,undef,$id_funcion);
	
	return "Error al eliminar: No existe amigo con id_amigo $id_amigo." if scalar !@$r1;

	my $r2 = $dbh->do(qq|
	    UPDATE amigos SET estado = 'D' WHERE id_amigo = ?
	|,undef,$id_amigo);

	return '';

}

sub mostrar_escritorio {

	my $error = shift;

	# Recuperamos los datos de lo amigos (que no fueron eliminados)
	my $resultSet = $dbh->selectall_hashref(qq|
	    SELECT id_amigo, dni, CONCAT(nombre,' ',apellido) AS nombre, telefono, mail FROM amigos WHERE estado = 'A'
	|,'id_amigo');

	# my $amigos;
	# my $cantAmigos = %$resultSet;

	my @arreglo;
	foreach my $k ( keys %$resultSet ){
		# print Dumper( $resultSet->{$k} )."\n";
		push @arreglo,$resultSet->{$k};
	}

	my $tmplColumnaIzq = HTML::Template->new(filename => 'templates/escritorio_izq.htm');
	$tmplColumnaIzq->param(
		ROWS => \@arreglo
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		TABLA_AMIGOS => $tmplColumnaIzq->output,
		LISTA_MENU => Comunes::seleccionar_menu('amigos'),
		ALERT => $error
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
}

sub mostrar_detalle {
	
	my $error = shift;
	my $id_amigo = shift;

	# Recuperamos los datos de las funciones (que tengan como fecha de ultima funcion hoy o en el futuro)
	my $resultSet = $dbh->selectall_hashref(qq|
	    SELECT f.id_funcion, nombre, descripcion, ultima_fecha, descuento, d.fecha_pedido AS fecha_pedido
		FROM funciones f
		LEFT JOIN descuentos_pedidos d
		ON f.id_funcion = d.id_funcion AND d.id_amigo = ?
	|,'id_funcion',$id_usuario);

	# my $amigos;
	# my $cantAmigos = %$resultSet;

	use Data::Dumper;
	print $fh Dumper( $resultSet );

	my @arreglo;
	foreach my $k ( keys %$resultSet ){
		# print Dumper( $resultSet->{$k} )."\n";
		# my $descuento_pedido;
		unless ( $resultSet->{$k}->{fecha_pedido} ){
			$resultSet->{$k}->{fecha_pedido} = '<span>Asignar Descuento</span>';
		}

		push @arreglo,$resultSet->{$k};
	}

	$resultSet = $dbh->selectall_arrayref(qq|
	    SELECT id_amigo, CONCAT(nombre,' ',apellido) FROM amigos WHERE estado = 'A' AND id_amigo = ?
	|,undef,$id_amigo);

	my $tmplColumnaIzq = HTML::Template->new(filename => 'templates/escritorio_detalle.htm');
	$tmplColumnaIzq->param(
		ROWS => \@arreglo,
		# id_amigo => $resultSet->[0][0],
		nombre_amigo => $resultSet->[0][1],
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		TABLA_AMIGOS => $tmplColumnaIzq->output,
		LISTA_MENU => Comunes::seleccionar_menu('amigos'),
		ALERT => $error
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;



	#validar id amigo.

	#mostrar descuentos del amigo.

	#mostrar funciones para asignar descuento.

}

sub asignar_descuento {
	my $id_amigo = shift;
	my $id_funcion = shift;

	my $r = $dbh->selectall_arrayref(qq|
		SELECT * FROM descuentos_pedidos WHERE id_amigo = ? AND id_funcion = ?
	|,undef,$id_amigo,$id_funcion);

	return "El amigo $id_amigo ya tiene asignado un descuento para la funcion $id_funcion" if scalar @$r > 0;

	my $r2 = $dbh->do(qq|
	    INSERT INTO descuentos_pedidos (id_amigo, id_funcion, fecha_pedido)
	    VALUES (?, ?, NOW() )
	|,undef,$id_amigo,$id_funcion);

	return '';
}
