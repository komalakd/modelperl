#!C:\PERL\bin\perl.exe

# use strict;

# use lib ('./lib/perl');
use CGI;
use Database;
use HTML::Template;
use Data::Dumper;
use Sesion;
use Comunes;

open $fh, '>>', 'debug_descuentos.txt';

my $q = CGI->new();
# print "Content-type: text/html\n\n";
# print 'asd'.Sesion::get_session();die;



#print $q->redirect('login.cgi') if !Sesion::get_session();

my $dbh = Database->new();

my $accion     = $q->param('accion');
my $id_amigo   = $q->param('id_amigo');
my $id_funcion = $q->param('id_funcion');


#FIXME redireccion

##########################
######## ACCIONES ########
##########################
if ( $accion eq 'ver_detalle' && $id_amigo ){

	my $error;# = validar_amigo( $id_amigo ); 

	# $error 
	# 	? #redireccionar a index
	# 	: 
		mostrar_detalle( $error, $id_amigo );

}elsif ( $accion eq 'asignar_descuento' && $id_amigo && $id_funcion){

	my $error;# = validar_amigo( $id_amigo );
	
	#redireccionar a index if $error;

	$error = asignar_descuento( $id_amigo, $id_funcion );
	$error ? 
		mostrar_detalle( $error ) :
		mostrar_detalle( 
			"Se ha registrado el pedido de descuento del amigo $id_amigo para la funcion $id_funcion.",
			$id_amigo 
		);

}else{

	# require Utils;
	# Utils::redirect('index.cgi');

	print "Content-type: text/html\n\n";
	print 'BAD PARAM!';

}

exit 0;



##################################
######## FUNCIONES AMIGOS ########
##################################


sub mostrar_detalle {
	
	my $error = shift;
	my $id_amigo = shift;

	# Recuperamos los datos de las funciones 
	# que tengan como fecha de ultima funcion hoy o en el futuro
	# o que ya fueron pedidas x el amigo
	my $resultSet = $dbh->selectall_arrayref(qq|
		SELECT f.id_funcion, f.nombre, f.descripcion, f.ultima_fecha, f.descuento, d.fecha_pedido
		FROM funciones f
		LEFT JOIN descuentos_pedidos d
		ON ( f.id_funcion = d.id_funcion AND d.id_amigo = ? )
		WHERE ( d.fecha_pedido IS NOT NULL OR f.ultima_fecha > NOW() )
	|,undef,$id_amigo);


	use Data::Dumper;
	print $fh Dumper( $resultSet );

	my @arreglo;

	foreach my $record ( @$resultSet ){
	
		my %row;

		$row{id_funcion}   = $record->[0];
		$row{nombre}       = $record->[1];
		$row{descripcion}  = $record->[2];
		$row{ultima_fecha} = $record->[3];
		$row{descuento}    = $record->[4];
		if ( $record->[5] ){
			
			$row{fecha_pedido} = qq|DESCUENTO PEDIDO|;

        }else{

        	$row{fecha_pedido} = 
        		qq| <a href="descuentos.cgi?accion=asignar_descuento&id_funcion=$row{id_funcion}&id_amigo=$id_amigo">
                        <span>Asignar Descuento</span>
                    </a>  
                |;
			 
        }
		

		print $fh Dumper( $row );
		

		push @arreglo, \%row;
	}
	
	print $fh "arreglo:\n";
	print $fh Dumper( \@arreglo );

	$resultSet = $dbh->selectall_arrayref(qq|
	    SELECT id_amigo, CONCAT(nombre,' ',apellido) FROM amigos WHERE estado = 'A' AND id_amigo = ?
	|,undef,$id_amigo);

	my $tmplColumnaIzq = HTML::Template->new(filename => 'templates/escritorio_detalle.htm');
	$tmplColumnaIzq->param(
		ROWS => \@arreglo,
		nombre_amigo => $resultSet->[0][1],
	);

	my $escritorio = HTML::Template->new(filename => 'templates/escritorio.html');
	$escritorio->param(
		TABLA_AMIGOS => $tmplColumnaIzq->output,
		LISTA_MENU => Comunes::seleccionar_menu(),
		ALERT => $error
	);

	print "Content-type: text/html\n\n";
	print $escritorio->output;
	
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




close $fh;