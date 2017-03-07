#!C:\PERL\bin\perl.exe

package Query;
use strict;
use Data::Dumper;
use Database;

# Setea los parametros en comun de todos los objetos del Model
sub new {
	my $class = shift;
    my $self = {
    	args => {
    		@_	
    	},
    };
    bless $self, $class;
    
    $self->{dbh} = Database->new();

    return $self;
}


sub prepare {
	my $self = shift;

	my $params;
	my @bind_values;
	
	# fields
	$params->{select} = 'SELECT '. join ', ', map { $_ } @{ $self->{args}{fields} };

	# count
	$params->{count} = "SELECT COUNT($self->{args}{pk})";

	# from
	$params->{from} = $self->{args}{from};

	# where
	my @string_array;
	print Dumper $self->{args};
	my $where = $self->{args}{where};
	foreach my $p ( keys %$where ){
		my @values = @{ $where->{$p}  };
		my $placeholders = join ',', map { '?' } @values;
		my $cond = "$p IN (" . join ',', $placeholders . ") ";
		push @string_array, $cond;
		push @bind_values, @values;
	}
	$params->{where} = ' WHERE ' . join ' AND ', @string_array;
	$params->{binds}{where} = \@bind_values;
	
	# order
	my $order = $self->{args}{order} || $self->{args}{pk};
	# my $order = $self->{args}{order} || $self->{id_denomination}; # FIXME - dejar esta linea!
	$params->{order} = ' ORDER BY ? ';
	$params->{binds}{order} = $order;


	$self->{params} = $params; # FIXME - queda feo!

	# limit
	if ( $self->{args}{page_number} ){ # Paginar solo si me llega el numero de pagina
		
		# die unless $self->{args}{page_number} ~= /\d/; # FIXME
		$self->count_records();
		
		my $page_size = $self->{args}{page_size} || 10; # Hardcore

		my $total_pages = $self->{total_records} / $page_size;

		$self->{page_number} = 1 if ($self->{args}{page_number} > $total_pages);

		my $first = ($self->{page_number} - 1) * $page_size;

		$params->{limit} = " LIMIT ?,?";
		$params->{binds}{limit} = [ $first, $page_size ];

	}

	$self->{params} = $params;

}

# Cuenta la cantidad de registros totales
sub count_records {
	my $self = shift;

	my $query_params = $self->{params};

	# Hacer preconsulta
	$self->{total_records} = $self->{dbh}->selectall_arrayref(qq|
		$query_params->{count}
	    $query_params->{from}
	    $query_params->{where}
	|,undef,@{ $query_params->{binds}{where} })->[0][0];
}

# Hacer consulta
sub execute {
	my $self = shift;

	my $query_params = $self->{params};
	
	$self->{result_set} = $self->{dbh}->selectall_arrayref(qq|
		$query_params->{select}
	    $query_params->{from}
	    $query_params->{where}
	    $query_params->{order}
	    $query_params->{limit}
	|,undef,@{ $query_params->{binds}{where} },
			   $query_params->{binds}{order}  ,
			@{ $query_params->{binds}{limit} } );

	my $retorno;
	$retorno->{result_set}    = $self->{result_set};
	$retorno->{page_number}   = $self->{page_number};
	$retorno->{total_records} = $self->{total_records};

	return $retorno;
}


1;