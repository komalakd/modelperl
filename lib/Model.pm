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

    my %data = grep { $class->attr_exists($_) } keys %args;

    my $self = {
        table => $class->table(),
        data  => { %data },
    };
    
    bless $self, $class;

    $self->{dbh} = Database->GetInstance();
    $self->_set_state( 'NEW' );
    $self->set( @_ );

    return $self;
}

sub pk_fields { die 'must implement this annoying method.' }

sub non_pk_fields { die 'must implement this annoying method.' }

sub fields {
    my $class = shift;
    
    my @fields = (
        $class->pk_fields(),
        $class->non_pk_fields(),
    );

    return [@fields];
}

# Recibe un arrayref con los atributos que quieren obetenerse
# Devuelve un array con los atributos del objeto
sub get {
    my $self = shift;
    my @attrs = @_;

    my @values;

    foreach my $attr ( @attrs ){
        if ( $self->attr_exists($attr) ){
            push @values, $self->{data}{$attr};
        }else{
            die "Non-existent attibute: $attr";
        }
    }

    return scalar @values == 1 ? $values[0] : @values;
}

# Recibe un hash de la forma FIELD => VALUE para setear los atributos
sub set {
    my $self = shift;
    my %args = @_;

    foreach my $attr ( keys %args ){
        if ( $self->attr_exists($attr) ){
            $self->_set( $attr, $args{$attr} );
        }else{
            die "Non-existent attibute: $attr";
        }
    }
    
    $self->_set_state( 'MODIFIED' ) if $self->_get_state() ne 'NEW';
}

sub _set {
    my $self = shift;
    my $attr = shift;
    my $value = shift;
    $self->{data}{$attr} = $value;
}

{
    my %cache = ();
    sub attr_exists {
        my $self = shift;
        my $attr = shift;

        return map { $_ => 1 } @{$self->fields()}; # FIXME: cache isn't working

        my %fields = map { $_ => 1 } @{$self->fields()} unless scalar keys $cache{ $self->classname() };

        $cache{ $self->{classname} } = %fields;

        return exists $fields{$attr};
    }
}

sub filter_attrs { # just in case...
    my $self = shift;
    my @attrs = @_;

    return grep { $self->attr_exists($_) } @attrs;
}

