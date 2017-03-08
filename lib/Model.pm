package Model;

use strict;
use Data::Dumper;
use Database;

# Estados posibles que puede adoptar un objeto del Model
my $states = [qw/
    NEW
    SAVED
    MODIFIED
    DELETED
/];

# Setea los parametros en comun de todos los objetos del Model
sub new {
    my $class = shift;
    my %args = @_;

    my %fields = map { $_ => 1 } @{$class->fields()};
    
    my %data = grep { exists $fields{$_} } keys %args;

    my $self = {
        id_denomination => $class->pk(),
        table => $class->table(),
        data  => { %data }
    };
    
    bless $self, $class;

    $self->{dbh} = Database->GetInstance();
    $self->set_state( 'NEW' );
    $self->set( @_ );

    return $self;
}

# Recibe un arrayref con los atributos que quieren obetenerse
# Devuelve un array con los atributos del objeto
sub get {
    my $self = shift;
    my @attrs = @_;

    my @values;
    foreach my $att ( @attrs ){
        if ( exists $self->{data}{$att} ){
            push @values, $self->{data}{$att};
        }else{
            die "Non-existent attibute: $att";
        }
    }

    return scalar @values == 1 ? $values[0] : @values;
}

# Recibe un hash de la forma FIELD => VALUE para setear los atributos
sub set {
    my $self = shift;
    my $args = {
        @_
    };

    my %fields = map { $_ => 1 } @{$self->fields()};

    foreach my $att ( keys %$args ){
        if ( exists $fields{$att} ){
            $self->{data}{$att} = $args->{$att};
        }else{
            die "Non-existent attibute: $att";
        }
    }
    
    $self->set_state( 'MODIFIED' ) if $self->get_state() ne 'NEW';
}

sub GetAll {
    my $self = shift;
    
    require Query;
    
    my $query = Query->new( 
        pk     => $self->pk(),
        from   => ' FROM ' . $self->table(),
        fields => $self->fields(),
        @_ # FIXME: filter params
    );
    $query->prepare();

    my $result = $query->execute();

    require Colection;
    my $colection = Colection->new(
        page_number => $result->{page_number},
        total_records => $result->{total_records},
    );

    foreach my $row ( @{$result->{result_set}} ) {
        my %args = ();
        foreach my $field ( @{ $self->fields() } ) {
            $args{$field} = shift @$row;
        }

        my $instance = $self->new( %args );
        $instance->set_state('SAVED');
        $colection->add($instance);
    }

    return $colection;
}

sub GetOne {
    my $class = shift;
    my %args = @_;

    my $colection = $class->GetAll(
        where => {
            %args
        },
        limit => 1
    );  

    my $object = $colection->first;

    return undef unless $object;

    $object->set_state( 'SAVED' );
    return $object;
}

# Inserta, actualiza o borra el objeto en base
sub save {
    my $self = shift;
    
    die unless $self->validate();

    my $state = $self->get_state();
    if ( $state eq 'NEW'){
        return $self->insert();
    } elsif ( $state eq 'MODIFIED' ) {
        $self->update();
    } elsif ( $state eq 'DELETED' ) {
        $self->delete();
    } elsif ( $state eq 'SAVED' ) {
        # Do nothing..!
    } else {
        die "Non-existent object state: $state";
    }
    $self->set_state( 'SAVED' );
}

# Recibe una coleccion de objetos
# Separa los objetos dependiendo del atributo state
# Se realiza insert, update y delete para los objetos de las distintas colecciones generadas
sub Save {
    my $class = shift;
    my $colection = shift;

    my @invalid = grep { $_->validate() } grep { $_->get_state() ne 'DELETED' } @$colection;

    return {
        error   => 1,
        invalid => \@invalid,
    } if @invalid;
    
    my $state_colection = {
        to_insert => [],
        to_update => [],
        to_delete => [],
    };
    
    foreach my $object ( @$colection ){

        my $state = $object->get_state();
        if( $state eq 'NEW' ) {
            push @{ $state_colection->{to_insert} }, $object;
        }elsif ( $state eq 'MODIFIED' ){
            push @{ $state_colection->{to_update} }, $object;
        }elsif ( $state eq 'DELETED' ){
            push @{ $state_colection->{to_delete} }, $object if $object->get( $object->pk() );
        }elsif ( $state eq 'SAVED' ){
            # relax
        }else{
            die "Unknown state: $state";
        }
    }

    $class->Insert( $state_colection->{to_insert} );
    $class->Update( $state_colection->{to_update} );
    $class->Delete( $state_colection->{to_delete} );

    return {
        inserted => $state_colection->{to_insert},
        updated  => $state_colection->{to_update},
        deleted  => $state_colection->{to_delete},
    };
}

