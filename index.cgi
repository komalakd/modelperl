#!C:\PERL\bin\perl.exe

use strict;
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Database;
use Data::Dumper;
use HTML::Template;

my $q = CGI->new();
my $session = CGI::Session->load();
my $accion = $q->param('accion');

if ( $accion eq 'login' ){

	login();

}elsif ( $accion eq 'logout' ){

	logout();
	mostrar_login();

}else{
	
	# Validar si el usuario esta logueado
	if( $session->is_expired ){
		mostrar_login( "Su sesion ha expirado" );
	}elsif ( $session->is_empty ){ 
		mostrar_login(  );
	}else{
		print $session->header( 
			-location=>'reservas.cgi' 
		);	
	}

}

exit 0;


sub login {

	my $user = $q->param('name');
	my $pass = $q->param('pass');

	my $dbh = Database->new();

	my $r = $dbh->selectall_arrayref(qq|
	    SELECT id_usuario, password 
	    FROM usuarios 
	    WHERE id_usuario = ? AND password = ? AND estado = 'X'
	|,undef,$user,$pass);

	if ( scalar @$r != 0 ){

		$session = new CGI::Session();
        print $session->header(-location=>'index.cgi');

	}else{
		mostrar_login( "ERROR: Usuario y/o contraseña incorrectos." );
	}

}


sub logout {

	$session = CGI::Session->load() or die CGI::Session->errstr;
    $session->delete();

	mostrar_login( );

}


sub mostrar_login {

	my $error = shift;

	my $template_login = HTML::Template->new(filename => 'templates/login.html');
	$template_login->param(
		ALERT => $error,
	);
	print $q->header();
	print $template_login->output;

}

sub redirigir_usuario_logueado {

	my $sesion = Sesion::get_session( );
	
	my $cookie = Sesion::get_cookie($sesion)->value;

	print STDERR Dumper($cookie);

	return '' unless $cookie;

	print $q->redirect(
		-url     => 'musicos.cgi',
		-cookie  => $cookie
	);

}