#!C:\PERL\bin\perl.exe

package Musico;
use base 'Model'; 

use strict;
use Data::Dumper;
use Model;

# Constructor
sub new {
	my $class = shift;
    my $self = {
    	id_denomination => 'id_musico',
    	table => 'musicos',
    	data => {
	    	id_musico 			=> undef,
	    	dni 				=> undef,
	    	nombre 				=> undef,
	    	apellido 			=> undef,
	    	telefono_fijo 		=> undef,
	    	telefono_celular 	=> undef,
	    	fecha_alta 			=> undef,
	    	id_complejo			=> undef,
	    }
    };
    bless $self, $class;
    
    $self->SUPER::new(@_);
    return $self;
}

sub GetAll {
	my $self = shift;

	my $hash = $self->SUPER::GetAll(
		fields => [qw/id_musico dni nombre apellido telefono_fijo telefono_celular fecha_alta id_complejo/],
		from   => ' FROM musicos ',
		@_
	);

	require Colection;
	my $colection = Colection->new(
		page_number => $hash->{page_number},
		total_records => $hash->{total_records},
	);

	foreach my $row ( @{$hash->{result_set}} ) {
		my $musico = Musico->new(
			id_musico 			=> $row->[0],
	    	dni 				=> $row->[1],
	    	nombre 				=> $row->[2],
	    	apellido 			=> $row->[3],
	    	telefono_fijo 		=> $row->[4],
	    	telefono_celular 	=> $row->[5],
	    	fecha_alta 			=> $row->[6],
	    	id_complejo			=> $row->[7],
		);
		$musico->set_state( 'SAVED' );
		$colection->add($musico);
	}

	return $colection;	
}
sub GetOne {
	my $self = shift;
	my $id_musico = shift;
	my $colection = $self->GetAll(
		where => {
			id_musico => [$id_musico],
		},
		limit => 1
	);

	my $row = $colection->[0];
	my $musico = Musico->new(
		id_musico 			=> $row->[0],
    	dni 				=> $row->[1],
    	nombre 				=> $row->[2],
    	apellido 			=> $row->[3],
    	telefono_fijo 		=> $row->[4],
    	telefono_celular 	=> $row->[5],
    	fecha_alta 			=> $row->[6],
    	id_complejo			=> $row->[7],
	);
	$musico->set_state( 'SAVED' );
	return $musico;
}

# Recibe una coleccion de objetos y los inserta en base
sub Insert {
	my $self = shift;
	my $colection = shift;

	$self->{dbh}->prepare(qq|
	    INSERT INTO musicos SET dni, nombre, apellido, telefono_fijo, telefono_celular, fecha_alta, id_complejo
	    VALUES(?,?,?,?,?,NOW(),?)
	|,undef);

	foreach my $object ( @$colection ){
		$self->{dbh}->execute(
			$self->get( qw/dni nombre apellido telefono_fijo telefono_celular id_complejo/ )
		);
		$self->set_state( 'SAVED' );
	}	
}

# Recibe una coleccion de objetos y los actualiza en base
sub Update {
	my $self = shift;
	my $colection = shift;

	$self->{dbh}->prepare(qq|
	    UPDATE musicos SET dni = ?, nombre = ?, apellido = ?, telefono_fijo = ?, telefono_celular = ?, id_complejo = ?
	    WHERE id_musico = ?
	|,undef);

	foreach my $object ( @$colection ){
		$self->{dbh}->execute(
			$self->get( qw/dni nombre apellido telefono_fijo telefono_celular id_musico id_complejo/ )
		);
		$self->set_state( 'SAVED' );
	}
}

# Recibe una coleccion de objetos y los borra de la base
sub Delete {
	my $self = shift;
	my $colection = shift;

	my @ids = map { $_->get( qw/id/ ) } @$colection;
	my $placeholders = join ',', map { '?' } @ids;

	# TODO - validar que existan todos los objetos ?

	$self->{dbh}->do(qq|
	    DELETE FROM musicos
	    WHERE id_musico = IN($placeholders)
	|,undef,@ids);

	map { $self->set_state( 'DELETED' ); } @$colection;
}

1;
