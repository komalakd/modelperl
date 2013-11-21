#!C:\PERL\bin\perl.exe

use strict;
use CGI;
use Database;
use Data::Dumper;
use Sesion;
use HTML::Template;

print STDERR 'login';

my $q = CGI->new();
my $accion = $q->param('accion');

if ( $accion eq 'login' ){

	login();

}elsif ( $accion eq 'logout' ){

	logout();
	mostrar_login();

}else{
	
	mostrar_login();	

}

exit 0;


sub login {

	my $user = $q->param('user');
	my $pass = $q->param('pass');

	my $dbh = Database->new();

	my $r = $dbh->selectall_arrayref(qq|
	    SELECT user, password FROM usuarios WHERE user = ? AND password = ?
	|,undef,$user,$pass);

	if ( scalar @$r != 0 ){

		Sesion::set_session( $user );
		print $q->redirect('escritorio.cgi');
	}else{
		mostrar_login( "ERROR" );
	}

}


sub logout {

	delete_session();
	mostrar_login();

}


sub mostrar_login {

	my $error = shift;

	my $login = HTML::Template->new(filename => 'index.html');

	print $q->header();
	print $login->output;

}


# Redireccionamos
# my $q = CGI->new();
# print $q->redirect('login.html') if !Sesion::get_session();