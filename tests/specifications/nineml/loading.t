#!/usr/bin/perl -w
#

use strict;


my $test
    = {
       command_definitions => [
			       {
				arguments => [
					      'library/NineML/poissonianSpiker.xml',
					      '--yaml-stdout',
					      '--commands',
					      'export no ndf STDOUT /**',
					     ],
				command => 'bin/neurospaces_exchange',
				command_tests => [
						  {
						   description => 'Does the yamlified XML have the necessary information?',
						   read => 'definition:
  url: http://www.nineml.org/neurons/Poisson.xml
name: E_ext
note:
  text: Poisson input (page 185)
properties:
  random:
    reference: RNG
  rate:
    unit: Hz
    value: 10
',
						  },
						  {
						   description => "Is the exported NDF valid?",
						   read => '
#!neurospacesparse
// -*- NEUROSPACES -*-

NEUROSPACES NDF

IMPORT
END IMPORT

PRIVATE_MODELS
END PRIVATE_MODELS

PUBLIC_MODELS
  FIBER E_ext
  END FIBER
END PUBLIC_MODELS
',
						  },
						 ],
				description => "low-level yaml export of the loaded neuroml",
			       },
			      ],
       description => "loading of nineml files",
       name => 'nineml/loading.t',
      };


return $test;


