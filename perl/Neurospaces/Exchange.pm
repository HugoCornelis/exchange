#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#

use strict;


use Neurospaces;
use Neurospaces::Components;

use XML::Simple;
# use XML::Twig;


package Neurospaces::Exchange;


sub version
{
    # $Format: "    my $version = \"${package}-${label}\";"$
    my $version = "exchange-alpha";

    return $version;
}


package Neurospaces::Exchange::NeuroML;


sub convert
{
    my $self = shift;

    my $options = shift;

    # construct the cell morphology

    if ($self->{xml_simple}->{cells})
    {
	if ($self->{xml_simple}->{cells}->{cell})
	{
	    # construct cell

	    my $xml_cell = $self->{xml_simple}->{cells}->{cell};

	    my $cell = Neurospaces::Components::Cell->new();

	    $cell->set_name($xml_cell->{name});

	    my $result = $self->{model_container}->insert_public($cell);

	    if ($result)
	    {
		return $result;
	    }

	    # get cable cache

	    my $xml_cable = $xml_cell->{"mml:cables"}->{"mml:cable"};

	    # construct segment

	    my $xml_segment = $xml_cell->{"mml:segments"}->{"mml:segment"};

	    my $segment = Neurospaces::Components::Segment->new();

	    $segment->set_name($xml_segment->{name});

	    # set cable ID

	    $segment->set_parameter_string("NEUROML_cable", $xml_segment->{cable});

	    # add biophysics group name to the segment

	    my $meta_groups = $xml_cable->{"meta:group"};

	    my $meta_group_index = {};

	    foreach my $meta_group_count (0 .. $#$meta_groups)
	    {
		$segment->set_parameter_string("NEUROML_group[$meta_group_count]", $xml_cable->{"meta:group"}->[$meta_group_count] );

		# maintain group indices

		if (not defined $meta_group_index->{$xml_cable->{"meta:group"}->[$meta_group_count]})
		{
		    $meta_group_index->{$xml_cable->{"meta:group"}->[$meta_group_count]} = [];
		}

		push @{$meta_group_index->{$xml_cable->{"meta:group"}->[$meta_group_count]}}, $segment;
	    }

	    # set spatial dimensions

	    my $diameter = ($xml_segment->{"mml:distal"}->{diameter} + $xml_segment->{"mml:proximal"}->{diameter}) / 2;

	    if ($diameter > 1)
	    {
		$diameter *= 1e-6;
	    }

	    $segment->set_parameter_double("DIA", $diameter);

	    if ($xml_segment->{"mml:distal"}->{x} == $xml_segment->{"mml:proximal"}->{x}
		and $xml_segment->{"mml:distal"}->{y} == $xml_segment->{"mml:proximal"}->{y}
		and $xml_segment->{"mml:distal"}->{z} == $xml_segment->{"mml:proximal"}->{z})
	    {
		$segment->set_parameter_double("LENGTH", 0);
	    }
	    else
	    {
		return "different xyz for morphologies not supported yet";
	    }

	    # insert the segment into the cell

	    $result = $cell->insert($segment);

	    if ($result)
	    {
		return $result;
	    }

	    # access biophysics properties

	    my $biophysics = $xml_cell->{biophysics};

	    # distribute initial membrane potential

	    my $Vm_init_group = $biophysics->{"bio:init_memb_potential"}->{"bio:parameter"}->{"bio:group"};

	    my $Vm_init = $biophysics->{"bio:init_memb_potential"}->{"bio:parameter"}->{"value"};

	    if ($biophysics->{units} eq 'Physiological Units')
	    {
		$Vm_init *= 1e-3;
	    }

	    foreach my $segment ( @{ $meta_group_index->{$Vm_init_group}} )
	    {
		$segment->set_parameter_double("Vm_init", $Vm_init);
	    }

	    # distribute axial resistance

	    my $axial_resistance_group = $biophysics->{"bio:spec_axial_resistance"}->{"bio:parameter"}->{"bio:group"};

	    my $axial_resistance = $biophysics->{"bio:spec_axial_resistance"}->{"bio:parameter"}->{"value"};

	    if ($biophysics->{units} eq 'Physiological Units')
	    {
		# ohm cm to ohm meter

		$axial_resistance *= 1e-2;
	    }

	    foreach my $segment ( @{ $meta_group_index->{$axial_resistance_group}} )
	    {
		$segment->set_parameter_double("RA", $axial_resistance);
	    }

	    # distribute specific capacitance

	    my $specific_capacitance_group = $biophysics->{"bio:spec_capacitance"}->{"bio:parameter"}->{"bio:group"};

	    my $specific_capacitance = $biophysics->{"bio:spec_capacitance"}->{"bio:parameter"}->{"value"};

	    if ($biophysics->{units} eq 'Physiological Units')
	    {
		# microF / cm^2 to F / m^2

		$specific_capacitance *= 1e-2;
	    }

	    foreach my $segment ( @{ $meta_group_index->{$specific_capacitance_group}} )
	    {
		$segment->set_parameter_double("CM", $specific_capacitance);
	    }

	    # distribute leak conductance properties

	    my $leak_group = $biophysics->{"bio:mechanism"}->{"GranPassiveCond"}->{"bio:parameter"}->{"gmax"}->{"bio:group"};

	    my $leak = $biophysics->{"bio:mechanism"}->{"GranPassiveCond"}->{"bio:parameter"}->{"gmax"}->{"value"};

	    if ($biophysics->{units} eq 'Physiological Units')
	    {
		#t kilo ohm cm^2 to ohm m^2

# 		$specific_capacitance *= 1e-1;
	    }

	    foreach my $segment ( @{ $meta_group_index->{$leak_group}} )
	    {
		$segment->set_parameter_double("RM", $leak);
	    }

 	    use Data::Dumper;

 	    print Dumper($meta_group_index);

	}
    }

    # return result: error message

    return undef;
}


package Neurospaces::Exchange::NineML;


sub convert
{
    my $self = shift;

    my $options = shift;

    my $element_mapping
	= {
# 	   'http://www.nineml.org/neurons/IaF_tau.xml' => {
# 							   package => 'Neurospaces::Components::Segment::IaF_tau',
# 							   properties => {
# 									  membraneConstant => 'TAU',
# 									 },
# 							  },
	   'http://www.nineml.org/neurons/Poisson.xml' => {
							   package => 'Neurospaces::Components::Fiber',
							   properties => {
									  rate => 'RATE',
									 },
							  },
	   'http://www.nineml.org/tools/random.xml' => {
							package => 'Neurospaces::Components::Randomvalue',
							properties => {
								       seed => 'RANDOMSEED',
								      },
						       },
	  };

    if ($self->{xml_simple}->{import}->{url})
    {
	my $urls
	    = (
	       $self->{xml_simple}->{import}->{url} =~ /ARRAY/
	       ? $self->{xml_simple}->{import}->{url}
	       : [ $self->{xml_simple}->{import}->{url}, ],
	      );

	foreach my $url (@$urls)
	{
	    my $parser_url = Neurospaces::Exchange::Parser->new( { model_container => $self->{model_container}, }, );

	    my $parser_url_error = $parser_url->read($url);

	    if ($parser_url_error)
	    {
		if ($url =~ s(^file://./)(NineML/))
		{
		    $parser_url_error = $parser_url->read($url);
		}
	    }

	    if ($parser_url_error)
	    {
		return "cannot parse url $url ($parser_url_error)";
	    }
	}
    }

    if ($self->{xml_simple}->{node})
    {
	# note that the yaml contains nodes converted to a hash by their name

	my $nodes = $self->{xml_simple}->{node};

	my $node_count = scalar keys %$nodes;

	foreach my $node_name (sort keys %$nodes)
	{
	    my $node = $nodes->{$node_name};

	    print "$node_name\n";

	    # if it is a reference

	    if ($node->{reference})
	    {
		if (not $nodes->{$node->{reference}}->{done})
		{
		    $self->convert_node($nodes->{$node->{reference}}, $nodes->{$node->{reference}});
		}
	    }

	    $self->convert_node($node_name, $node);
	}
    }

    if ($self->{xml_simple}->{definition}->{url} eq 'http://www.nineml.org/neurons/Poisson.xml')
    {
	my $fiber = Neurospaces::Components::Fiber->new();

	$fiber->set_name($self->{xml_simple}->{name});

	my $result = $self->{model_container}->insert_public($fiber);

	if ($result)
	{
	    return $result;
	}

	# set parameters of the fiber

	$fiber->set_parameter_double("RATE", $self->{xml_simple}->{properties}->{rate}->{value});

	# attach the random number generator

	my $parser_random = Neurospaces::Exchange::Parser->new( { model_container => $self->{model_container}, }, );

	if ($self->{xml_simple}->{properties}->{random}->{reference})
	{
	    my $reference = $self->{xml_simple}->{properties}->{random}->{reference};

	    my $parser_random_error = $parser_random->read($reference);

	    if ($parser_random_error)
	    {
		return "cannot parse random number generator ($parser_random_error)";
	    }

	    # insert the randomvalue as a private model

	    my $randomvalue = Neurospaces::Components::Randomvalue->new();

	    $randomvalue->set_name($reference);

	    $randomvalue->set_parameter_double("RANDOMSEED", $parser_random->{xml_simple}->{properties}->{seed});

	    my $result_insert_private = $self->{model_container}->insert_private($randomvalue);

	    if ($result_insert_private)
	    {
		return $result_insert_private;
	    }

	    # and link it with the spike generator

	    my $result_alias = $randomvalue->alias(undef, $reference, "randomvalue", "Neurospaces::Components::Randomvalue");

	    if (! ref $result_alias)
	    {
		return $result_alias;
	    }

	    my $result_child = $fiber->insert($result_alias);

	    if ($result_child)
	    {
		return $result_child;
	    }
	}
	else
	{
	    return "random element without a reference in $self->{xml_simple}->{name}";
	}
    }

    # return result: error message

    return undef;
}


sub convert_node
{
    my $self = shift;

    my $node_name = shift;

    my $node = shift;

    # obtain a reference to the nodes definition through following the references

    my $definition = $node->{definition};

    if ($node->{definition}->{url} eq 'http://www.nineml.org/PSRs/Delta.xml')
    {
		
    }

    if ($self->{definition}->{url} eq 'http://www.nineml.org/neurons/Poisson.xml')
    {
	my $fiber = Neurospaces::Components::Fiber->new();

	$fiber->set_name($self->{xml_simple}->{name});

	my $result = $self->{model_container}->insert_public($fiber);

	if ($result)
	{
	    return $result;
	}

	# set parameters of the fiber

	$fiber->set_parameter_double("RATE", $self->{xml_simple}->{properties}->{rate}->{value});

	# attach the random number generator

	my $parser_random = Neurospaces::Exchange::Parser->new( { model_container => $self->{model_container}, }, );

	if ($self->{xml_simple}->{properties}->{random}->{reference})
	{
	    my $reference = $self->{xml_simple}->{properties}->{random}->{reference};

	    my $parser_random_error = $parser_random->read($reference);

	    if ($parser_random_error)
	    {
		return "cannot parse random number generator ($parser_random_error)";
	    }

	    # insert the randomvalue as a private model

	    my $randomvalue = Neurospaces::Components::Randomvalue->new();

	    $randomvalue->set_name($reference);

	    $randomvalue->set_parameter_double("RANDOMSEED", $parser_random->{xml_simple}->{properties}->{seed});

	    my $result_insert_private = $self->{model_container}->insert_private($randomvalue);

	    if ($result_insert_private)
	    {
		return $result_insert_private;
	    }

	    # and link it with the spike generator

	    my $result_alias = $randomvalue->alias(undef, $reference, "randomvalue", "Neurospaces::Components::Randomvalue");

	    if (! ref $result_alias)
	    {
		return $result_alias;
	    }

	    my $result_child = $fiber->insert($result_alias);

	    if ($result_child)
	    {
		return $result_child;
	    }
	}
	else
	{
	    return "random element without a reference in $self->{xml_simple}->{name}";
	}
    }

    # flag this node as processed

    $node->{done} = 1;
}


package Neurospaces::Exchange::Parser;


sub is_neuroml
{
    my $self = shift;

    return (defined $self->{xml_simple}->{"xsi:schemaLocation"}) and ($self->{xml_simple}->{"xsi:schemaLocation"} =~ /neuroml/i);
}


sub new
{
    my $package = shift;

    my $options = shift || {};

    my $model_container = $options->{model_container};

    if (!$model_container)
    {
	$model_container = Neurospaces->new();

	$model_container->read(undef, [ "Neurospaces::Exchange::Parser", "/usr/local/neurospaces/models/library/utilities/empty_model.ndf", ]);

    }

    my $self
	= {
	   model_container => $model_container,
# 	   xml_twig => XML::Twig->new();
	   %$options,
	  };

    bless $self, $package;

    return $self;
}


sub qualify
{
    my $self = shift;

    my $filename = shift;

    my $result = $self->{model_container}->{neurospaces}->NeurospacesQualifyFilename($filename);

    return $result;
}


sub read
{
    my $self = shift;

    my $filename = shift;

    my $options = shift || {};

    if ($filename !~ /\.xml$/)
    {
	$filename .= ".xml";
    }

    my $qualified_filename = $self->qualify($filename);

    if (!$qualified_filename)
    {
	return "cannot qualify $filename (not found?)";
    }

    push @{$self->{filename}}, $filename;

    push @{$self->{qualified_filename}}, $qualified_filename;

#     $self->{xml_twig}->parsefile($qualified_filename);

#     eval
    {
	$self->{xml_simple} = XML::Simple::XMLin($qualified_filename);
    };

    if ($options->{verbose}
	|| $options->{yaml_stdout})
    {
	use YAML;

	print Dump($self->{xml_simple});
    }

    if ($self->is_neuroml())
    {
	bless $self, "Neurospaces::Exchange::NeuroML";
    }
    else
    {
	bless $self, "Neurospaces::Exchange::NineML";
    }

    return $self->convert($options);
}


1;


