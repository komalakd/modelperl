#!C:\PERL\bin\perl.exe

use strict;

# use lib './';

use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use HTML::Template;
use Data::Dumper;

use lib ('./lib/perl');
use lib ('./lib/perl/Model');

use Database;
use Musico;
use Comunes;

my $q = CGI->new();

my $session = CGI::Session->load();
if( $session->is_expired || $session->is_empty ){
	print $session->header( 
		-location=>'index.cgi' 
	);
}

my $dbh = Database->new( );
# my $dbh = $dblogin->get_dbh( $session->{user} );

my $accion     = $q->param('accion');
my $id_musico = $q->param('id_musico');

##########################
######## ACCIONES ########
##########################

if ( $accion eq 'alta' ){

	mostrar_alta();

}elsif ( $accion eq 'acepta_alta' ){

	my $error = registrar_musico();
	$error 
		? mostrar_alta($error) 
		: mostrar_musicos();

}elsif ( $accion eq 'modificacion' && $id_musico ){

	my $error = mostrar_modificacion( $id_musico );
	mostrar_musicos( $error ) if $error;

}elsif ( $accion eq 'acepta_modificacion' && $id_musico ){

	my $error = modificar( $id_musico );
	$error 
		? mostrar_modificacion( $id_musico, $error ) 
		: mostrar_musicos( "Los datos del musico se han modificado correctamente." );

}elsif ( $accion eq 'eliminar' && $id_musico ){

	my $error = eliminar( $id_musico );
	mostrar_musicos( $error ) if $error;
	mostrar_musicos( "El musico se ha eliminado correctamente." );

}else{

	mostrar_musicos();

}

exit 0;


##########################################
############### FUNCIONES ################
##########################################

sub mostrar_musicos {

	my $error = shift;

	my $colection = Musico->GetAll();
	my $rows = $colection->collect( [qw/id_musico nombre telefono_fijo telefono_celular/] );

	print "Content-type: text/html\n\n"; # FIXME - mover abajo
	print Dumper ($rows);

	my $tmplColumnaIzq = HTML::Template->new(filename => 'templates/musicos.html');
	$tmplColumnaIzq->param(
		ROWS => $rows
	);

	my $css = q|
		<link href="css/general/demo_table.css" rel="stylesheet" type="text/css">
	|;

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		CSS => $css,
		TABLA_AMIGOS => $tmplColumnaIzq->output,
		LISTA_MENU => Comunes::seleccionar_menu('musicos'),
		ALERT => $error
	);

	
	print $escritorio->output;

}

sub mostrar_alta {

	my $error = shift;
	
	my $formAlta = HTML::Template->new(filename => 'templates/musicos_alta.html');
	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	
	$escritorio->param(
		TABLA_AMIGOS => $formAlta->output,
		ALERT => $error,
		LISTA_MENU => Comunes::seleccionar_menu('musicos')
	);
	
	print "Content-type: text/html\n\n";
	print $escritorio->output;

	return;
}

sub registrar_musico {

	my ($dni,$nombre,$apellido,$telefono_fijo,$telefono_celular) = $q->param(qw/dni nombre apellido telefono_fijo telefono_celular/);

	return "Error: Debe ingresar todos los datos obligarios." if grep { !$_ } ($dni,$nombre,$apellido,$telefono_fijo,$telefono_celular);

	my $musico = Musico->new(
		dni 				=> $dni,
		nombre 				=> $nombre,
		apellido 			=> $apellido,
		telefono_fijo 		=> $telefono_fijo,
		telefono_celular 	=> $telefono_celular,
	);

	return $musico->save();
}

sub mostrar_modificacion {
	
	my $id_musico = shift;
	my $error = shift;

	my $musico = Musico->GetOne( id_musico => [$id_musico] );
	
	return "Error: No existe un musico con id_musico $id_musico." unless $musico;

	my $formModificacion = HTML::Template->new(filename => 'templates/musicos_modificacion.html');
	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');

	$formModificacion->param(
		map { $_ => $musico->get($_) } qw/id_musico nombre apellido telefono_fijo telefono_celular/
		# ID_MUSICO  => $musico->get( qw/id_musico/ ),
		# NOMBRE     => $musico->get( qw/nombre/ ),
		# APELLIDO   => $musico->get( qw/apellido/ ),
		# FIJO       => $musico->get( qw/fijo/ ),
		# CELULAR    => $musico->get( qw/celular/ ),
	);
	
	$escritorio->param(
		TABLA_AMIGOS => $formModificacion->output,
		ALERT        => $error,
		LISTA_MENU   => Comunes::seleccionar_menu('musicos')
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
	return;
}


sub modificar {

	my $id_musico = shift;

	my ($dni,$nombre,$apellido,$fijo,$celular) = $q->param(qw/dni nombre apellido telefono_fijo telefono_celular/);

	return "Error: Debe ingresar todos los datos obligarios." if grep { !$_ } ($dni,$nombre,$apellido,$fijo,$celular);

	my $musico = Musico->GetOne( id_musico => [$id_musico] );
	
	return "Error: No existe un musico con id_musico $id_musico." unless $musico;

	$musico->set(
		id_musico  			=> $id_musico,
		dni        			=> $dni,
		nombre     			=> $nombre,
		apellido   			=> $apellido,
		telefono_fijo       => $fijo,
		telefono_celular 	=> $celular,
	);

	return $musico->save();
}

sub eliminar {
	my $id_musico = shift;

	my $musico = Musico->GetOne( id_musico => [$id_musico] );
	return "Error: No existe un musico con id_musico $id_musico." unless $musico;
	$musico->delete() and return '';
}
