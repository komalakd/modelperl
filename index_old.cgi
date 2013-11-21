#!C:\PERL\bin\perl.exe

use strict;
use CGI;
use Database;
use Data::Dumper;
use Sesion;
use HTML::Template;

# print STDERR 'login';

my $q = CGI->new();
my $accion = $q->param('accion');

if ( $accion eq 'login' ){

	login();

}elsif ( $accion eq 'logout' ){

	logout();
	mostrar_login();

}else{
	
	# Validar si el usuario esta logueado
	redirigir_usuario_logueado() || mostrar_login();

}

exit 0;


sub login {

	my $user = $q->param('name');
	my $pass = $q->param('pass');

	my $dbh = Database->new();

	my $r = $dbh->selectall_arrayref(qq|
	    SELECT user, password FROM usuarios WHERE user = ? AND password = ?
	|,undef,$user,$pass);

	if ( scalar @$r != 0 ){

		my $sesion = Sesion::set_session( $user );
		my $cookie = Sesion::get_cookie($sesion)->value;


		print $q->redirect(
			-url     => 'amigos.cgi',
			# -cookie  => $cookie
		);

	}else{
		mostrar_login( "ERROR: Usuario y/o contraseña incorrectos." );
	}

}


sub logout {

	Sesion::delete_session( ); 
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
		-url     => 'amigos.cgi',
		-cookie  => $cookie
	);

}