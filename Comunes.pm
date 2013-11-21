#!C:\PERL\bin\perl.exe
package Comunes;

use strict;
use Data::Dumper;
use Database;

sub seleccionar_menu { #ver de hacerlo en con JQuery...
	my $seleccionado = shift;
	
	my $musicos;
    my $bandas;
    my $reservas;

	if ( $seleccionado eq 'musicos' ){
		$musicos = q| class="current_page_item" |;
	}elsif ( $seleccionado eq 'bandas' ){
        $bandas = q| class="current_page_item" |;
    }else{
        $reservas = q| class="current_page_item" |;   
	}

	return qq|
		<li $reservas><a href="reservas.cgi" title="">reservas</a></li>
        <li $musicos><a href="musicos.cgi" title="">M&uacute;sicos</a></li>
        <li $bandas><a href="bandas.cgi" title="">Bandas</a></li>
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

        my $dbh = Database->new();
        
        my $sth = $dbh->prepare('INSERT INTO estadisticas ('.join(',', keys %estadistica).') VALUES (?,?,?,?,?)');
        
        $sth->execute( values %estadistica );

    }

}


1;