#!/usr/bin/perl -w
#

use strict;


my $test
    = {
       command_definitions => [
			       {
				arguments => [
					      'library/NeuroML/GranuleCell/Granule_98.morph.xml',
					      '--yaml-stdout',
					      '--commands',
					      'export no ndf STDOUT /**',
					     ],
				command => 'bin/neurospaces_exchange',
				command_tests => [
						  {
						   description => 'Does the yamlified XML have the necessary information?',
						   read => 'cells:
  cell:
    biophysics:
      bio:init_memb_potential:
        bio:parameter:
          bio:group: all
          value: -65.0
      bio:mechanism:
        GranPassiveCond:
          bio:parameter:
            e:
              bio:group: all
              value: -65.0
            gmax:
              bio:group: all
              value: 0.0330033
          passive_conductance: true
          type: Channel Mechanism
        Gran_CaHVA_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 0.9084216
          type: Channel Mechanism
        Gran_CaPool_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 5.18213E-7
          type: Channel Mechanism
        Gran_H_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 0.03090506
          type: Channel Mechanism
        Gran_KA_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 1.14567
          type: Channel Mechanism
        Gran_KCa_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 17.9811
          type: Channel Mechanism
        Gran_KDr_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 8.89691
          type: Channel Mechanism
        Gran_NaF_98:
          bio:parameter:
            bio:group: all
            name: gmax
            value: 55.7227
          type: Channel Mechanism
      bio:spec_axial_resistance:
        bio:parameter:
          bio:group: all
          value: 0.1
      bio:spec_capacitance:
        bio:parameter:
          bio:group: all
          value: 1.0
      units: Physiological Units
    connectivity:
      net:potential_syn_loc:
        - net:group: all
          synapse_type: NMDA
        - net:group: all
          synapse_type: MF_AMPA
        - net:group: all
          synapse_type: AMPA_GranGol
        - net:group: all
          synapse_type: GABAA
    meta:notes: \'An implementation using ChannelML of the Granule cell mode from Maex, R and De Schutter, E. Synchronization of Golgi and Granule Cell Firing in a Detailed Network Model of the Cerebellar Granule Cell Layer, 1998\'
    mml:cables:
      mml:cable:
        id: 0
        meta:group:
          - all
          - soma_group
        name: Soma
    mml:segments:
      mml:segment:
        cable: 0
        id: 0
        mml:distal:
          diameter: 10.0
          x: 0.0
          y: 0.0
          z: 0.0
        mml:proximal:
          diameter: 10.0
          x: 0.0
          y: 0.0
          z: 0.0
        name: Soma
    name: Granule_98
lengthUnits: micron
xmlns: http://morphml.org/neuroml/schema
xmlns:bio: http://morphml.org/biophysics/schema
xmlns:cml: http://morphml.org/channelml/schema
xmlns:meta: http://morphml.org/metadata/schema
xmlns:mml: http://morphml.org/morphml/schema
xmlns:net: http://morphml.org/networkml/schema
xmlns:xsi: http://www.w3.org/2001/XMLSchema-instance
xsi:schemaLocation: http://morphml.org/neuroml/schema  NeuroML.xsd
',
# 						   timeout => 10000000,
						  },
						  {
						   read => '
#!neurospacesparse
// -*- NEUROSPACES -*-

NEUROSPACES NDF

IMPORT
END IMPORT

PRIVATE_MODELS
END PRIVATE_MODELS

PUBLIC_MODELS
  CELL Granule_98
    SEGMENT Soma
      PARAMETERS
        PARAMETER ( RM = 0.0330033 ),
        PARAMETER ( CM = 0.01 ),
        PARAMETER ( RA = 0.001 ),
        PARAMETER ( Vm_init = -0.065 ),
        PARAMETER ( LENGTH = 0 ),
        PARAMETER ( DIA = 1e-05 ),
        PARAMETER ( NEUROML_group[1] = "soma_group" ),
        PARAMETER ( NEUROML_group[0] = "all" ),
        PARAMETER ( NEUROML_cable = "0" ),
      END PARAMETERS
    END SEGMENT
  END CELL
END PUBLIC_MODELS
',
						  },
						 ],
				description => "low-level yaml export of the loaded neuroml",
			       },
			      ],
       description => "loading of neuroml files",
       name => 'neuroml/loading.t',
      };


return $test;


