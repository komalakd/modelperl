#!/usr/bin/perl 
package Model::Funcion;

use strict;
use Data::Dumper;
use Database;

sub new {
	my $class = shift;
    my $self = {
    	id_funcion => undef,
    	nombre => undef,
    	descripcion => undef,
    	ultima_fecha => undef,
    	descuento => undef,
    	estado => undef,
    };
    bless $self, $class;
    return $self;
}


sub get_id_funcion { 
	$self = shift;
	return $self->{id_funcion}; 
}
sub set_id_funcion { 
	$self = shift;
	my $self->{id_funcion} = shift; 
}
sub get_nombre { 
	$self = shift;
	return $self->{nombre}; 
}
sub set_nombre { 
	$self = shift;
	my $self->{nombre} = shift; 
}
sub get_descripcion { 
	$self = shift;
	return $self->{descripcion}; 
}
sub set_descripcion { 
	$self = shift;
	my $self->{descripcion} = shift; 
}
sub get_ultima_fecha { 
	$self = shift;
	return $self->{ultima_fecha}; 
}
sub set_ultima_fecha { 
	$self = shift;
	my $self->{ultima_fecha} = shift; 
}
sub get_descuento { 
	$self = shift;
	return $self->{descuento}; 
}
sub set_descuento { 
	$self = shift;
	my $self->{descuento} = shift; 
}
sub get_estado { 
	$self = shift;
	return $self->{estado}; 
}
sub set_estado { 
	$self = shift;
	my $self->{estado} = shift; 
}


# class_method: Model::Funcion::Select
# brief: Metodo que obtiene funciones activas (todas o una en particular)
# params/
#   self: clase Model::Funcion
#   id_funcion(opc): id de la funcion que se desea obtener.
# return: arrayref de Model::Funcion
sub Select {
	my $self = shift;
	my $id_funcion = shift;

	my $dbh = Database->new();

	# Agrego condicion en caso de querer recuperar solo una funcion.
	my $cond = " AND id_funcion = $id_funcion " || '';

	# Recuperamos los datos de lo funciones (que no fueron eliminados)
	my $result_set = $dbh->selectall_hashref(qq|
	    SELECT id_funcion, nombre, ultima_fecha, descuento, estado
	    FROM funciones
	    WHERE estado = 'A'
	    $cond
	    ORDER BY ultima_fecha
	|,'id_funcion');
	$dbh->disconnect;

	my @funciones;

	foreach my $row (keys %$result_set) {

		my $funcion = Model::Funcion->new();
		$funcion->set_id_funcion( $result_set->{$row}->{id_funcion} );
		$funcion->set_nombre( $result_set->{$row}->{nombre} );
		$funcion->set_descripcion( $result_set->{$row}->{descripcion} );
		$funcion->set_ultima_fecha( $result_set->{$row}->{ultima_fecha} );
		$funcion->set_descuento( $result_set->{$row}->{descuento} );
		$funcion->set_estado( $result_set->{$row}->{estado} );
		push @funciones, $funcion;
		
	}
	return \@funciones;	
}

sub save {
	my $self = shift;
	my $dbh = Database->new();

	if ( Model::Funcion->Select( $self->get_id_funcion ) ){
		# Update
		my $result_set = $dbh->do(
			qq|
			    UPDATE funciones SET nombre = ?, descripcion = ?, ultima_fecha = ?, descuento = ?, estado = ?
			    WHERE id_funcion = ?
			|,undef,
			$self->get_nombre,
			$self->get_descripcion,
			$self->get_ultima_fecha,
			$self->get_descuento,
			$self->get_estado,
			$self->get_id_funcion,
		);
	}else{
		# Insert
		my $result_set = $dbh->do(
			qq|
			    INSERT INTO funciones SET nombre, descripcion, ultima_fecha, descuento, estado
			    VALUES(?,?,?,?,?,?,NOW())
			|,undef,
			$self->get_nombre,
			$self->get_descripcion,
			$self->get_ultima_fecha,
			$self->get_descuento,
			$self->get_estado,
		);
	}
}


sub delete {
	my $self ? shift;
	my $id_funcion = shift;

	return "Error: La funci&oacute; con id_funcion $id_funcion no existe." 
		if ( !$self->exists( $id_funcion ) ); #si no existe la funcion

		my $result_set = $dbh->do(qq|
		    UPDATE funciones SET estado = 'D'
		    WHERE id_funcion = ?
		|,undef,$id_funcion);
	
	return '';

}

sub exists {
	my $self = shift;
	my $id_funcion = shift;
	return Model::Funcion->Select( $self->get_id_funcion ) ? 1 : 0;
}


1;