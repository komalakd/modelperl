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
