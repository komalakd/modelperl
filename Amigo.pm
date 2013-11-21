#!/usr/bin/perl 
package Model::Amigo;
use base Model; 

use strict;
use Data::Dumper;
use Database;

# Arma la estructura del objeto a crearse
sub initialize {
	my $class = shift;

    SUPER::initialize();

    my $self = {
    	id_denomination => 'id_amigo', # FIXME
    	id_amigo => undef,
    	dni => undef,
    	nombre => undef,
    	apellido => undef,
    	mail => undef,
    	estado => undef,
    	telefono => undef,
    	fecha_registro => undef,
    };
    bless $self, $class;
    return $self;
}

# Constructor
sub new {
	my $self = shift;
    my $attrs = @_;

    map { 
    	$self->set( $_ => $attrs->{$_} )
    } keys %$attrs;

	$self->{state} = 'NEW';
}

# Metodo que obtiene una coleccion de objetos del mismo tipo
# params/
#   where             -> hashref: CAMPO => \@VALORES
#   group by + having -> string
#   page_size         -> int
#   page_number       -> int
# Devuelve un arrayref de objetos
sub Select {
	my $self = shift;
	my $args = @_;
	
	# FIXME - emprolijar
	my $where = ' WHERE ' . join ' AND ', map { 
		'$_ IN ('. 
			join ',' map { '?' } @{ $args->{where}{$_} } 
		.')' 
	} keys %{ $args->{where} };

	my $order_by = ' ORDER BY ' . ($args->{order_by} || 'id_amigo');

	my $limit = $self->SUPER::Paginar(
		page_number => $args->{page_number},
		page_size   => $args->{page_size},
	);

	my $result_set = $self->{dbh}->selectall_hashref(qq|
	    SELECT id_amigo, dni, nombre, apellido, mail, estado, telefono, fecha_registro 
	    FROM amigos
	    $where
		$order_by	    
	    $limit
	|,'id_amigo',@$ids);

	my @colection = map { sub { 
		$result_set->{$_}{state} = 'SAVED';
		return Model->Amigo->new( $result_set->{$_} ) 
	} } keys %$result_set;
}

# Guarda o actualiza un objeto particular en base
sub save {
	my $self = shift;
	
	die unless $self->validate();

	my $state = $self->get('state');
	if ( $state eq 'SAVED' || $state eq 'MODIFIED'){
		return $self->update();
	} elsif ( $state eq 'NEW' ) {
		return $self->insert();
	} else {
		die "Wrong object state to save: $state";
	}
	$self->{state} = 'SAVED';
}

# Guarda en base un objeto particular
sub insert {
	my $self = shift;
	$self->{dbh}->do(qq|
	    INSERT INTO amigos SET dni, nombre, apellido, mail, estado, telefono, fecha_registro 
	    VALUES(?,?,?,?,?,?,NOW())
	|,undef,$self->get( [qw/ dni nombre apellido mail estado telefono fecha_registro /] ) );
}

# Actualiza en base un objeto particular
sub update {
	$self->{dbh}->do(qq|
	    UPDATE amigos SET dni = ?, nombre = ?, apellido = ?, mail = ?, estado = ?, telefono = ?, fecha_registro = ? 
	    WHERE id_amigo = ?
	|,undef,$self->get( [qw/ dni nombre apellido mail estado telefono fecha_registro /] ) );
}

# Borra en base un objeto particular
sub delete {
	my $self = shift;

	return $self->{dbh}->do(qq|
	    DELETE FROM amigos
	    WHERE id_amigo = ?
	|,undef,$self->get('id_amigo')) if $self->exists();
	$self->{state} = 'DELETED';
}

# Retorna si un objeto particular existe en base.
sub exists {
	my $self = shift;

	return $self->{dbh}->selectall_arrayref(q|
	    SELECT COUNT(id_amigo)
	    FROM amigos
	    WHRE id_amigo = ?
	    LIMIT 1
	|,undef,$self->get('id_amigo'))->[0][0];
}

# TODO
# Verifica que los atributos de un objeto sean consistentes
sub validate {
	my $self = shift;
	my $object = shift;
	return 1 if $object->{state} eq 'DELETED';
	return 1; # FIXME - retorna solo valido
}

# Recibe una coleccion de objetos del mismo tipo y realiza acciones en base segun el estado del objeto
sub Save {
	my $self = shift;
	my $colection = shift;

	my @invalid = grep { $_->validate() } grep { $_->get('state') ne 'DELETED' } @$colection;

	return {
		message => 'Error validating the object Amigo',
		error => 1,
		invalid => \@invalid,
	} if @$invalid;

	my colection = $self->SUPER::Save( colection );

	return return {
		message => 'The object has been saved correctly',
	};

}
# Recibe una coleccion de objetos y los inserta en base
sub Insert {
	my $self = shift;
	my $colection = shift;

	$self->{dbh}->prepare(qq|
	    INSERT INTO amigos SET dni, nombre, apellido, mail, estado, telefono, fecha_registro 
	    VALUES(?,?,?,?,?,?,NOW())
	|,undef);

	foreach my $object ( @$colection ){
		$self->{dbh}->execute(
			$self->get( [qw/ dni nombre apellido mail estado telefono fecha_registro /])
		);
		$self->{state} = 'SAVED';
	}	
}

# Recibe una coleccion de objetos y los actualiza en base
sub Update {
	$self->{dbh}->prepare(qq|
	    UPDATE amigos SET dni = ?, nombre = ?, apellido = ?, mail = ?, estado = ?, telefono = ?, fecha_registro = ? 
	    WHERE id_amigo = ?
	|,undef);

	foreach my $object ( @$colection ){
		$self->{dbh}->execute(
			$self->get( [qw/ dni nombre apellido mail estado telefono fecha_registro id_amigo /] )
		);
		$self->{state} = 'SAVED';
	}
}

# Recibe una coleccion de objetos y los borra de la base
sub Delete {
	my $self = shift;
	my $colection = shift;

	my @ids = map { $_->get('id') } @$colection;
	my $placeholders = join ',', map { '?' } @$ids;

	# TODO - validar que existan todos los objetos ?

	$self->{dbh}->do(qq|
	    DELETE FROM amigos
	    WHERE id_amigo = IN($placeholders)
	|,undef,@$ids);

	return map { $self->{state} = 'DELETED' } @$colection;
}

1;
