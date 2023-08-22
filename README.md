# GENIE_Hadronic_XS_Script

This product is a script designed to simulate hadron/nuclei interaction with GENIE and to plot the reactions observables, including the double-differential particle-production, total, reaction, charge exchange, pion production, absorption, Knock out cross-sections. 

## Authors

<pre>
Nicholas Geary [1] , < nig22 \at pitt.com >
Narisoa M Vololoniaina [2] < nariymarc \at gmail.com >, 

(1) University of Pittsburgh
(2) University of Antananarivo, Madagascar

</pre>
 
## How to run the simulation?
runfast-2018.pl is the program responsible for the simulation of the reaction Hadron-Nucleus, it calls gevgen_hadron command and then produces gntp.inuke.***.ghep.root or text files inside the "root_files" directory.

# example: to run the simulation of proton on Iron according to the Bertrand experiment, type the following command:
  perl runfast.pl --type root --a bertrand --n Nevents --m GENIE_Hadronic_Model
  
  GENIE_Hadronic_model: -hA2018
  						-hN2018
  						-HINCL
  						-HG4BertCasc

## How to make the plots?
intranukeplotter-2018.pl is the script responsible for the generation of the plots.

#example: to plot the double differential cross section in angle and in energy of the raction proton +Fe (according to the Bertrand experiment):
perl intranukeplotter-2018.pl --type nrg --a bertrand --dorf date --m GENIE_Hadronic_Model

## For more information about run options look at "runfast-2018.pl" and "intranukeplotter-2018.pl"