#!/usr/bin/perl

use strict;
use CGI;
use Data::Dumper;
use CGI::Session;


package Sesion;

my $cgi = CGI->new();


sub set_session {

	my $id_usuario = shift;

	my $session = new CGI::Session("driver:File", $cgi, {Directory=>'/tmp'});
	
	# print $cgi->header( -cookie=>$cookie );

	# print "Se ha creado la sesion: $sid";

	$session->param("id_usuario", $id_usuario);

	return $session;

}


sub get_session {

	my $sid = $cgi->cookie("CGISESSID") || undef;

	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});

	return $session;

	my $name = $session->param("id_usuario");

	# print $cgi->header();
	# print "La sesion recuperada es: $sid. ";
	
	# if ( $name ){
	# 	print "El nombre de usuario recuperado es: $name.";
	# }else{
	# 	print "La sesion no tiene almacenado ningun usuario.";
	# }

	return $name;

}


sub delete_session {

	my $sid = $cgi->cookie("CGISESSID") || undef;

	my $session = new CGI::Session(undef, $sid, {Directory=>'/tmp'});	

	$session->delete();

	# print $cgi->header();
	# print "La sesion ha sido eliminada.";

	return;

}

sub get_cookie {

	my $session = shift;
	
	my $sid = $session->id();
	
	my $cookie = $cgi->cookie(CGISESSID => $session->id);

	use Data::Dumper;
	# open my $fh, '>', 'debug.txt';
	# print $fh "var: " . Data::Dumper( $cookie );
	# close $fh;

	

	return $cookie;

}