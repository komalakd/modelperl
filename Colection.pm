#!C:\PERL\bin\perl.exe

package Colection;
use strict;
use Data::Dumper;

# Setea los parametros en comun de todos los objetos del Model
sub new {
	my $class = shift;
	my $args = {
		@_
	};
    my $self = {
    	items => [],
    	page_number => $args->{page_number} || undef,
    	total_records => $args->{total_records} || undef,
    };
    bless $self, $class;

    return $self;
}


sub get_items {
	my $self = shift;
	return $self->{items};
}

sub set_items {
	my $self = shift;
	my $items = shift;
	$self->{items} = $items;
}

sub get_page_number {
	my $self = shift;
	return $self->{page_number};
}

sub get_total_records {
	my $self = shift;
	return $self->{total_records};
}

sub set_page_number {
	my $self = shift;
	$self->{page_number} = shift;
}

sub set_total_records {
	my $self = shift;
	$self->{total_records} = shift;
}


sub add {
	my $self = shift;
	my $item = shift;
	push @{$self->{items}}, $item;
}

sub remove {
	my $self = shift;
	my $item = shift;
	# NOT IMPLEMENTED
	# my $id = $item->get('id');
}

sub size {
	my $self = shift;
	return scalar @{$self->{items}};
}

sub collect {
	my $self = shift;
	my $fields = shift;
	my $items = $self->get_items();

	my $retorno;
	foreach my $i ( @$items ){
		my $hash;
		foreach my $f ( @$fields ){
			$hash->{f} = $i->get( $f );
		}
		push @{$retorno}, $hash;
	}

	return $retorno;
}

1;