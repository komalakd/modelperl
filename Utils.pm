#!C:\PERL\bin\perl.exe
package Utils;

use strict;
use Data::Dumper;
use Database;

sub seleccionar_menu { #ver de hacerlo en con JQuery...
	my $seleccionado = shift;
	
	my $amigos;
	my $funciones;

	if ( $seleccionado == 1 ){
		$amigos = q| class="current_page_item" |;
	}else{
		$funciones = q| class="current_page_item" |;
	}

	return qq|
		<li $amigos><a href="amigos.cgi" title="">Nuestros Amigos</a></li>
		<li $funciones><a href="funciones.cgi" title="">Funciones</a></li>
	|;

}


sub registrar_estadistica {
    my ( $id_usuario, $seccion, $accion, $items ) = @_;

    my @items = ref $items eq 'ARRAY' ? @{ $items } : ($items);

    if ( @items ){

        my $ids_items = join(',',@items);
        
        $ids_items = substr($ids_items,0,27).'...' if ( length($ids_items) > 30 );

        my %estadistica = (
            id_usuario        => $id_usuario,
            seccion           => $seccion,
            accion            => $accion,
            id_item           => $items,
            fecha             => 'NOW()',
        );

        my $dbh = Educativa::DataBase->new( connect_to => 'aula' );
        
        my $sth = $dbh->prepare('INSERT INTO estadisticas ('.join(',', keys %estadistica).') VALUES (?,?,?,?,?)');
        
        $sth->execute( values %estadistica );

    }

}

1;