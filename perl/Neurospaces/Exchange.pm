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


package Neurospaces::Exchange::Parser;


our $model_container;


sub new
{
    my $package = shift;

    my $options = shift || {};

    if (!$model_container)
    {
	$model_container = Neurospaces->new();

	$model_container->read(undef, [ "Neurospaces::Exchange::Parser", "/usr/local/neurospaces/models/library/utilities/empty_model.ndf", ]);

    }

    my $self
	= {
# 	   model_container => $model_container,
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

    my $result = $model_container->{neurospaces}->NeurospacesQualifyFilename($filename);

    return $result;
}


sub read
{
    my $self = shift;

    my $filename = shift;

    my $options = shift || {};

    $self->{filename} = $filename;

    my $qualified_filename = $self->qualify($filename);

    $self->{qualified_filename} = $qualified_filename;

#     $self->{xml_twig}->parsefile($qualified_filename);

    $self->{xml_simple} = XML::Simple::XMLin($qualified_filename);

    if ($options->{verbose}
	|| $options->{yaml_stdout})
    {
	use YAML;

	print Dump($self->{xml_simple});
    }

    # construct the cell morphology

    if ($self->{xml_simple}->{cells})
    {
	if ($self->{xml_simple}->{cells}->{cell})
	{
	    # construct cell

	    my $xml_cell = $self->{xml_simple}->{cells}->{cell};

	    my $cell = Neurospaces::Components::Cell->new();

	    $cell->set_name($xml_cell->{name});

	    my $result = $model_container->insert($cell);

	    if ($result)
	    {
		die "$0: $result";
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

	    $segment->set_parameter_string("NEUROML_group[0]", $xml_cable->{"meta:group"}->[0] );
	    $segment->set_parameter_string("NEUROML_group[1]", $xml_cable->{"meta:group"}->[1] );

	    # set spatial dimensions

	    $segment->set_parameter_double("DIA", $xml_segment->{"mml:distal"}->{diameter});

	    if ($xml_segment->{"mml:distal"}->{x} == $xml_segment->{"mml:proximal"}->{x}
		and $xml_segment->{"mml:distal"}->{y} == $xml_segment->{"mml:proximal"}->{y}
		and $xml_segment->{"mml:distal"}->{z} == $xml_segment->{"mml:proximal"}->{z})
	    {
		$segment->set_parameter_double("LENGTH", 0);
	    }
	    else
	    {
		die "$0: different xyz for morphologies not supported yet";
	    }

	    # insert the segment into the cell

	    $result = $cell->insert($segment);

	    if ($result)
	    {
		die "$0: $result";
	    }

# 	    use Data::Dumper;

# 	    print Dumper($cell);

	}
    }

    # add the 

    return $model_container;
}


1;