sub get_state {
    my $self = shift; 
    return $self->{state};
}

sub set_state {
    my $self = shift; 
    $self->{state} = shift;
}

# Guarda en base un objeto particular
sub insert {
    my $self = shift;
    my $table = $self->{table};
    my %data = %{ $self->{data} };
    my @fields = map { $_ } keys %data;
    my $fields = join ', ', @fields;
    my $placeholders = join ',', map { '?' } @fields;
    my @bind_values = $self->get( @fields );
    
    $self->{dbh}->do(qq|
        INSERT INTO $table ($fields)
        VALUES ($placeholders)
    |,undef, @bind_values );

    my $id = $self->{dbh}->last_insert_id( undef, undef, undef, undef );

    $self->set( $self->pk() => $id );
}

# Actualiza en base un objeto particular
sub update {
    my $self = shift;
    my $table = $self->{table};
    my @fields = map { $_ } keys %{ $self->{data} };
    my $fields = join ', ', map { "$_ = ?" } @fields;
    my @bind_values = $self->get( @fields );

    $self->{dbh}->do(qq|
        UPDATE $table 
        SET $fields
        WHERE $self->{id_denomination} = ?
    |,undef, @bind_values, $self->get( $self->{id_denomination} ) );

    $self->set_state( 'SAVED' );
}

# Borra en base un objeto particular
sub delete {
    my $self = shift;
    my $table = $self->{table};
    my $id_denomination = $self->{id_denomination};
    my $id = $self->get( ($id_denomination) );
    
    $self->{dbh}->do(qq|
        DELETE FROM $table 
        WHERE $id_denomination = ?
    |,undef, $id );

    $self->set_state( 'DELETED' );
}

# Retorna si un objeto particular existe en base.
sub exists {
    my $self = shift;
    my $table = $self->{table};
    my $id_denomination = $self->{id_denomination};
    my $bind_value = $self->get( ($id_denomination) );
    
    return $self->{dbh}->selectall_arrayref(qq|
        SELECT COUNT(*) 
        FROM $table 
        WHERE $id_denomination = ? 
        LIMIT 1
    |,undef, $bind_value )->[0][0];
}

# TODO
# Verifica que los atributos de un objeto sean consistentes
sub validate {
    my $self = shift;
    return 1 if $self->get_state() eq 'DELETED';
    return 1; # FIXME - retorna solo valido
}

# Recibe una coleccion de objetos y los inserta en base
sub Insert {
    my $self = shift;
    my $colection = shift;

    my $fields = $self->fields();
    my $fields_str = join ',', @$fields;
    my $ph_str = join ',', map { '?' } @$fields;

    my $sth = Database->GetInstance()->prepare(qq|
        INSERT INTO $self->table ($fields_str)
        VALUES ($ph_str)
    |);

    foreach my $object ( @$colection ){
        $sth->execute(
            $object->get( $fields )
        );
        $object->set_state( 'SAVED' );
    }   

}

# Recibe una coleccion de objetos y los actualiza en base
sub Update {
    my $self = shift;
    my $colection = shift;

    my $fields = $self->fields();
    my $fields_str = join ',', @$fields;
    my $ph_str = join ',', map { ' '.$_.'= ?' } @$fields;

    my $pk = shift @$fields;

    my $sth = Database->GetInstance()->prepare(qq|
        UPDATE $self->table SET $ph_str
        WHERE $pk = ?
    |,undef);

    foreach my $object ( @$colection ){
        $sth->execute(
            $self->get( $fields )
        );
        $self->set_state( 'SAVED' );
    }
}

# Recibe una coleccion de objetos y los borra de la base
sub Delete {
    my $self = shift;
    my $colection = shift;
    
    return unless @$colection;

    my $fields = $self->fields();
    my $pk = shift @$fields;

    my @ids = map { $_->get( $pk ) } @$colection;
    my $placeholders = join ',', map { '?' } @ids;

    # TODO - validar que existan todos los objetos ?
    Database->GetInstance()->do(qq|
        DELETE FROM $self->table
        WHERE $pk = IN($placeholders)
    |,undef,@ids);

    map { $self->set_state( 'DELETED' ); } @$colection;

    return $colection;
}

sub pk {
    my $self = shift;
    return shift @{$self->fields()};
}

1;