sub GetAll {
    my $self = shift;
    my %args = @_;

    require Query;
    
    my $query = Query->new( 
        pk     => [$self->pk_fields()],
        from   => ' FROM ' . $self->table(),
        fields => $self->fields(),
        where  => { %args }, # FIXME: filter params
    );
    
    $query->prepare();

    my $result = $query->execute();

    require Colection;
    my $colection = Colection->new(
        page_number   => $result->{page_number},
        total_records => $result->{total_records},
    );

    foreach my $row ( @{$result->{result_set}} ) {
        my %args = ();
        foreach my $field ( @{ $self->fields() } ) {
            $args{$field} = shift @$row;
        }

        my $instance = $self->new( %args );
        $instance->_set_state('SAVED');
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

    $object->_set_state( 'SAVED' );
    return $object;
}

sub save {
    my $self = shift;
    $self->_before_save();
    $self->_save();
    $self->_after_save();
}

sub _before_save {}

sub _after_save {}

# Inserta, actualiza o borra el objeto en base
sub _save {
    my $self = shift;
    
    die unless $self->validate();

    my $state = $self->_get_state();
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
    $self->_set_state( 'SAVED' );
}

# Recibe una coleccion de objetos
# Separa los objetos dependiendo del atributo state
# Se realiza insert, update y delete para los objetos de las distintas colecciones generadas
sub Save {
    my $class = shift;
    my $colection = shift;

    $_->_before_save foreach @$colection;

    my @invalid = grep { $_->validate() } grep { $_->_get_state() ne 'DELETED' } @$colection;

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

        my $state = $object->_get_state();
        if( $state eq 'NEW' ) {
            push @{ $state_colection->{to_insert} }, $object;
        }elsif ( $state eq 'MODIFIED' ){
            push @{ $state_colection->{to_update} }, $object;
        }elsif ( $state eq 'DELETED' ){
            push @{ $state_colection->{to_delete} }, $object if scalar grep { $object->get( $_ ) } $object->pk_fields();
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

sub _get_state {
    my $self = shift; 
    return $self->{state};
}

sub _set_state {
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

    # set the values foreach primary key
    foreach my $pk ( $self->pk_fields() ) {
        my $pk_last_id = $self->{dbh}->last_insert_id( undef, undef, undef, $pk );
        $self->set( $pk => $pk_last_id );
    }
}

# Actualiza en base un objeto particular
sub update {
    my $self = shift;
    my $table = $self->{table};
    
    # non-primary fields
    my @fields = map { $_ } keys %{ $self->{data} };
    my $fields = join ', ', map { "$_ = ?" } @fields;
    my @bind_values = $self->get( @fields );

    # primary keys
    my @pks = $self->pk_fields();
    my $where = join ' AND ', map { "$_ = ?" } @pks;
    push @bind_values, $self->get( @pks );

    $self->{dbh}->do(qq|
        UPDATE $table 
        SET $fields
        WHERE $where
    |,undef, @bind_values );

    $self->_set_state( 'SAVED' );
}

# Borra en base un objeto particular
sub delete {
    my $self = shift;
    my $table = $self->{table};

    # primary keys
    my @pks = $self->pk_fields();
    my $where = join ' AND ', map { "$_ = ?" } @pks;
    my @bind_values = $self->get( @pks );
    
    $self->{dbh}->do(qq|
        DELETE FROM $table 
        WHERE $where
    |,undef, @bind_values );

    $self->_set_state( 'DELETED' );
}

# TODO
# Verifica que los atributos de un objeto sean consistentes
sub validate {
    my $self = shift;
    return 1 if $self->_get_state() eq 'DELETED';
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
        $object->_set_state( 'SAVED' );
    
        $object->_after_save();
    }   

}

# Recibe una coleccion de objetos y los actualiza en base
sub Update {
    my $self = shift;
    my $colection = shift;

    my $fields = $self->non_pk_fields();
    my $ph_str = join ',', map { ' '.$_.'= ?' } @$fields;

    # primary keys
    my @pks = $self->pk_fields();
    my $where = join ' AND ', map { "$_ = ?" } @pks;

    my $sth = Database->GetInstance()->prepare(qq|
        UPDATE $self->table SET $ph_str
        WHERE $where
    |,undef);

    foreach my $object ( @$colection ){
        $sth->execute( $self->get( $fields ) );
        $self->_set_state( 'SAVED' );
        $object->_after_save();
    }
}

# Recibe una coleccion de objetos y los borra de la base
sub Delete {
    my $self = shift;
    my $colection = shift;
    
    return unless $colection->get_total_records();

    my @item_conditions = ();
    my @bind_values = ();

    foreach my $item (@$colection) {
        push @item_conditions, join( ' AND ', map { "$_ = ?" } $self->pk_fields() );
        push @bind_values, $item->get( $item->pk_fields() );
    }

    my $where = join( ' OR ', map { '$_' } @item_conditions );

    # TODO - validar que existan todos los objetos ?
    Database->GetInstance()->do(qq|
        DELETE FROM $self->table
        WHERE $where
    |,undef,@bind_values);

    foreach my $item ( @$colection ){
        $item->_set_state( 'DELETED' );
        $item->_after_save();
    }

    return $colection;
}

sub get_related {
    my $self = shift;
    my $rel_name = shift;

    my $rel = $self->relations( $rel_name );

    die "Non-existent relation: $rel" unless $rel;

    my $rel_type = $rel->{$rel_name}{type};
    my $rel_model_name = $rel->{$rel_name}{model};
    my $rel_field = $rel->{$rel_name}{trough};
    my $rel_field_value = $self->get( $rel_field );

    die "Non-existent relation type: $rel_type" unless $rel;

    my $relation;

    if( $rel_type eq 'belongs_to'){
        $relation = $rel_model_name->GetOne( $rel_field => [$self->get( $rel_field )] );
    }elsif( $rel_type eq 'has_many'){
        $relation = $rel_model_name->GetAll( $rel_field => [$self->get( $rel_field )] );
    }elsif( $rel_type eq 'has_one'){ # TODO
        $relation = $rel_model_name->GetOne( $rel_field => [$self->get( $rel_field )] );
    }

    return $relation;
}

1;
