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
    reference: NineML/RNG
  rate:
    unit: Hz
    value: 10
',
						  },
						  {
						   description => "Is the exported NDF valid?",
						   read => '#!neurospacesparse
// -*- NEUROSPACES -*-

NEUROSPACES NDF

IMPORT
END IMPORT

PRIVATE_MODELS
  RANDOMVALUE "NineML/RNG"
    PARAMETERS
      PARAMETER ( RANDOMSEED = 452145 ),
    END PARAMETERS
  END RANDOMVALUE
END PRIVATE_MODELS

PUBLIC_MODELS
  FIBER "E_ext"
    PARAMETERS
      PARAMETER ( RATE = 10 ),
    END PARAMETERS
    CHILD "NineML/RNG" "NineML/RNG"
    END CHILD
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


