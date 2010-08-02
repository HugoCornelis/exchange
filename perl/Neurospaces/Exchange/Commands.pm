#!/usr/bin/perl -w
#!/usr/bin/perl -w -d:ptkdb
#

package Neurospaces::Exchange::Commands;


use strict;


use Neurospaces::Exchange;


our $g3_commands
    = [
       'neuroml_load',
       'neuroml_load_help',
       'nineml_load',
       'nineml_load_help',
      ];



sub neuroml_load
{
    my $filename = shift;

    my $parser = Neurospaces::Exchange::Parser->new( { model_container => $GENESIS3::model_container, }, );

    my $parse_error = $parser->read($filename, { verbose => $GENESIS3::verbose_level, yaml_stdout => ( $GENESIS3::verbose_level eq '2' ) , }, );

    if ($parse_error)
    {
	die "$0: parsing of $filename failed ($parse_error)";
    }

}



sub neuroml_load_help
{
    print "description: load a neuroml / nineml model description file.\n";

    print "synopsis: neuroml_load <filename>\n";

    return "*** Ok";
}


sub nineml_load
{
    return neuroml_load();
}



sub nineml_load_help
{
    print "description: load a neuroml / nineml model description file.\n";

    print "synopsis: nineml_load <filename>\n";

    return "*** Ok";
}


1;


