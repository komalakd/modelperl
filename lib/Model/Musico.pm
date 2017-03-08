package Model::Musico;

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

1;
