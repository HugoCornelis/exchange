#!/usr/bin/perl -w
#!/usr/bin/perl -d:ptkdb -w
#

use strict;


use Neurospaces;
use Neurospaces::Components;

use XML::Simple;
# use XML::Twig;


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

    if ($options->{verbose})
    {
	use YAML;

	print Dump($self->{xml_simple});
    }

    if ($self->{xml_simple}->{cells})
    {
	if ($self->{xml_simple}->{cells}->{cell})
	{
# 	    print "exchanging cells\n";

	    my $xml_cell = $self->{xml_simple}->{cells}->{cell};

	    my $xml_segment = $xml_cell->{"mml:segments"}->{"mml:segment"};

	    my $cell = Neurospaces::Components::Cell->new();

	    $cell->set_name($xml_cell->{name});

	    my $result = $model_container->insert($cell);

	    if ($result)
	    {
		die "$0: $result";
	    }

	    my $segment = Neurospaces::Components::Segment->new();

	    $segment->set_name($xml_segment->{name});

# 	    use Data::Dumper;

# 	    print Dumper($cell);

	}
    }

    return $model_container;
}


sub qualify
{
    my $self = shift;

    my $filename = shift;

    my $result = $model_container->{neurospaces}->NeurospacesQualifyFilename($filename);

    return $result;
}


1;


