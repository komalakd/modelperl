#!/usr/bin/perl

use strict;
use CGI;
use Data::Dumper;
use CGI::Session;
# use Sesion;

my $cgi = CGI->new();

my $accion = $cgi->param('accion');
my $id_usuario = 'avalle';
# my $nombre_usuario = "ANDRES";


##########################
######## ACCIONES ########
##########################

if ( $accion eq 'set_session' && $id_usuario){
	
	my $session = set_session( $id_usuario );
	my $cookie = get_cookie( $session );
	my $sid = $session->id();

	print $cgi->header( -cookie => $cookie );
	print "Se ha creado la sesion: $sid";

}elsif ( $accion eq 'get_session' ){

	my $session = get_session( $id_usuario );
	my $sid = $session->id();
	my $cookie = get_cookie( $session );

	my $nombre_usuario = $session->param( $id_usuario );

	print $cgi->header( -cookie => $cookie );
	print "La sesion recuperada es: $sid. ";
	
	if ( $nombre_usuario ){
		print "El nombre de usuario recuperado es: $nombre_usuario.";
	}else{
		print "La sesion no tiene almacenado ningun usuario.";
	}

}elsif ( $accion eq 'delete_session' ){

	delete_session( );
	print $cgi->header();
	$cgi->print('Sesion borrada');

}else{

	$cgi->header();
	$cgi->print('Variables pasadas');

}

exit 0;


###########################
######## FUNCIONES ########
###########################

# Class Method: set_session
# brief: Devuelve un nuevo objeto CGI::Session a partir de un id_usuario. Borra sesion actual.
# param: int id_usuario
# return: objeto CGI::Session 
sub set_session {

	my $id_usuario = shift;
	delete_session();
	my $session = new CGI::Session( "driver:File", $cgi, {Directory=>'/tmp'} );
	$session->param( $id_usuario, "ANDRES" );
	return $session || '';

}

# Class Method: get_session
# brief: Devuelve el objeto CGI::Session de la sesion actual. Devuelve vacio si no existe.
# return: objeto CGI::Session 
sub get_session {

	my $sid = $cgi->cookie( "CGISESSID" ) || undef;
	my $session = new CGI::Session( undef, $sid, {Directory => '/tmp'} );
	return $session || '';

}

# Class Method: delete_session
# brief: Borra sesion actual.
sub delete_session {

	my $sid = $cgi->cookie("CGISESSID") || undef;
	my $session = new CGI::Session( undef, $sid, {Directory=>'/tmp'} );	
	$session->delete();
	return '';

}

# Object Method: get_cookie
# brief: Devuelve la cookie de la sesion que se envia como parametro. Devuelve vacio si no existe.
# return: string cookie
sub get_cookie {

	my $session = shift;
	my $sid = $session->id();
	my $cookie = $cgi->cookie( CGISESSID => $session->id );
	return $cookie;

}