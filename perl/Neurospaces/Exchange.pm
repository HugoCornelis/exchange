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
    my $version = "exchange-prealpha-1";

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

	my $parser_random_error = $parser_random->read($self->{xml_simple}->{properties}->{random}->{reference});

	if ($parser_random_error)
	{
	    return "cannot parse random number generator ($parser_random_error)";
	}

	my $randomvalue = Neurospaces::Components::Randomvalue->new();

	$randomvalue->set_name($self->{xml_simple}->{properties}->{random}->{reference});

	#t figure out why the randomvalue was needed

	$result = $fiber->insert($randomvalue);

	if ($result)
	{
	    return $result;
	}

    }

    # return result: error message

    return undef;
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


