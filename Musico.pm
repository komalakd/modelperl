#!C:\PERL\bin\perl.exe

package Musico;
use base 'Model'; 

use strict;
use Data::Dumper;
use Model;

# Constructor
sub new {
	my $class = shift;
    
    my %data = map { $_ => undef } @{$class->fields()};

    my $self = {
    	id_denomination => 'id_musico',
    	table => 'musicos',
    	data => {
	    	%data,
	    	@_
	    }
    };
    bless $self, $class;
    
    $self->SUPER::new(@_);
    return $self;
}
sub table {
	return 'musicos';
}
sub fields {
	return [qw/
		id_musico
		dni
		nombre
		apellido
		telefono_fijo
		telefono_celular
		fecha_alta
		id_complejo
	/];
}

# Recibe una coleccion de objetos y los inserta en base
sub Insert {
	my $self = shift;
	my $colection = shift;

	# FIXME
	my $sth = Database->new()->prepare(qq|
	    INSERT INTO musicos (dni, nombre, apellido, telefono_fijo, telefono_celular, fecha_alta, id_complejo)
	    VALUES (?,?,?,?,?,NOW(),?)
	|);

	foreach my $object ( @$colection ){
		$sth->execute(
			$object->get( qw/dni nombre apellido telefono_fijo telefono_celular id_complejo/ )
		);
		$object->set_state( 'SAVED' );
	}	

}

# Recibe una coleccion de objetos y los actualiza en base
sub Update {
	my $self = shift;
	my $colection = shift;

	my $sth = Database->new()->prepare(qq|
	    UPDATE musicos SET dni = ?, nombre = ?, apellido = ?, telefono_fijo = ?, telefono_celular = ?, id_complejo = ?
	    WHERE id_musico = ?
	|,undef);

	foreach my $object ( @$colection ){
		$sth->execute(
			$self->get( qw/dni nombre apellido telefono_fijo telefono_celular id_musico id_complejo/ )
		);
		$self->set_state( 'SAVED' );
	}
}

# Recibe una coleccion de objetos y los borra de la base
sub Delete {
	my $self = shift;
	my $colection = shift;
	
	return unless @$colection;

	my @ids = map { $_->get( qw/id_musico/ ) } @$colection;
	my $placeholders = join ',', map { '?' } @ids;

	# TODO - validar que existan todos los objetos ?
	Database->new()->do(qq|
	    DELETE FROM musicos
	    WHERE id_musico = IN($placeholders)
	|,undef,@ids);

	map { $self->set_state( 'DELETED' ); } @$colection;
}

1;
