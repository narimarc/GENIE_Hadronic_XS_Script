###########################################################################################################
##                                                                                                       ##
## Title:       intranukeplotter.pl                                                                      ##
##                                                                                                       ##
## Author:      Nicholas Geary, University of Pittsburgh (nig22@pitt.edu)  
##              updated Narisoa Vololoniaina 2023                                      ##
##                                                                                                       ##
## Description: This script generates format files based on user-specified experimental data and GENIE   ##
##              simulations. It then uses those format files and data files as inputs to rootgINukeVal.C ##
##              to generate plots, which are saved as png files.                                         ##
##                                                                                                       ##
## Use:         To plot angular distributions:                                                           ##
##                 perl intranukeplotter.pl --type ang --a author --dorf date [--v vsn] [--m mode]       ##
##                 [--datadir ddir] [--rootdir rdir] [--pngdir pdir] [--rm discard] [--png off]          ##
##                 [--name prepend]                                                                      ##
##                                                                                                       ##
##              To plot energy distributions:                                                            ##
##                 perl intranukeplotter.pl --type nrg --a author --dorf date [--v vsn] [--m mode]       ##
##                 [--datadir ddir] [--rootdir rdir] [--pngdir pdir] [--rm discard] [--png off]          ##
##                 [--name prepend]                                                                      ##
##                                                                                                       ##
##              To plot total cross sections:                                                            ##
##                 perl intranukeplotter.pl --type totxs --stype fate --p prb --t Tgt --hmax max         ##
##                 --vmax max --dorf date [--a author] [--v vsn] [--m mode] [--datadir ddir]             ##
##                 [--rootdir rdir] [--pngdir pdir] [--rm discard] [--png off] [--name prepend]          ##
##                                                                                                       ##
##              Notes: Compare up to 3 GENIE versions and 2 modes. Use switches --v2, --v3, --m2,        ##
##                     --dorf2, etc.                                                                     ##
##                     For total cross sections, script will automatically define authors whose data     ##
##                     match the specified reaction. Manually defining authors for total cross sections  ##
##                     turns this feature off.                                                           ##
##                                                                                                       ##
##              Currently supported authors:                                                             ##
##                 Ang: cochran, hautala, ingram, levenson, mckeown                                      ##
##                 Nrg: amian, baker, beck, bertrand, carman, chen, cochran, franz, hautala, hayashi,    ##
##                      ingram, iwamoto, kin, kormanyos, levenson, levenson_100, (Levenson @ 100 MeV)    ##
##                       mcgill, mckeown, meier, otsu, ouyang,                                           ##
##                      roy, slypen, stamer,tippawan, tyren, zumbro                                      ##
##                 Tot:                                                                                  ##
##                    Nucleon: abfalterer, auce, bauhof, dicello, dietrich, ibaraki, kirkby, mcgill,     ## 
##                             menet, mislivec, renberg, schimmerling, voss, zanelli                     ##
##                    Kaon:    bugg, friedman, krauss                                                    ##
##                    Pion:    allardyce, aniol, ashery, bowles, brinkmoller, clough, gelderloos,        ##
##                             lehmann, meirav, navon, saunders, wilkin , mashnik                                 ##
##                                                                                                       ##
## Input:       ROOT file:  $rootdir/[author]_MMM_DD_YY_prb_tgt_nrg_vsn_mode.ginuke.root                 ##
##              Data files:                                                                              ##
##                 Ang: $datadir/author-prb-tgt-nrg-det-angdist.dat                                      ##
##                 Nrg: $datadir/author-prb-tgt-nrg-det-ang.dat                                          ##
##                 Tot: $datadir/author-prb-tgt-fate.dat                                                 ##
##                                                                                                       ##
## Output:      Ang: $pngdir/author-prb-tgt-nrg-det-angdist-vsn-mode-date.png                            ##
##              Nrg: $pngdir/author-prb-tgt-nrg-det-ang-vsn-mode-date.png                                ##
##              Tot: $pngdir/prb-tgt-fate-vsn-mode-date.png                                              ##
##                                                                                                       ##
## Default file locations:                                                                               ##
##              ROOT files: ./root_files/                                                                ##
##              Data files: ./data_files/                                                                ##
##              Plot files: ./png_files/                                                                 ##
##                                                                                                       ## 
###########################################################################################################

$iarg = 0;
foreach (@ARGV) {
    if ($_ eq '--type')    { $type       = $ARGV[$iarg+1]; }     ## angular distribution, energy distribution, or total cross section
    if ($_ eq '--v')       { $vsn[0]     = $ARGV[$iarg+1]; }     ## GENIE version 1
    if ($_ eq '--v1')      { $vsn[0]     = $ARGV[$iarg+1]; }     ## GENIE version 1
    if ($_ eq '--v2')      { $vsn[1]     = $ARGV[$iarg+1]; }     ## GENIE version 2
    if ($_ eq '--v3')      { $vsn[2]     = $ARGV[$iarg+1]; }     ## GENIE version 3
    if ($_ eq '--v4')      { $vsn[3]     = $ARGV[$iarg+1]; }     ## GENIE version 3
    if ($_ eq '--v5')      { $vsn[4]     = $ARGV[$iarg+1]; }     ## GENIE version 3
    if ($_ eq '--v6')      { $vsn[5]     = $ARGV[$iarg+1]; }     ## GENIE version 3
    if ($_ eq '--m')       { $mdl[0]     = $ARGV[$iarg+1]; }     ## GENIE model 1
    if ($_ eq '--m1')      { $mdl[0]     = $ARGV[$iarg+1]; }     ## GENIE model 1
    if ($_ eq '--m2')      { $mdl[1]     = $ARGV[$iarg+1]; }     ## GENIE model 2
    if ($_ eq '--m3')      { $mdl[2]     = $ARGV[$iarg+1]; }     ## GENIE model 3
    if ($_ eq '--m4')      { $mdl[3]     = $ARGV[$iarg+1]; }     ## GENIE model 4 ***added july 25 2017  hN2015on hN2015off tags 
    if ($_ eq '--m5')      { $mdl[4]     = $ARGV[$iarg+1]; }     ## GENIE model 5 ***added july 25 2017  can compare hA2014, hA2015, hN2015 (oset or NNCorr)on/off all on same plot
    if ($_ eq '--m6')      { $mdl[5]     = $ARGV[$iarg+1]; }     ## GENIE model 6 ***added july 25 2017  can compare hA2014, hA2015, hN2015 (oset or NNCorr)on/off all on same plot
    if ($_ eq '--m7')      { $mdl[6]     = $ARGV[$iarg+1]; }     ## GENIE model 7 ***added july 25 2017  can compare hA2014, hA2015, hN2015 (oset or NNCorr)on/off all on same plot
    if ($_ eq '--dorf')    { $dorf[0]    = $ARGV[$iarg+1]; }     ## date of first root (gst) file
    if ($_ eq '--dorf1')   { $dorf[0]    = $ARGV[$iarg+1]; }     ## date of first root (gst) file
    if ($_ eq '--dorf2')   { $dorf[1]    = $ARGV[$iarg+1]; }     ## date of second root (gst) file
    if ($_ eq '--dorf3')   { $dorf[2]    = $ARGV[$iarg+1]; }     ## date of third root (gst) file
    if ($_ eq '--a')       { $author     = $ARGV[$iarg+1]; }     ## author for group of runs
    if ($_ eq '--rm')      { $remove     = $ARGV[$iarg+1]; }     ## choose to discard format files after use (enter "yes" as argument; note that format files cannot be removed unless png files are produced)
    if ($_ eq '--png')     { $png        = $ARGV[$iarg+1]; }     ## choose to turn off png file formation (enter "off" as argument)
    if ($_ eq '--datadir') { $datadir    = $ARGV[$iarg+1]; }     ## directory to find data files
    if ($_ eq '--rootdir') { $rootdir    = $ARGV[$iarg+1]; }     ## directory to find root files
    if ($_ eq '--pngdir')  { $pngdir     = $ARGV[$iarg+1]; }     ## directory to put png files
    if ($_ eq '--p')       { $probe      = $ARGV[$iarg+1]; }     ## probe
    if ($_ eq '--t')       { $tgt        = $ARGV[$iarg+1]; }     ## target
    if ($_ eq '--a')       { $authors[0] = $ARGV[$iarg+1]; }     ## author
    if ($_ eq '--a2')      { $authors[1] = $ARGV[$iarg+1]; }     ## second author
    if ($_ eq '--a3')      { $authors[2] = $ARGV[$iarg+1]; }     ## third author
    if ($_ eq '--a4')      { $authors[3] = $ARGV[$iarg+1]; }     ## fourth author
    if ($_ eq '--a5')      { $authors[4] = $ARGV[$iarg+1]; }     ## fifth author
    if ($_ eq '--stype')   { $st         = $ARGV[$iarg+1]; }     ## sub-type (fate)
    if ($_ eq '--hmax')    { $hmax       = $ARGV[$iarg+1]; }     ## horizontal maximum on plot
    if ($_ eq '--vmax')    { $vmax       = $ARGV[$iarg+1]; }     ## vertical maximum on plot
    if ($_ eq '--name')    { $prepend    = $ARGV[$iarg+1]; }     ## option to prepend author's name ('yes' to prepend)
    if ($_ eq '--rescale') { $rescale    = $ARGV[$iarg+1]; }     ## factor by which to rescale vertical maximum on plot
    if ($_ eq '--rmode')   { $rmode      = $ARGV[$iarg+1]; }     ## root mode-- '0' runs 'root -b -q' and '1' runs 'root -l'
    if ($_ eq '--err')     { $err_system = $ARGV[$iarg+1]; }     ## error system ('i' for interactive; defaults to non-interactive)
    if ($_ eq '--modes1')  { $modes[0]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 1
    if ($_ eq '--modes2')  { $modes[1]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 2
    if ($_ eq '--modes3')  { $modes[2]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 3
    if ($_ eq '--modes4')  { $modes[3]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 4
    if ($_ eq '--modes5')  { $modes[4]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 5
    if ($_ eq '--modes6')  { $modes[5]   = $ARGV[$iarg+1]; }     ## comma-separated list of modes for GENIE version 6
    if ($_ eq '--tag1')    { $tag1       = $ARGV[$iarg+1]; }     ## optional tag to be placed at the end of png file; if used it  MUST match the tag command used in runfast command to be able to find proper root files (1/2)
    if ($_ eq '--tag2')    { $tag2       = $ARGV[$iarg+1]; }     ## optional tag to be placed at the end of png file; if used it  MUST match the tag command used in runfast command to be able to find proper root files (1/2)  
    $iarg++;
};

check_input();
set_defaults();


### ANGULAR DISTRIBUTION ROUTINE ###

if ($type eq 'ang') {

%group_hash = (  ## link specified author to associated groupsashery
    'amian' => ['amian'],
    'baker' => ['baker_c', 'baker_ca'],
    'crawford'=>['crawford'],
    'Geant'=>['Geant'],
    'beck' => ['beck'],
    'nica'=>['nica'],
'letourneau'=>['letourneau_p','letourneau_h2','letourneau_h3','letourneau_he3','letourneau_he4'],    
    'benck'=>['benck_h2','benck_h3','benck_he4'],
    #'bertrand' => ['bertrand'],,
    #'bertrand'=>['bertrandpal_h2','bertrandpal_h3','bertrandpal_he3','bertrandpal_he4','bertrand_h2','bertrand_h3','bertrand_he3','bertrand_he4','abertrand_h61','abertrand_h361','abertrand_he361','abertrand_he461'],
    'bertrand'=>['bertrand_h2','bertrand_h3','bertrand_he3','bertrand_he4','abertrand_h61','abertrand_h361','abertrand_he361','abertrand_he461'],
    'abertrand' => ['abertrand_28','abertrand_61'],
    'sanami' => ['sanami_h2','sanami_h3'],
    'fidelus'=>['fidelus'],
    'machner'=>['machner_he3','machner_he4'],
    'carman' => ['carman'],
    'chen' => ['chen'],
    'cochran' => ['cochran'],
    'franz' => ['franz1','franz2'],
    'hautala' => ['hautala'],
    'hayashi' => ['hayashi'],
    'ingram' => ['ingram'],
    'iwamoto' => ['iwamoto_pim', 'iwamoto_pip'],
    'kin' => ['kin'],
    'ledoux' => ['ledoux'],      
    'levenson' => ['levenson_ang'],
    'levenson_220' => ['levenson_ang_220'],
    'mcgill' => ['mcgill'],    
    'mckeown' => ['mckeown','mckeown_2'],
    'mckshort' => ['mckshort'],
    'meier' => ['meier', 'meier_al'],
    'otsu' => ['otsu'],
    'ouyang' => ['ouyang'],
    'roy' => ['roy'],
    #'segel'=>['segel'],
    'shibata' => ['shibata_p','shibata_pi'], ## update this
    'slypen' => ['slypen_c', 'slypen_fe'],
    'stamer' => ['stamer'],
    'tippawan' => ['tippawan'],
    'tyren' => ['tyren'],
    'zumbro' => ['zumbro'],
    );
@groups = @{$group_hash {$author}};

foreach $group (@groups) {
    if ($group eq "amian") {
    @p = qw( p );                              ## probes
    @Tgt = qw( B Be C O Pb );                  ## targets
    @nrg = ( 597, 800 );                       ## energies
    @dp = qw( n );                             ## detected particles
    $bins = 4;                                 ## number of bins
};
if ($group eq "baker_c") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 318 );
    @dp = qw( p );
    $bins = 4;
};
if ($group eq "crawford") {
    @p = qw( p );  
    @Tgt = qw( C Ni );
    @nrg = ( 585 );
    @dp = qw( pip );
    $bins = 4;
};
if ($group eq "baker_ca") {
    @p = qw( p );  
    @Tgt = qw( Ca );
    @nrg = ( 320 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "beck") {
    @p = qw( p );  
    @Tgt = qw( Fe Pb );
    @nrg = ( 558 );
    @dp = qw( p );
    $bins = 4;
};
if ($group eq "bertrand") {
    @p = qw( p );  
    @Tgt = qw( Fe );
    @nrg = ( 65 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "abertrand_28") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 28.8 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "abertrand_61") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 61.7 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "bertrand_h2") {
    @p = qw( p );  
    @Tgt = qw( fe  );
    @nrg = ( 61.7 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "abertrand_h61") {
    @p = qw( p );  
    @Tgt = qw( al  );
    @nrg = ( 61.7 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "abertrand_h361") {
    @p = qw( p );  
    @Tgt = qw( al  );
    @nrg = ( 61.7 );
    @dp = qw( h3 ); 
    $bins = 4;
};if ($group eq "abertrand_he361") {
    @p = qw( p );  
    @Tgt = qw( al  );
    @nrg = ( 61.7 );
    @dp = qw( he3 ); 
    $bins = 4;
};if ($group eq "abertrand_he461") {
    @p = qw( p );  
    @Tgt = qw( al  );
    @nrg = ( 61.7 );
    @dp = qw( he4 ); 
    $bins = 4;
};




if ($group eq "bertrand_h3") {
    @p = qw( p );  
    @Tgt = qw( fe  );
    @nrg = ( 61.7 );
    @dp = qw( h3 ); 
    $bins = 4;
};
if ($group eq "bertrand_he3") {
    @p = qw( p );  
    @Tgt = qw(  fe  );
    @nrg = ( 61.7 );
    @dp = qw( he3 ); 
    $bins = 4;
};
if ($group eq "bertrand_he4") {
    @p = qw( p );  
    @Tgt = qw( fe  );
    @nrg = ( 61.7 );
    @dp = qw( he4 ); 
    $bins = 4;
};


if ($group eq "fidelus") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 1200,1900,2500 );
    @dp = qw( he3 ); 
    $bins = 4;
};

if ($group eq "letourneau_p") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 2500 );
    @dp = qw( p ); 
    $bins = 4;
};

if ($group eq "letourneau_h2") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 2500 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "letourneau_h3") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 2500 );
    @dp = qw( h3 ); 
    $bins = 4;
};
if ($group eq "letourneau_he3") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 2500 );
    @dp = qw( he3 ); 
    $bins = 4;
};
if ($group eq "letourneau_he4") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 2500 );
    @dp = qw( he4 ); 
    $bins = 4;
};






if ($group eq "watanabe_h2") {
    @p = qw( n );  
    @Tgt = qw( si );
    @nrg = ( 175.4 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "watanabe_h3") {
    @p = qw( n);  
    @Tgt = qw( si );
    @nrg = ( 175.4);
    @dp = qw( h3 ); 
    $bins = 4;
};
if ($group eq "watanabe_he3") {
    @p = qw( n );  
    @Tgt = qw( si );
    @nrg = ( 175.4 );
    @dp = qw( he3 ); 
    $bins = 4;
};
if ($group eq "machner_he3") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 200 );
    @dp = qw( he3 ); 
    $bins = 4;
};
if ($group eq "machner_he4") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 200 );
    @dp = qw( he4 ); 
    $bins = 4;
};
if ($group eq "sanami_h2") {
    @p = qw( n );  
    @Tgt = qw( al );
    @nrg = ( 75 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "sanami_h3") {
    @p = qw( n);  
    @Tgt = qw( al );
    @nrg = ( 75 );
    @dp = qw( h3 ); 
    $bins = 4;
};
if ($group eq "carman") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 200 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "chen") {
    @p = qw( p );  
    @Tgt = qw( Pb );
    @nrg = ( 290 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "cochran") {
    @p = qw( p );  
    @Tgt = qw( Al Be C Cu Pb H);
    @nrg = ( 730 );
    @dp = qw( pim pip ); 
    $bins = 10;
};
#if ($group eq "cochran") {
 #   @p = qw( p );  
 #   @Tgt = qw( Al Be C Cu Pb H );
  #  @nrg = ( 730 );
  #  @dp = qw( pim pip ); 
  #  $bins = 10;
#};
#if ($group eq "franz") {
  #  @p = qw( n );  
  #  @Tgt = qw( Cu );
  #  @nrg = ( 383, 425, 477, 542, 317.4, 347.7 );
  #  @dp = qw( p ); 
 #   $bins = 4;
#};
if ($group eq "franz1") {
    @p = qw( n );  
    @Tgt = qw( Cu Bi );
    @nrg = ( 383, 425, 477, 542, 317.4 );
    @dp = qw( h2 ); 
    $bins = 4;
};
if ($group eq "franz2") {
    @p = qw( n );  
    @Tgt = qw( Cu Bi );
    @nrg = ( 383, 425, 477, 542, 317.4);
    @dp = qw( h3 ); 
    $bins = 4;
};
if ($group eq "hautala") {
    @p = qw( p );  
    @Tgt = qw( Ca );
    @nrg = ( 197 );
    @dp = qw( n ); 
    $bins = 4;
};
if ($group eq "hayashi") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 147 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "ingram") {
    @p = qw( pip );  
    @Tgt = qw( H2O );
    @nrg = ( 114, 163, 240 );
    @dp = qw( pip );
    $bins = 2;
};
if ($group eq "iwamoto_pim") {
    @p = qw( pim );  
    @Tgt = qw( Fe );
    @nrg = ( 870 );
    @dp = qw( n );  
    $bins = 2;
};
if ($group eq "iwamoto_pip") {
    @p = qw( pip );  
    @Tgt = qw( Fe );
    @nrg = ( 870, 2100 );
    @dp = qw( n ); 
    $bins = 2;
};
if ($group eq "uozumi_Au") {
    @p = qw( p );  
    @Tgt = qw( c Al Nb Au );
    @nrg = ( 300 );
    @dp = qw( h2 ); 
    $bins = 2;
};
if ($group eq "nica") {
    @p = qw( n );  
    @Tgt = qw( Co );
    @nrg = ( 62.7 );
    @dp = qw( h2 ); 
    $bins = 2;
};
if ($group eq "benck_h2") {
    @p = qw( n );  
    @Tgt = qw( Al );
    @nrg = ( 62.7 );
    @dp = qw( h2 ); 
    $bins = 2;
};

if ($group eq "benck_h3") {
    @p = qw( n );  
    @Tgt = qw( Al );
    @nrg = ( 62.7 );
    @dp = qw( h3 ); 
    $bins = 2;
};
if ($group eq "benck_he4") {
    @p = qw( n );  
    @Tgt = qw( Al );
    @nrg = ( 62.7 );
    @dp = qw( he4 ); 
    $bins = 2;
};

if ($group eq "uozumi_c") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 300 );
    @dp = qw( h2 ); 
    $bins = 2;
};
if ($group eq "uozumi") {
    @p = qw( p );  
    @Tgt = qw( au);
    @nrg = ( 300 );
    @dp = qw( h2 ); 
    $bins = 2;
};
if ($group eq "uozumi_nb") {
    @p = qw( p );  
    @Tgt = qw( nb );
    @nrg = ( 300 );
    @dp = qw( h2 ); 
    $bins = 2;
};
if ($group eq "uozumi_au") {
    @p = qw( p );  
    @Tgt = qw( au);
    @nrg = ( 300 );
    @dp = qw( h2 ); 
    $bins = 2;
};

if ($group eq "uozumi_AAl") {
    @p = qw( p );  
    @Tgt = qw( al);
    @nrg = ( 392 );
    @dp = qw( he3 ); 
    $bins = 2;
};
if ($group eq "kin") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 300, 392 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "ledoux") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 800 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "levenson_ang") {
    @p = qw( pip );  
    @Tgt = qw( He C Ni Pb );
    @nrg = ( 100, 160, 220 );
    @dp = qw( pip ); 
    $bins = 4;
};
if ($group eq "levenson_ang_220") {
    @p = qw( pip );  
    @Tgt = qw( He C Ni Pb );
    @nrg = ( 220 );
    @dp = qw( pip ); 
    $bins = 4;
};
if ($group eq "mcgill") {
    @p = qw( p );  
    @Tgt = qw( C Ca );
    @nrg = ( 800 );
    @dp = qw( p );  
    $bins = 2;
};
if ($group eq "mckeown") {
    @p = qw( pim pip );  
    @Tgt = qw( C Li Ni Ta He );
    @nrg = ( 100, 160, 220 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "mckeown_2") {
    @p = qw( pim pip );  
    @Tgt = qw( Al Be );
    @nrg = ( 100, 220 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "mckshort") {
    @p = qw( pim pip );  
    @Tgt = qw( C Al Ni );
    @nrg = ( 100, 160, 220 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "meier") {
    @p = qw( p );  
    @Tgt = qw( C Fe O Pb );
    @nrg = ( 113 );
    @dp = qw( n );  
    $bins = 4;
};
if ($group eq "meier_al") {
    @p = qw( p );  
    @Tgt = qw( Al );
    @nrg = ( 256 );
    @dp = qw( n ); 
    $bins = 4;
};
if ($group eq "otsu") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 392, 400 );
    @dp = qw( n ); 
    $bins = 4;
};
if ($group eq "ouyang") {
    @p = qw( pim );  
    @Tgt = qw( C Bi );
    @nrg = ( 500 );
    @dp = qw( pi0 );  
    $bins = 4;
};
if ($group eq "roy") {
    @p = qw( p );  
    @Tgt = qw( He Ni Ta );
    @nrg = ( 500 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "slypen_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 26.5, 50, 62.7, 72.8 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "slypen_fe") {
    @p = qw( n );  
    @Tgt = qw( Fe );
    @nrg = ( 25.5, 49, 62.7 );
    @dp = qw( p );  
    $bins = 4;
};
if ($group eq "stamer") {
    @p = qw( p );  
    @Tgt = qw( Al Pb Zr );
    @nrg = ( 256, 800 );
    @dp = qw( n ); 
    $bins = 2;
};
if ($group eq "tippawan") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 95.6 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "tyren") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 185 );
    @dp = qw( p ); 
    $bins = 4;
};
if ($group eq "zumbro") {
    @p = qw( pip );  
    @Tgt = qw( C );
    @nrg = ( 500 );
    @dp = qw( pip );
    $bins = 4;
};

foreach $tgt (@Tgt) {
    foreach $probe (@p) {
       foreach $det (@dp) {
           set_particles();
           set_file_names();
           make_format_file();
           make_png_files();
       };
   };
};
};
}


###############################################################################################################################################################
###############################################################################################################################################################

### ENERGY DISTRIBUTION ROUTINE ###

if ($type eq 'nrg') {

%group_hash = (  ## link specified author to associated groups
    'amian' => ['amian'],
    'baker' => ['baker_c', 'baker_ca'],
    'beck' => ['beck'],
    #'bertrand' => ['bertrand'],
    'crawford'=>['crawford'],
    'machner'=>['machner','machner_he3', 'machner_he4'],
    #'bertrand' => ['abertrand_28','abertrand_61'],
    #'bertrand'=>['bertrandpal_h2','bertrandpal_h3','bertrandpal_he3','bertrandpal_he4','bertrand_h2','bertrand_h3','bertrand_he3','bertrand_he4','abertrand_h61','abertrand_h361','abertrand_he361','abertrand_he461'],
    'bertrand'=>['bertrand_h2','bertrand_h3','bertrand_he3','bertrand_he4','abertrand_h61','abertrand_h361','abertrand_he361','abertrand_he461'],
    'fidelus'=>['fidelus'],
    'letourneau'=>['letourneau_p','letourneau_h2','letourneau_h3','letourneau_he3','letourneau_he4'],
    'watanabe'=>['watanabe_h2','watanabe_h3','watanabe_he3'],
    'sanami' => ['sanami_h2','sanami_h3'],
    'carman' => ['carman'],
    'chen' => ['chen'],
    'cochran' => ['cochran','cochran_h_pim','cochran_h_pip'],
   #'cochran' => ['cochran'],
   'franz' => ['franz1','franz2'],
   'hautala' => ['hautala'],
   'hayashi' => ['hayashi'],
   'ingram' => ['ingram_114', 'ingram_240'],#,'ingram_162'
   'iwamoto' => ['iwamoto_870', 'iwamoto_2100'],
   'nica'=>['nica'],
   'benck'=>['benck_h2','benck_h3','benck_he4'],
   'uozumi'=>['uozumi','uozumi_al','uozumi_AAl','uozumi_au'],
    #'uozumi'=>['uozumi','uozumi_AAl','uozumi_c','uozumi_al','uozumi_nb','uozumi_au'],
    'kin' => ['kin_300', 'kin_392'],
    'kormanyos' => ['kormanyos'],
    'ledoux' => ['ledoux'],
    'levenson' => ['levenson_1','levenson_2','levenson_3','levenson_4','levenson_5','levenson_6','levenson_7'],
    'levenson_100' =>['levenson_100_1','levenson_100_2', 'levenson_100_3'],
    'levenson_160' =>['levenson_160_1', 'levenson_160_2','levenson_160_3'],
    'levenson_220' =>['levenson_220_1', 'levenson_220_2'],
    'mcgill' => ['mcgill'],    
    'mckeown' => ['mckeown'],
    'meier' => ['meier', 'meier_al'],
    'otsu' => ['otsu_392', 'otsu_400'],
    'ouyang' => ['ouyang'],
    'roy' => ['roy', 'roy_ta'],
    'segel'=> ['segel_ni'],
    'shibata' => [ 'shibata1', 'shibata2', 'shibata3', 'shibata4', 'shibata5', 'shibata6', 'shibata7', 'shibata8', 'shibata9' ],
    'shibata_p' => [ 'shibata2', 'shibata3', 'shibata6', 'shibata7', 'shibata8', 'shibata9' ],
    'shibata_pi' => [ 'shibata1' , 'shibata4', 'shibata5' ],
    'slypen' => ['slypen_c', 'slypen_c_62.7', 'slypen_fe'],
    'stamer' => ['stamer'],
    'tippawan' => ['tippawan'],
    'tyren' => ['tyren'],
    'zumbro' => ['zumbro'],
################################################################### Subsets of authors #################################################################################
'mckeown100pip' => ['mckeown100pip'],
'mckeown160pip' => ['mckeown160pip'],
'mckeown220pip' => ['mckeown220pip'],

'mckeown100pim' => ['mckeown100pim'],
'mckeown160pim' => ['mckeown160pim'],
'mckeown220pim' => ['mckeown220pim'],

'slypen26.5' => ['slypen26.5_c', 'slypen26.5_fe'],
'slypen50' => ['slypen50_c','slypen50_fe'],
'slypen62.7' => ['slypen62.7_c', 'slypen62.7_fe'],
'slypen72.8' => ['slypen72.8_c','slypen72.8_fe'],
'slypen25.5' => ['slypen25.5_c','slypen25.5_fe' ],
'slypen49' => ['slypen49_c', 'slypen49_fe'],

'amian597' => ['amian597'],
'amian800' => ['amian800'],

'cochran_be' => ['cochran_be'],
'cochran_c' => ['cochran_c'],
'cochran_cu' => ['cochran_cu'],
'cochran_d' =>['cochran_d'],
'cochran_h' => ['cochran_hpip', 'cochran_hpim'],
'cochran_pb' => ['cochran_pb'],
'cochran_al' => ['cochran_al'],

);
@groups = @{$group_hash {$author}}; 

foreach $group ( @groups ) {  
    if ($group eq "amian") {
    @p = qw( p );                              ## probes
    @Tgt = qw( B Be C O Pb );                  ## targets
    @nrg = ( 597, 800 );                       ## energies
    @dp = qw( n );                             ## detected particles
    @ang = ( 30, 60, 120, 150 );               ## angles
    @cthmin = ( .82, .45, -.55, -.92 );        ## min cos(theta) cuts
    @cthmax = ( .92, .55, -.45, -.82 );        ## max cos(theta) cuts
    $bins = 4;                                 ## number of bins
};
if ($group eq "segel_ni"){
    @p=qw(p);
    @Tgt=qw(Ni);
    @nrg=(164);
    @dp=qw(p);
    @ang=(120, 25, 30, 40, 60, 90);
    @cthmax=(-0.469, 0.921, 0.883, 0.788, 0.530, 0.035);
    @cthmin=(-0.530, 0.891, 0.848, 0.743, 0.469, -0.035);
    $bins=4;
};
if ($group eq "baker_c") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 318 );
    @dp = qw( p );
    @ang = ( 3, 5, 7, 9, 12, 15, 18 );
    @cthmin = ( .998, .993, .99, .985, .974, .961, .946 );
    @cthmax = ( .9995, .998, .995, .99, .982, .971, .956 ); 
    $bins = 4;
};
if ($group eq "crawford") {
    @p = qw( p );  
    @Tgt = qw( C Ni );
    @nrg = ( 585 );
    @dp = qw( pip );
    @ang = ( 22.5,45,60,90,135);
    @cthmin = ( 0.909,0.682,0.469,-0.034,-0.731);
    @cthmax = ( 0.936,0.731,0.529,0.034,-0.682); 
    $bins = 8;
};
if ($group eq "baker_ca") {
    @p = qw( p );  
    @Tgt = qw( Ca );
    @nrg = ( 320 );
    @dp = qw( p );
    @ang = ( 3.5, 5, 7, 9, 10.5, 12, 14, 16, 18, 20, 23 );
    @cthmin = ( .9975, .993, .99, .985, .981, .974, .966, .957, .946, .935, .911 );
    @cthmax = ( .999, .998, .995, .99, .986, .982, .974, .965, .956, .945, .931 );  
    $bins = 4;
};
if ($group eq "beck") {
    @p = qw( p );  
    @Tgt = qw( Fe Pb );
    @nrg = ( 558 );
    @dp = qw( p );
    @ang = ( 10, 20, 30, 40, 50, 60 );
    @cthmin = ( .975, .921, .839, .731, .602, .454 );
    @cthmax = ( .995, .956, .891, .799, .682, .545 );  
    $bins = 8;
};
if ($group eq "machner_he4") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 200 );
    @dp = qw( he4 );
    @ang = ( 20, 45, 60, 90, 110);
    @cthmin = ( 0.913,0.656,0.438, -0.0174,-0.406);
    @cthmax = (0.961, 0.754,0.559, 0.0174,-0.275); 
    $bins = 4;
};
if ($group eq "machner_he3") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 200 );
    @dp = qw( he3 );
    @ang = ( 20, 45, 60, 90, 110);
    @cthmin = ( 0.913,0.656,0.438, -0.0174,-0.406);
    @cthmax = (0.961, 0.754,0.559, 0.0174,-0.275); 
    $bins = 4;
};
#if ($group eq "bertrand") {
#    @p = qw( p );  
 #   @Tgt = qw( Fe );
  #  @nrg = ( 65 );
   # @dp = qw( p );
  #  @ang = ( 20, 30, 37, 45, 52, 60, 75, 90, 120, 135 );
  #  @cthmin = ( .932, .855, .786, .692, .599, .48, .239, -.021, -.518, -.722 );
   # @cthmax = ( .947, .876, .811, .722, .632, .52, .279, .021, -.482, -.692 );  
   # $bins = 4;
#};
if ($group eq "fidelus") {
    @p = qw( p );  
    @Tgt = qw( al );
    @nrg = ( 1200,1900, 2500 );
    @dp = qw( he3 );
    @ang = ( 15.6,20,35,50,65,80,100 );
    @cthmin = ( 0.956,0.930,0.803,0.622,0.398,0.147,-0.199);
    @cthmax = (0.970,0.948, 0.833,0.662,0.446,0.199,-0.147);  
    $bins = 4;
};
if ($group eq "watanabe_h2") {
    @p = qw( n );  
    @Tgt = qw( si );
    @nrg = ( 175.4 );
    @dp = qw( h2 );
    @ang = ( 20,40,60,80,100,120,140,160 );
    @cthmin = (0.913,0.719,0.438,0.104,-0.241,-0.559,-0.809,-0.961);
    @cthmax = (0.961,0.809,0.559,0.241,-0.104,-0.438,-0.719,-0.913);  
    $bins = 4;
};
if ($group eq "watanabe_h3") {
    @p = qw( n );  
    @Tgt = qw( si );
    @nrg = ( 175.4 );
    @dp = qw( h3 );
    @ang = (  20,40,60 );
    @cthmin = ( 0.913,0.719,0.438);
    @cthmax = (0.961,0.809,0.559);  
    $bins = 4;
};
if ($group eq "watanabe_he3") {
    @p = qw( n );  
    @Tgt = qw( si );
    @nrg = ( 175.4 );
    @dp = qw( he3 );
    @ang = (  20,40,60,80 );
    @cthmin = ( 0.913,0.719,0.438,0.104);
    @cthmax = (0.961,0.809,0.559,0.241); 
    $bins = 4;
};

if ($group eq "sanami_h2") {
    @p = qw( n );  
    @Tgt = qw( al );
    @nrg = ( 75);
    @dp = qw( h2 );
    @ang = ( 25,65,125);
    @cthmin = ( 0.894,0.398,-0.594);
    @cthmax = ( 0.917,0.446,-0.551);  
    $bins = 4;
    };if ($group eq "sanami_h3") {
        @p = qw( n );  
        @Tgt = qw( al );
        @nrg = ( 75);
        @dp = qw( h3 );
        @ang = ( 25,65,125);
        @cthmin = ( 0.894,0.398,-0.594);
        @cthmax = ( 0.917,0.446,-0.551);  
        $bins = 4;
    };
    if ($group eq "abertrand_28") {
        @p = qw( p );  
        @Tgt = qw( al );
        @nrg = ( 28.8);
        @dp = qw( h2 );
        @ang = ( 11,30,60);
        @cthmin = ( 0.976,0.852,0.477);
        @cthmax = ( 0.986,0.878,0.522);  
        $bins = 4;
    };
    if ($group eq "bertrand_h2") {
        @p = qw( p );  
        @Tgt = qw( fe );
        @nrg = ( 61.7 );
        @dp = qw( h2 );
        @ang = ( 15,20,22,30,37,45,52,60,75,90,120,135);
        @cthmin = (0.953,0.923,0.909,0.843,0.771,0.675,0.580,0.461,0.216,-.1,-0.537,-0.737);
        @cthmax = (0.976,0.953,0.942,0.887,0.824,0.737,0.649,0.537,0.300,.1,-0.461,-0.675);
        $bins = 4;
};

    if ($group eq "bertrand_h3") {
        @p = qw( p );  
        @Tgt = qw( fe  );
        @nrg = ( 61.7 );
        @dp = qw( h3 );
        @ang = ( 15,20,22,30,37,45,52,60,75,90,120,135);
        @cthmin = (.953,0.930,0.917,0.843,0.771,0.675,0.580,0.216,-0.1,-0.537,-.8);
        @cthmax = (0.976,0.948,0.936,0.887,0.824,0.737,0.649,0.300,0.1,-0.4617,-.6);
        $bins = 4;
};

    if ($group eq "bertrand_he3") {
        @p = qw( p );  
        @Tgt = qw( fe  );
        @nrg = ( 61.7 );
        @dp = qw( he3 );
        @ang = ( 22,37,52,75,135 );
        @cthmin = (0.909,0.771,0.580,-0.737);
        @cthmax = (0.942,0.824,0.649,-0.675);  
        $bins = 4;
};

    if ($group eq "bertrand_he4") {
        @p = qw( p );  
        @Tgt = qw( fe  );
        @nrg = ( 61.7 );
        @dp = qw( he4 );
        @ang = ( 22,37,52,75,135 );
        @cthmin = (0.909,0.771,0.580,-0.737);
        @cthmax = (0.942,0.824,0.649,-0.675);
        $bins = 4;
};

    if ($group eq "abertrand_h61") {
        @p = qw( p );  
        @Tgt = qw( al );
        @nrg = ( 62.7 );
        @dp = qw( h2 );
        @ang = ( 12,15,25,30,35,40,45,50,55,60,65,70,75,82,90,110,160 );
        @cthmin = ( 0.972,0.958,0.894,0.852,0.803,0.748,0.688,0.622,0.551,0.477,0.398,0.317,0.233,0.113,-0.0261,-0.366,-0.948);
        @cthmax = ( 0.983,0.972,0.917,0.878,0.833,0.782,0.725,0.663,0.594,0.522,0.446,0.366,0.284,0.165,0.0261,-0.317,-0.930);  
        $bins = 4;
};#11 cthmin 0.976, cthmax 0.986, 
    if ($group eq "abertrand_h361") {
        @p = qw( p );  
        @Tgt = qw( al );
        @nrg = ( 62.7 );
        @dp = qw( h3 );
        @ang = ( 12,15,25,30,35,40,45,50,55,60,65,70,75,82,90,110,160 );
        @cthmin = ( 0.972,0.958,0.894,0.852,0.803,0.748,0.688,0.622,0.551,0.477,0.398,0.317,0.233,0.113,-0.0261,-0.366,-0.948);
        @cthmax = ( 0.983,0.972,0.917,0.878,0.833,0.782,0.725,0.663,0.594,0.522,0.446,0.366,0.284,0.165,0.0261,-0.317,-0.930);  
        $bins = 4;
};
    if ($group eq "abertrand_he361") {
        @p = qw( p );  
        @Tgt = qw( al );
        @nrg = ( 62.7 );
        @dp = qw( he3 );
        @ang = ( 12,15,25,30,35,40,45,55,60,65,70,75,82,90,110,160 );
        @cthmin = ( 0.972,0.958,0.894,0.852,0.803,0.748,0.688,0.551,0.477,0.398,0.317,0.233,0.113,-0.0261,-0.366,-0.948);
        @cthmax = ( 0.983,0.972,0.917,0.878,0.833,0.782,0.725,0.594,0.522,0.446,0.366,0.284,0.165,0.0261,-0.317,-0.930);  
        $bins = 4;
};
    if ($group eq "abertrand_he461") {
        @p = qw( p );  
        @Tgt = qw( al );
        @nrg = ( 62.7 );
        @dp = qw( he4 );
        @ang = ( 12,15,25,30,35,40,45,55,60,65,70,75,82,90,110,160 );
        @cthmin = ( 0.972,0.958,0.894,0.852,0.803,0.748,0.688,0.551,0.477,0.398,0.317,0.233,0.113,-0.0261,-0.366,-0.948);
        @cthmax = ( 0.983,0.972,0.917,0.878,0.833,0.782,0.725,0.594,0.522,0.446,0.366,0.284,0.165,0.0261,-0.317,-0.930);  
        $bins = 4;
};


if ($group eq "carman") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 200 );
    @dp = qw( p );
    @ang = ( 26.9, 30.3, 33.6 );
    @cthmin = ( .877, .848, .818 );
    @cthmax = ( .907, .878, .848 );  
    $bins = 6;
};


if ($group eq "letourneau_p") {
    @p = qw( p );  
    @Tgt = qw( Au );
    @nrg = ( 2500 );
    @dp = qw( p );
    @ang = ( 30, 75, 105, 150 );
    @cthmin = ( 0.838, 0.207,-0.309,-0.891);
    @cthmax = ( 0.891,0.309,-0.207,-0.838);  
    $bins = 4;
};
if ($group eq "letourneau_h2") {
    @p = qw( p );  
    @Tgt = qw( Au );
    @nrg = ( 2500 );
    @dp = qw( h2 );
    @ang = ( 30, 75, 105, 150 );
    @cthmin = ( 0.838, 0.207,-0.309,-0.891);
    @cthmax = ( 0.891,0.309,-0.207,-0.838);  
    $bins = 4;
};
if ($group eq "letourneau_h3") {
    @p = qw( p );  
    @Tgt = qw( Au );
    @nrg = ( 2500 );
    @dp = qw( h3 );
    @ang = ( 30, 75, 105, 150 );
    @cthmin = ( 0.838, 0.207,-0.309,-0.891);
    @cthmax = ( 0.891,0.309,-0.207,-0.838);  
    $bins = 4;
};
if ($group eq "letourneau_he3") {
    @p = qw( p );  
    @Tgt = qw( Au );
    @nrg = ( 2500 );
    @dp = qw( he3 );
    @ang = ( 30, 75, 105, 150 );
    @cthmin = ( 0.838, 0.207,-0.309,-0.891);
    @cthmax = ( 0.891,0.309,-0.207,-0.838);  
    $bins = 4;
};
if ($group eq "letourneau_he4") {
    @p = qw( p );  
    @Tgt = qw( Au );
    @nrg = ( 2500 );
    @dp = qw( he4 );
    @ang = ( 30, 75, 105, 150 );
    @cthmin = ( 0.838, 0.207,-0.309,-0.891);
    @cthmax = ( 0.891,0.309,-0.207,-0.838);  
    $bins = 4;
};




if ($group eq "chen") {
    @p = qw( p );  
    @Tgt = qw( Pb );
    @nrg = ( 290 );
    @dp = qw( p );
    @ang = ( 10 );
    @cthmin = ( .97 );
    @cthmax = ( 1 );  
    $bins = 4;
};
if ($group eq "cochran") {
    @p = qw( p );  
    @Tgt = qw( Al Be C Cu Pb );
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
#if ($group eq "cochran") {
 #   @p = qw( p );  
  #  @Tgt = qw( Al Be C Cu Pb );
   # @nrg = ( 730 );
   # @dp = qw( pim pip );
   # @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
   # @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
   # @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
   # $bins = 10;
#};
if ($group eq "cochran_h_pim") {
    @p = qw( p );  
    @Tgt = qw( H );
    @nrg = ( 730 );
    @dp = qw( pim );
    @ang = ( 15, 20, 30, 120, 150 );
    @cthmin = ( .956, .935, .846, -.6, -.886 );
    @cthmax = ( .976, .955, .886, -.4, -.846 );  
    $bins = 10;
};
if ($group eq "cochran_h_pip") {
    @p = qw( p );  
    @Tgt = qw( H );
    @nrg = ( 730 );
    @dp = qw( pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 );  
    $bins = 10; 
};
#if ($group eq "franz") {
   # @p = qw( n );  
   # @Tgt = qw( Cu );
   # @nrg = ( 383, 425, 477, 542, 317.4, 347.7 );
   # @dp = qw( p );
   # @ang = ( 54, 68, 90, 121, 164 );
   # @cthmin = ( .515, .292, -.05, -.588, -.982 );
  #  @cthmax = ( .656, .454, .05, -.438, -.934 ); 
 #   $bins = 4;
#};

if ($group eq "franz1") {
    @p = qw( n );  
    @Tgt = qw( Cu Bi );
    @nrg = ( 383, 425, 477, 542, 317.4);
    @dp = qw( h2 );
    @ang = ( 54, 68, 90, 121, 164 );
    @cthmin = ( .515, .292, -.05, -.588, -.982 );
    @cthmax = ( .656, .454, .05, -.438, -.934 ); 
    $bins = 4;
};
if ($group eq "franz2") {
    @p = qw( n );  
    @Tgt = qw( Cu Bi );
    @nrg = ( 383, 425, 477, 542, 317.4);
    @dp = qw( h3 );
    @ang = ( 54, 68, 90, 121, 164 );
    @cthmin = ( .515, .292, -.05, -.588, -.982 );
    @cthmax = ( .656, .454, .05, -.438, -.934 ); 
    $bins = 4;
};
if ($group eq "hautala") {
    @p = qw( p );  
    @Tgt = qw( C Ca );
    @nrg = ( 197 );
    @dp = qw( n );
    @ang = ( 13, 24, 37, 48 );
    @cthmin = ( .969, .904, .769, .619 );
    @cthmax = ( .979, .924, .829, .719 ); 
    $bins = 8;
};
if ($group eq "hayashi") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 147 );
    @dp = qw( p );
    @ang = ( 20, 40 );
    @cthmin = ( .913, .719 );
    @cthmax = ( .961, .809 );  
    $bins = 4;
};
if ($group eq "ingram_114") {
    @p = qw( pip );  
    @Tgt = qw( O );
    @nrg = ( 114 );
    @dp = qw( pip );
    @ang = ( 50, 80 );
    @cthmin = ( .543, .074);
    @cthmax = ( .743, .274 );  
    $bins = 2;
};
if ($group eq "ingram_162") {
    @p = qw( pip );  
    @Tgt = qw( O h2o);
    @nrg = ( 162 );
    @dp = qw( pip );
    @ang = ( 30, 50, 80, 110, 134 );
    @cthmin = ( .766, .543, .074, -.442, -.845 );
    @cthmax = ( .966, .743, .274, -.222, -.545 );  
    $bins = 2;
};
if ($group eq "ingram_240") {
    @p = qw( pip );  
    @Tgt = qw( O );
    @nrg = ( 240 );
    @dp = qw( pip );
    @ang = ( 60, 130 );
    @cthmin = ( .35,-.793 );
    @cthmax = ( .65,-.493 ); 
    $bins = 2;
};
if ($group eq "iwamoto_870") {
    @p = qw( pim pip );  
    @Tgt = qw( Fe );
    @nrg = ( 870 );
    @dp = qw( n );
    @ang = ( 15, 30, 60, 90, 120, 150 );
    @cthmin = ( .946, .82, .4, -.1, -.6, -.97 );
    @cthmax = ( .986, .92, .6, .1, -.4, -.77);  
    $bins = 2;
};
if ($group eq "iwamoto_2100") {
    @p = qw( pip );  
    @Tgt = qw( Fe );
    @nrg = ( 2100 );
    @dp = qw( n );
    @ang = ( 15,120, 150 );
    @cthmin = ( .946, -.6, -.97 );
    @cthmax = ( .986, -.4, -.77); 
    $bins = 2;
};
if ($group eq "uozumi") {
    @p = qw( p );  
    @Tgt = qw( c nb );
    @nrg = ( 300 );
    @dp = qw( h2 );
    @ang = ( 20, 30, 45, 60, 75, 90, 105 );
    @cthmin = ( .932, .839, .657,.4, .208,-.1, -.309 );
    @cthmax = ( .947, .891,  .757,.6,  .309,.1, -.208  );  
    $bins = 4;
};

if ($group eq "uozumi_al") {
    @p = qw( p );  
    @Tgt = qw( al);
    @nrg = ( 300 );
    @dp = qw( h2 );#25 deg min max io ,.891,.920
    @ang = ( 25,30, 45, 60, 75, 90, 105 );
    @cthmin = (.891,.839, .657,.4, .208,-.1, -.309 );
    @cthmax = (.920,.891,  .757,.6,.309,.1, -.208  );  
    $bins = 4;
};
if ($group eq "uozumi_AAl") {
    @p = qw( p );  
    @Tgt = qw( al);
    @nrg = ( 392 );
    @dp = qw( h2 );#25 deg min max io ,.891,.920
    @ang = ( 20,35, 45, 60, 75, 90, 105  );
    @cthmin = (.932,0.777 , .657,.4, .208,-.1, -.309 );
    @cthmax = (.947,0.857,  .757,.6,.309,.1, -.208);  
    $bins = 4;
};
if ($group eq "uozumi_au") {
    @p = qw( p );  
    @Tgt = qw( au );
    @nrg = ( 300 );
    @dp = qw( h2 );
    @ang = ( 30, 45, 60, 75, 90, 105 );
    @cthmin = ( .839, .657,.4, .208,-.1, -.309 );
    @cthmax = ( .891,  .757,.6,  .309,.1, -.208  );  
    $bins = 4;
};

if ($group eq "nica") {
    @p = qw( n );  
    @Tgt = qw( co );
    @nrg = ( 62.7 );
    @dp = qw( h2 );
    @ang = (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170);
    @cthmin = (.978,.927,.848,.743,.615,.469,.309,.139,-.1,-.207,-.374,-.529,-.669,-.788,-.882,-.951,-.990);
    @cthmax = (.990,.951,.882,.788,.669,.529,.374,.207,.1,-.139,-.309,-.469,-.615,-.743,-.848,-.927,-.978);  
    $bins = 4;
};
if ($group eq "benck_h2") {
    @p = qw( n );  
    @Tgt = qw( al );
    @nrg = ( 62.7 );
    @dp = qw( h2 );
    @ang = (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170);
    @cthmin = (.978,.927,.848,.743,.615,.469,.309,.139,-.1,-.207,-.374,-.529,-.669,-.788,-.882,-.951,-.990);
    @cthmax = (.990,.951,.882,.788,.669,.529,.374,.207,.1,-.139,-.309,-.469,-.615,-.743,-.848,-.927,-.978);  
    $bins = 4;
};
if ($group eq "benck_h3") {
    @p = qw( n );  
    @Tgt = qw( al );
    @nrg = ( 62.7 );
    @dp = qw( h3 );
    @ang = (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170);
    @cthmin = (.978,.927,.848,.743,.615,.469,.309,.139,-.1,-.207,-.374,-.529,-.669,-.788,-.882,-.951,-.990);
    @cthmax = (.990,.951,.882,.788,.669,.529,.374,.207,.1,-.139,-.309,-.469,-.615,-.743,-.848,-.927,-.978);  
    $bins = 4;
};
if ($group eq "benck_he4") {
    @p = qw( n );  
    @Tgt = qw( al );
    @nrg = ( 62.7 );
    @dp = qw( he4 );
    @ang = (10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170);
    @cthmin = (.978,.927,.848,.743,.615,.469,.309,.139,-.1,-.207,-.374,-.529,-.669,-.788,-.882,-.951,-.990);
    @cthmax = (.990,.951,.882,.788,.669,.529,.374,.207,.1,-.139,-.309,-.469,-.615,-.743,-.848,-.927,-.978);  
    $bins = 4;
};
if ($group eq "kin_300") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 300 );
    @dp = qw( p );
    @ang = ( 20, 30, 40, 50, 60, 75, 90, 105 );
    @cthmin = ( .921, .839, .731, .602, .454, .208, -.052, -.309 );
    @cthmax = ( .956, .891, .799, .682, .545, .309, .052, -.208 );  
    $bins = 4;
};
if ($group eq "kin_392") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 392 );
    @dp = qw( p );
    @ang = ( 20, 25, 40, 50, 75, 90, 105 );
    @cthmin = ( .921, .839, .731, .602, .454, .208, -.052, -.309 );
    @cthmax = ( .956, .891, .799, .682, .545, .309, .052, -.208 ); 
    $bins = 4;
};
if ($group eq "kormanyos") {
    @p = qw( kp );
    @Tgt = qw( C );
    @nrg = ( 367 );
    @dp = qw( kp );
    @ang = ( 42 );
    @cthmin = ( .682 );
    @cthmax = ( .799 ); 
    $bins = 4;
};
if ($group eq "ledoux") {
    @p = qw( p );
    @Tgt = qw( Pb );
    @nrg = ( 800 );
    @dp = qw( n );
    @ang = ( 0, 10, 25, 40, 55, 85, 130, 145, 160 );
    @cthmin = ( 0.999, .978, .891, .743, .544, .052, -.669, -.838, -.951 );
    @cthmax = ( 1., .990, .920, .788, .602, .121, -.615, -.798, -.927); 
    $bins = 4;
};
if ($group eq "levenson_100_1") {
    @p = qw( pip );  
    @Tgt = qw( C );
    @nrg = ( 100 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_1") {
    @p = qw( pip );  
    @Tgt = qw( C );
    @nrg = ( 100 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_2") {
    @p = qw( pip );  
    @Tgt = qw( C Ni );
    @nrg = ( 160 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_160_1") {
    @p = qw( pip );  
    @Tgt = qw( C Ni );
    @nrg = ( 160 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_160_2") {
    @p = qw( pip );  
    @Tgt = qw( He );
    @nrg = (160);
    @dp = qw( pip );
    @ang = ( 30, 60, 90, 120, 146 );
    @cthmin = (.788, .375, -.139, -.616, -.899 );
    @cthmax = (.927, .616, .139, -.375, -.743 ); 
    $bins = 4;
};
if ($group eq "levenson_160_3") {
    @p = qw( pip );  
    @Tgt = qw( Pb );
    @nrg = ( 160 );
    @dp = qw( pip );
    @ang = ( 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_6") {
    @p = qw( pip );  
    @Tgt = qw( Pb );
    @nrg = ( 160 );
    @dp = qw( pip );
    @ang = ( 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_3") {
    @p = qw( pip );  
    @Tgt = qw( C Ni Pb );
    @nrg = ( 220 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_220_1") {
    @p = qw( pip );  
    @Tgt = qw( C Ni Pb );
    @nrg = ( 220 );
    @dp = qw( pip );
    @ang = ( 30, 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .788, .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .927, .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_4") {
    @p = qw( pip );  
    @Tgt = qw( C );
    @nrg = ( 300 );
    @dp = qw( pip );
    @ang = ( 30, 60, 90, 120 );
    @cthmin = ( .788, .375, -.139, -.616 );
    @cthmax = ( .927, .616, .139, -.375 );  
    $bins = 4;
};
if ($group eq "levenson_5") {
    @p = qw( pip );  
    @Tgt = qw( Ni Pb );
    @nrg = ( 100 );
    @dp = qw( pip );
    @ang = ( 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_100_2") {
    @p = qw( pip );  
    @Tgt = qw( Ni Pb );
    @nrg = ( 100 );
    @dp = qw( pip );
    @ang = ( 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_6") {
    @p = qw( pip );  
    @Tgt = qw( Pb );
    @nrg = ( 160 );
    @dp = qw( pip );
    @ang = ( 50, 70, 90, 110, 130, 146 );
    @cthmin = ( .530, .208, -.139, -.469, -.743, -.899);
    @cthmax = ( .743, .469, .139, -.208, -.530, -.743);  
    $bins = 4;
};
if ($group eq "levenson_7") {
    @p = qw( pip );  
    @Tgt = qw( He );
    @nrg = ( 100, 160, 220 );
    @dp = qw( pip );
    @ang = ( 30, 60, 90, 120, 146 );
    @cthmin = (.788, .375, -.139, -.616, -.899 );
    @cthmax = (.927, .616, .139, -.375, -.743 ); 
    $bins = 4;
};
if ($group eq "levenson_220_2") {
    @p = qw( pip );  
    @Tgt = qw( He );
    @nrg = ( 220 );
    @dp = qw( pip );
    @ang = ( 30, 60, 90, 120, 146 );
    @cthmin = (.788, .375, -.139, -.616, -.899 );
    @cthmax = (.927, .616, .139, -.375, -.743 ); 
    $bins = 4;
};
if ($group eq "levenson_100_3") {
    @p = qw( pip );  
    @Tgt = qw( He );
    @nrg = ( 100);
    @dp = qw( pip );
    @ang = ( 30, 60, 90, 120, 146 );
    @cthmin = (.788, .375, -.139, -.616, -.899 );
    @cthmax = (.927, .616, .139, -.375, -.743 ); 
    $bins = 4;
};
if ($group eq "mcgill") {
    @p = qw( p );  
    @Tgt = qw( C Ca );
    @nrg = ( 800 );
    @dp = qw( p );
    @ang = ( 5, 11, 15, 20, 30 );
    @cthmin = ( .991, .9766, .946, .92, .82 );
    @cthmax = ( .999, .9866, .986, .96, .92 );  
    $bins = 2;
};
if ($group eq "mckeown") {
    @p = qw( pim pip );  
    @Tgt = qw( Al Be C Li Ni Ta );
    @nrg = ( 100, 160, 220 );
    @dp = qw( p );
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins = 4;
};
if ($group eq "mckshort") {
    @p = qw( pim pip );  
    @Tgt = qw( Al C Ni );
    @nrg = ( 100, 160, 220 );
    @dp = qw( p );
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins = 4;
};
if ($group eq "meier") {
    @p = qw( p );  
    @Tgt = qw( C Fe O Pb );
    @nrg = ( 113 );
    @dp = qw( n );
    @ang = ( 7.5, 30, 60, 150 );
    @cthmin = ( .986, .82, .4, -.97 );
    @cthmax = ( .996, .92, .6, -.77 );  
    $bins = 4;
};
if ($group eq "meier_al") {
    @p = qw( p );  
    @Tgt = qw( Al );
    @nrg = ( 256 );
    @dp = qw( n );
    @ang = ( 7.5, 30, 60, 150 );
    @cthmin = ( .986, .82, .4, -.97 );
    @cthmax = ( .996, .92, .6, -.77 );  
    $bins = 4;
};
if ($group eq "otsu_392") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 392 );
    @dp = qw( n );
    @ang = ( 12, 16, 20, 24, 28 );
    @cthmin = ( .976, .957, .934, .902, .871 );
    @cthmax = ( .98, .965, .946, .922, .894 ); 
    $bins = 4;
};
if ($group eq "otsu_400") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 400 );
    @dp = qw( p );
    @ang = ( 12, 16, 20, 24, 28 );
    @cthmin = ( .976, .957, .934, .902, .871 );
    @cthmax = ( .98, .965, .946, .922, .894 ); 
    $bins = 4;
};
if ($group eq "ouyang") {
    @p = qw( pim );  
    @Tgt = qw( C Bi );
    @nrg = ( 500 );
    @dp = qw( pi0 );
    @ang = ( 30 );
    @cthmin = ( .816 );
    @cthmax = ( .916 );  
    $bins = 4;
};
if ($group eq "roy") {
    @p = qw( p );  
    @Tgt = qw( He Ni );
    @nrg = ( 500 );
    @dp = qw( p );
    @ang = ( 65, 90, 120, 160 );
    @cthmin = ( .342, -.087, -.574, -.966 );
    @cthmax = ( .5, .087, -.423, -.906 ); 
    $bins = 4;
};
if ($group eq "roy_ta") {
    @p = qw( p );  
    @Tgt = qw( Ta );
    @nrg = ( 500 );
    @dp = qw( p );
    @ang = ( 90, 120, 160 );
    @cthmin = ( .342, -.087, -.574, -.966 );
    @cthmax = ( .5, .087, -.423, -.906 ); 
    $bins = 4;
};

#####################################################################################################

########################

## MORE SHIBATA EDITS:

#Temporary workspace.

###########################################################################

## New Code ##########################

###############################

## Red line group:
if ($group eq "shibata1") {
    @p = qw( pip );
    @Tgt = qw( C Cu Pb );
    @nrg = ( 3862.86 );
    @dp = qw( p );
    @ang = ( 30, 45, 60, 75, 90, 120 );
    @cthmin = ( 0.819 , 0.643 , 0.423, 0.174, -0.087 , -0.574 );
    @cthmax = ( 0.906 , 0.766 , 0.574, 0.342, 0.087, -0.423 );
    $bins = 4;
};

## Yellow line group:
if ($group eq "shibata2") {
    @p = qw( p );
    @Tgt = qw( C Cu Pb );
    @nrg = ( 3170.3 );
    @dp = qw( p );
    @ang = ( 30, 45, 60, 75, 90, 120 );
    @cthmin = ( 0.819 , 0.643 , 0.423, 0.174, -0.087 , -0.574 );
    @cthmax = ( 0.906 , 0.766 , 0.574, 0.342, 0.087, -0.423 );
    $bins = 4;
};

## Blue line group:
if ($group eq "shibata3") {
    @p = qw( p );
    @Tgt = qw( Cu );
    @nrg = ( 1732.0 , 747.063 );
    @dp = qw( p );
    @ang = ( 30, 45, 60, 75, 90, 120 );
    @cthmin = ( 0.819 , 0.643 , 0.423, 0.174, -0.087 , -0.574 );
    @cthmax = ( 0.906 , 0.766 , 0.574, 0.342, 0.087, -0.423 );
    $bins = 4;
};

## Violet line group:
if ($group eq "shibata4") {
    @p = qw( pip );
    @Tgt = qw( Cu );
    @nrg = ( 2364.32 , 1267.37 );
    @dp = qw( p );
    @ang = ( 30, 45, 60, 75, 90, 120 );
    @cthmin = ( 0.819 , 0.643 , 0.423, 0.174, -0.087 , -0.574 );
    @cthmax = ( 0.906 , 0.766 , 0.574, 0.342, 0.087, -0.423 );
    $bins = 4;
};

## Red dash group:
if ($group eq "shibata5") {
    @p = qw( pip );
    @Tgt = qw( Cu );
    @nrg = ( 2863.67 );
    @dp = qw( n  );
    @ang = ( 60 );
    @cthmin = ( 0.423 );
    @cthmax = ( 0.574 );
    $bins = 4;
};

## Yello dash group:
if ($group eq "shibata6") {
    @p = qw( p );
    @Tgt = qw( Al C Cu );  ##Removed Ag
    @nrg = ( 11098.4 );
    @dp = qw( pip  );
    @ang = ( 90 );
    @cthmin = ( -0.087 );
    @cthmax = ( 0.087 );
    $bins = 4;
};

## Blue dash group:
if ($group eq "shibata7") {
    @p = qw( p );
    @Tgt = qw( Al C Cu );
    @nrg = ( 11098.4 );
    @dp = qw( pim  );
    @ang = ( 90 );
    @cthmin = ( -0.087 );
    @cthmax = ( 0.087 );
    $bins = 4;
};

## Violet dash group:
if ($group eq "shibata8") {
    @p = qw( p );
    @Tgt = qw( Ag Al Cu Ta );
    @nrg = ( 11098.4 );
    @dp = qw( p  );
    @ang = ( 90 );
    @cthmin = ( -0.087 );
    @cthmax = ( 0.087 );
    $bins = 4;
};

## Black dash group:
if ($group eq "shibata9") {
    @p = qw( p );
    @Tgt = qw( Cu );
    @nrg = ( 2205.03 );
    @dp = qw( n  );
    @ang = ( 60 );
    @cthmin = ( 0.423 );
    @cthmax = ( 0.574 );
    $bins = 4;
};
if ($group eq "slypen_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 26.5, 50, 72.8 );
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen_c_62.7") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 62.7 );
    @dp = qw( p );
    @ang = ( 20, 40, 60, 130 );
    @cthmin = ( .906, .707, .423, -.707 );
    @cthmax = ( .966, .819, 974, -.574 );  
    $bins = 4;
};
if ($group eq "slypen_fe") {
    @p = qw( n );  
    @Tgt = qw( Fe );
    @nrg = ( 25.5, 49, 62.7 );
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "stamer") {
    @p = qw( p );  
    @Tgt = qw( Al Pb Zr );
    @nrg = ( 256, 800 );
    @dp = qw( n );
    @ang = ( 7.5, 30, 60, 120, 150 );
    @cthmin = ( .98, .82, .45, -.55 , -.92 );
    @cthmax = ( 1, .92, .55, -.45, -.82 ); 
    $bins = 2;
};
if ($group eq "tippawan") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 95.6 );
    @dp = qw( p );
    @ang = ( 20, 40, 60, 80, 100, 120, 140 );
    @cthmin = ( .9205, .8387, .4226, .1045, -.2419, -.588, -.8192 );
    @cthmax = (  .9563, .8988, .5736, .2419, -.1045, -.438, -.7077 ); 
    $bins = 4;
};
if ($group eq "tyren") {
    @p = qw( p );  
    @Tgt = qw( C );
    @nrg = ( 185 );
    @dp = qw( p );
    @ang = ( 3.2 );
    @cthmin = ( .996 );
    @cthmax = ( 1 );  
    $bins = 4;
};
if ($group eq "zumbro") {
    @p = qw( pip );  
    @Tgt = qw( C );
    @nrg = ( 500 );
    @dp = qw( pip );
    @ang = ( 30, 50 );
    @cthmin = ( .82, .59 );
    @cthmax = ( .92, .69 ); 
    $bins = 4;
};

################################################################### Subsets of authors #################################################################################


if ($group eq "mckeown100pip"){
    @p = qw (pip);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (100);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};
if ($group eq "mckeown160pip"){
    @p = qw (pip);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (160);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};
if ($group eq "mckeown220pip"){
    @p = qw (pip);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (220);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};
if ($group eq "mckeown100pim"){
    @p = qw (pim);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (100);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};
if ($group eq "mckeown160pim"){
    @p = qw (pim);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (160);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};
if ($group eq "mckeown220pim"){
    @p = qw (pim);
    @Tgt = qw (Al Be C He Li Ni Ta);
    @nrg = (220);
    @dp = qw(p);
    @ang = ( 30, 45, 90, 120, 150 );
    @cthmin = ( .806, .647, -.060, -.560, -.926 );
    @cthmax = ( .926, .767, .060, -.440, -.806);  
    $bins=4;
};

if ($group eq "slypen26.5_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 26.5);
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen50_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 50);
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen72.8_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 72.8 );
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen62.7_c") {
    @p = qw( n );  
    @Tgt = qw( C );
    @nrg = ( 62.7 );
    @dp = qw( p );
    @ang = ( 20, 40, 60, 130 );
    @cthmin = ( .906, .707, .423, -.707 );
    @cthmax = ( .966, .819, 974, -.574 );  
    $bins = 4;
};
if ($group eq "slypen25.5_fe") {
    @p = qw( n );  
    @Tgt = qw( Fe );
    @nrg = ( 25.5);
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen49_fe") {
    @p = qw( n );  
    @Tgt = qw( Fe );
    @nrg = ( 49);
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "slypen62.7_fe") {
    @p = qw( n );   
    @Tgt = qw( Fe );
    @nrg = ( 62.7 );
    @dp = qw( p );
    @ang = ( 2.5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 177.5 );
    @cthmin = ( .996, .974, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.974, -.996, -1 );
    @cthmax = ( 1, .993, .966, .906, .819, .707, .574, .423, .259, .087, -.087, -.259, -.423, -.574, -.707, -.819, -.906, -.97, -.996 ); 
    $bins = 4;
};
if ($group eq "amian597") {
    @p = qw( p );                              
    @Tgt = qw( B Be C O Pb );                  
    @nrg = ( 597);                       
    @dp = qw( n );                             
    @ang = ( 30, 60, 120, 150 );               
    @cthmin = ( .82, .45, -.55, -.92 );        
    @cthmax = ( .92, .55, -.45, -.82 );        
    $bins = 4;                                 
};
if ($group eq "amian800") {
    @p = qw( p );                              
    @Tgt = qw( B Be C O Pb );                  
    @nrg = ( 800);                       
    @dp = qw( n );                             
    @ang = ( 30, 60, 120, 150 );               
    @cthmin = ( .82, .45, -.55, -.92 );        
    @cthmax = ( .92, .55, -.45, -.82 );        
    $bins = 4;                                 
};
if ($group eq "cochran_al") {
    @p = qw( p );  
    @Tgt = qw( Al);
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
if ($group eq "cochran_be") {
    @p = qw( p );  
    @Tgt = qw( Be);
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
if ($group eq "cochran_c") {
    @p = qw( p );  
    @Tgt = qw( C);
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
if ($group eq "cochran_cu") {
    @p = qw( p );  
    @Tgt = qw(Cu);
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
if ($group eq "cochran_pb") {
    @p = qw( p );  
    @Tgt = qw( Pb );
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 ); 
    $bins = 10;
};
if ($group eq "cochran_d") {
    @p = qw( p );  
    @Tgt = qw( D);
    @nrg = ( 730 );
    @dp = qw( pim pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90);
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1);
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1); 
    $bins = 10;
};
if ($group eq "cochran_hpim") {
    @p = qw( p );  
    @Tgt = qw( H );
    @nrg = ( 730 );
    @dp = qw( pim );
    @ang = ( 15, 20, 30, 120, 150 );
    @cthmin = ( .956, .935, .846, -.6, -.886 );
    @cthmax = ( .976, .955, .886, -.4, -.846 );  
    $bins = 10;
};
if ($group eq "cochran_hpip") {
    @p = qw( p );  
    @Tgt = qw( H );
    @nrg = ( 730 );
    @dp = qw( pip );
    @ang = ( 15, 20, 30, 45, 60, 75, 90, 105, 120, 135, 150 );
    @cthmin = ( .956, .935, .846, .657, .4, .159, -.1, -.359, -.6, -.757, -.886 );
    @cthmax = ( .976, .955, .886, .757, .6, .359, .1, -.159,-.4, -.657, -.846 );  
    $bins = 10;
};

foreach $tgt (@Tgt) {
    foreach $probe (@p) {
       foreach $det (@dp) {
           foreach $energy (@nrg) {
              set_particles();
              set_file_names();
              make_format_file();
              make_png_files();
          };
      };
  };
};
};
};

###############################################################################################################################################################
###############################################################################################################################################################

### TOTAL CROSS SECTION ROUTINE ###

if ($type eq 'totxs') {

(@authors) ? ($defaults = 'no') : ($defaults = 'yes');  ## use defaults if user did not define authors
if ($defaults eq 'yes') {
    if ($probe eq 'p') {
# sd	if ($tgt eq 'c') {@authors = qw(dietrich dicelloBAD various auce)};
if ($tgt eq 'c') {
 if ($subtype eq 'reac') {
         @authors = qw(various);
          } else {

          };
}; # various
if ($tgt eq 'c12'){@authors=qw(auce)};
	if ($tgt eq 'pb'){@authors=qw(various)}; #includes auce, carlson, ingam
	if ($tgt eq 'pb208') {@authors = qw(auce carlson)};
	if ($tgt eq 'ca') {@authors = qw(auce carlson)};
	if ($tgt eq 'ca40'){@authors =qw(auce carlson)};
	if ($tgt eq 'ca42'){@authors =qw(carlson)};
	if ($tgt eq 'ca44'){@authors =qw(carlson)};
	if ($tgt eq 'ca48'){@authors =qw(carlson)};
	if ($tgt eq 'fe') {@authors = qw(various)};
	if ($tgt eq 'fe54'){@authors = qw(carlson)}; 
	if ($tgt eq 'fe56'){@authors = qw(carlson)};
    if ($tgt eq 'fe56'){@authors = qw(mashnik)};
	if ($tgt eq 'fe57'){@authors = qw(carlson)};
	if ($tgt eq 'fe58'){@authors =qw(carlson)};
	if ($tgt eq 'sn') {@authors=qw(carlson)};
	if ($tgt eq 'sn112'){@authors=qw(carlson)};
	if ($tgt eq 'sn114'){@authors=qw(carlson)};
	if ($tgt eq 'sn116'){@authors=qw(carlson)};
	if ($tgt eq 'sn117'){@authors=qw(carlson)};
	if ($tgt eq 'sn118'){@authors=qw(carlson)};
	if ($tgt eq 'sn119'){@authors=qw(carlson)};
	if ($tgt eq 'sn120'){@authors=qw(carlson)};
	if ($tgt eq 'sn122'){@authors=qw(carlson)};
	if ($tgt eq 'sn124'){@authors=qw(carlson)};
	if ($tgt eq 'cu') {@authors = qw(dietrich)};
	if ($tgt eq 'ni') {@authors = qw(auce menet)};
    if ($tgt eq 'au') {@authors = qw(uozumi)};
    if  ($tgt eq 'n') {@authors = qw(rowntree )};
    if ($tgt eq 'ar') {
         #   if ($subtype eq 'abs'){@authors = qw(rowntree kotlinski )};
};
    if ($tgt eq 'xe') {@authors = qw(rowntree )};
    if  ($tgt eq 'n') {@authors = qw(kotlinski )};
    if ($tgt eq 'xe') {@authors = qw(kotlinski )};
};
if ($probe eq 'n') {
	if ($tgt eq 'cu') {@authors = qw(voss)};
	if ($tgt eq 'c') {
       if ($subtype eq 'total') {@authors = qw(abfalterer)};
# sd	    if ($subtype eq 'reac') {@authors = qw(ibaraki schimmerling voss zanelli various adal rogers)};
if ($subtype eq 'reac') {@authors = qw(various)};
};
if ($tgt eq 'fe') {
   if ($subtype eq 'total') {@authors = qw(abfalterer)};
# sd	    if ($subtype eq 'reac') {@authors = qw(ibaraki schimmerling zanelli various)};
if ($subtype eq 'reac') {@authors = qw(various)};
};
	if ($tgt eq 'fe56'){@authors =qw(beyer negret)};  #inelastic gammas
	if ($tgt eq 'c12'){@authors =qw(adal rogers)}; #inelastic gamma
	if ($tgt eq 'pb') {
       if ($subtype eq 'total') {@authors = qw(abfalterer)};
# sd	    if ($subtype eq 'reac') {@authors = qw(schimmerling voss)};   
if ($subtype eq 'reac') {@authors = qw(various)};   
};
}

if ($probe eq 'pip') {
	if ($tgt eq 'al') {
       if ($subtype eq 'reac') {
          @authors = qw(allardyce ashery);
          } else {@authors = qw(ashery)};
      };
      if ($tgt eq 'bi') {@authors = qw(ashery)};
      if ($tgt eq 'c') {
       if ($subtype eq 'total') {
          @authors = qw(ashery clough saunders wilkin);
          } elsif ($subtype eq 'reac') {
            @authors = qw(allardyce ashery meirav saunders); 
# sd		@authors = qw(allardyce ashery meirav saunders);
} else {
@authors = qw(mashnik);
@authors = qw(ashery);
#@authors = qw(rowntree);
    #@authors = qw();
};
};
if ($tgt eq 'fe') {
    #@authors = qw(mashnik);
    @authors = qw(ashery);
};
if ($tgt eq 'ar') {
    #@authors = qw(rowntree kotlinski); #rowntree kotlinski
   # @authors = qw(kotlinski);
};
if ($tgt eq 'li') {
   if ($subtype eq 'total') {
      @authors = qw(ashery clough);
      } else {@authors = qw(ashery)};
  };
  if ($tgt eq 'nb') {@authors = qw(ashery)};
  if ($tgt eq 'ca') {@authors = qw(allardyce meirav)};
  if ($tgt eq 'ni' || $tgt eq 'pb' || $tgt eq 'sn') {@authors = qw(allardyce)};
  if ($tgt eq 'be' || $tgt eq 'li6') {@authors = qw(clough)};
  if ($tgt eq 'o') {
   if ($subtype eq 'total') {
      @authors = qw(clough);
      } elsif ($subtype eq 'reac') {
          @authors = qw(meirav);
      }
  };
  if ($tgt eq 'zr') {@authors = qw(meirav)};
  if ($tgt eq 'pb') {
   if ($subtype eq 'reac') {
      @authors = qw(allardyce);
  }
}
};

if ($probe eq 'pim') {
	if ($tgt eq 'al') {
       if ($subtype eq 'reac') {
          @authors = qw(allardyce ashery);
          } else {@authors = qw(ashery)};
      };
      if ($tgt eq 'bi' || $tgt eq 'fe' || $tgt eq 'nb') {@authors = qw(ashery)};
      if ($tgt eq 'c') {
       if ($subtype eq 'total') {
          @authors = qw(ashery clough gelderloos wilkin);
          } elsif ($subtype eq 'reac') {
# sd		@authors = qw(allardyce ashery gelderloos meirav);
@authors = qw(various);
} else {@authors = qw(ashery)};
};
if ($tgt eq 'li') {
   if ($subtype eq 'total') {
      @authors = qw(ashery clough);
      } else {@authors = qw(ashery)};
  };
  if ($tgt eq 'ca') {@authors = qw(allardyce meirav)};
  if ($tgt eq 'ni' || $tgt eq 'sn') {@authors = qw(allardyce)};
  if ($tgt eq 'pb') {
   if ($subtype eq 'reac') {@authors = qw(allardyce gelderloos)};
   if ($subtype eq 'total') {@authors = qw(gelderloos)};
};
if ($tgt eq 'be' || $tgt eq 'li6') {@authors = qw(clough)};
if ($tgt eq 'o') {
   if ($subtype eq 'total') {@authors = qw(clough)};
   if ($subtype eq 'reac') {@authors = qw(meirav)};
};
if ($tgt eq 'cu') {@authors = qw(gelderloos)};
if ($tgt eq 'zr') {@authors = qw(meirav)};
};
if ($probe eq 'km') {@authors = qw(bugg)};
if ($probe eq 'kp') {
	if ($tgt eq 'c') {
       if ($subtype eq 'total') {@authors = qw(bugg friedman)};
       if ($subtype eq 'reac') {@authors = qw(friedman)};
   };
   if ($tgt eq 'ca') {
       if ($subtype eq 'reac') {@authors = qw(friedman)};
       if ($subtype eq 'total') {@authors = qw(friedman krauss)};
   };
   if ($tgt eq 'si') {@authors = qw(friedman)};
   if ($tgt eq 'd') {
       if ($subtype eq 'reac') {@authors = qw(friedman)};
       if ($subtype eq 'total') {@authors = qw(friedman krauss)};
   };
   if ($tgt eq 'li6') {@authors = qw(friedman)};
};
};

set_particles();
set_file_names();
make_format_file();
make_png_files();
};
###############################################################################################################################################################
###############################################################################################################################################################

### SUBROUTINES ###

## Subroutine to check that input is valid ##

sub check_input {
    $GENIE = $ENV{"GENIE"};
    if ($GENIE eq '') {error_exit_g();}
    if ($type eq 'totxs') {
       error_exit("type of cross section") unless defined $st;
       error_exit("horizontal max") unless defined $hmax;
       error_exit("vertical max") unless defined $vmax;
   };
   if ($type eq 'ang' || $type eq 'nrg') {error_exit("author") unless defined $author};
    %author_hash = (                 ## 1 means nrg_dist data, 2 means nrg_dist data and ang_dist data
        'amian' => '1', 
        'baker' => '1',
        'beck' => '1',
        'crawford'=>'1',
        'bertrand' => '1',
        'letourneau'=>'1',
        'abertrand'=>'1',
        'abertrand_28'=>'1',
        'abertrand_61'=>'1',
        'sanami_h2'=>'1',
        'sanami_h3'=>'1',
        'fidelus'=>'1',
        'watanabe'=>'1',
        'machner'=>'1',
        #'fidelus_19'=>'1',
        #'fidelus_25'=>'1',
        'sanami'=>'1',
        'nica'=>'1',
        'benck'=>'1',
        'uozumi'=>'1',
        'uozumi_c' => '1',
        'uozumi_al' => '1',
        'uozumi_nb' => '1',
        'uozumi_au' => '1',
        'uozumi_AAl'=>'1',
        'carman' => '1',
        'chen' => '1',
        'bertrand'=>'2',
        'cochran' => '2',
        'benck'=>'2',
        'franz' => '1',
        'hautala' => '2',
        'hayashi' => '1',
        'ingram' => '2',
        'iwamoto' => '1',
        'kin' => '1',
        'kormanyos' => '1',
        'ledoux' => '1',
        'levenson' => '2',
        'levenson_100' => '2',
        'levenson_160' => '2',
        'levenson_220' => '2',
        'mcgill' => '1',
        'mckeown' => '2',
        'mckshort' => '2',
        'meier' => '1',
        'otsu' => '1',
        'ouyang' => '1',
        'roy' => '1',
        'segel' =>'1',
        'shibata' => '1',
        'shibata_p' => '1',
        'shibata_pi' => '1',
        'slypen' => '1',
        'stamer' => '1',
        'tippawan' => '1',
        'tyren' => '1',
        'zumbro' => '1',
################################################################### Subsets of authors #################################################################################
'mckeown100pip' => '2',
'mckeown160pip' => '2',
'mckeown220pip' => '2',

'mckeown100pim' => '2',
'mckeown160pim' => '2',
'mckeown220pim' => '2',


'slypen26.5' => '1',
'slypen50' => '1',
'slypen62.7' => '1',
'slypen72.8' => '1',
'slypen25.5' => '1',
'slypen49' => '1', 

'amian597' => '1',
'amian800' => '1',

'cochran_be' => '1',
'cochran_c' => '1',
'cochran_cu' => '1',
'cochran_d' => '1',
'cochran_h' => '1',
'cochran_pb' => '1',
'cochran_al' => '1',

'benck_h2'=>'2',
'benck_h3'=>'2',
'benck_he4'=>'2',
);


    $valid_author = $author_hash {$author};
    if ($type eq 'ang' && $valid_author ne '2') {error_exit("author")};
    if ($type eq 'nrg' && $valid_author ne '1' && $valid_author ne '2') {error_exit("author")};
    error_exit("date of root file") unless defined $dorf[0];
    %author_hash_2 = (           ## 3 means total cross section data
        'abfalterer' => '3', 
        'aniol' => '3',
        'ashery' => '3',
        'mashnik'=>'3',
        'rowntree'=>'3',
        ' kotlinski'=>'3',
               # ' kotlinski_2p'=>'3',
        'auce' => '3',
        'bauhof' => '3',
        'beyer' => '3',
        'dicello' => '3',
        'makinoandmenet' => '3',
        'makino'=>'3',
        'menet'=>'3',
        'mashnik'=>'3',
        'renberg'=>'3',
        'bowles' => '3',
        'mcgill'=>'3',
        'brinkmoller' => '3',
        'carlson' =>'3',
        'dietrich' => '3',
        'ibaraki' => '3',
        'lehmann' => '3',
        'navon' => '3',
        'negret' => '3',
        'schimmerling' => '3',
        'various'=>'3',
        'Geant' =>'3',
        'voss' => '3',
        'zanelli' => '3',
        'macgregor' => '3',
        'bugg' => '3', 
        'friedman' => '3',
        'krauss' => '3',
        'allardyce' => '3',
        'clough' => '3',
        'gelderloos' => '3',
        'meirav' => '3',
        'saunders' => '3',
        'wilkin' => '3',
        'adal' => '3',
        'rogers' => '3'
        );
    $valid_author_2 = $author_hash_2 {$author};
    if ($type eq 'totxs' && $authors[0] && $valid_author_2 ne '3') {error_exit("author")};
    if ($type ne 'ang' && $type ne 'nrg' && $type ne 'totxs') {error_exit("type")};

    ($prepend eq 'yes') ? ($a_name = "$author\_") : ($a_name = "");
};

## Subroutine to set defaults ##

sub set_defaults {
    if ($modes[0]) {$modes[0] = lc($modes[0]);}
    if ($modes[1]) {$modes[1] = lc($modes[1]);}
    if ($modes[2]) {$modes[2] = lc($modes[2]);}
    if ($st) {$st = lc($st)};
    %st_hash = ('r' => 'reac', 'reac' => 'reac', 'reaction' => 'reac', 'rxn' => 'reac', 't' => 'total', 'tot' => 'total', 'total' => 'total', 'cex' => 'cex', 'elas' => 'elas', 'el' => 'elas', 'inel' => 'inelas', 'inelas' => 'inelas', 
      'abs' => 'abs', 'ko' => 'ko', 'knockout' => 'ko', 'k-o' => 'ko', 'pipro' => 'pipro'); 
    $subtype = $st_hash{$st};
    %sbtp_hash = ('reac' => 'reac', 'total' => 'total', 'cex' => 'cex', 'elas' => 'el', 'inelas' => 'inel', 'abs' => 'abs', 'ko' => 'ko', 'pipro' => 'pipro');
    $sbtp = $sbtp_hash{$subtype};
    if ($tgt) {$tgt = lc($tgt)}; if ($probe) {$probe = lc($probe)};
    if ($dorf[0]) {$dorf[0] = ucfirst(lc($dorf[0]))};
    if ($dorf[1]) {$dorf[1] = ucfirst(lc($dorf[1]))};
    if ($dorf[2]) {$dorf[2] = ucfirst(lc($dorf[2]))};
    $author = lc($author); $Author = ucfirst($author);
    $png = lc($png); $remove = lc($remove);
    if ($datadir) {$datadir =~ s|/$||};     ## if datadir is defined, remove any trailing slash
    if ($rootdir) {$rootdir =~ s|/$||};     ## if rootdir is defined, remove any trailing slash
    if ($pngdir) {$pngdir =~ s|/$||};       ## if pngdir is defined, remove any trailing slash
    
    if (!(@mdl)) {                          ## if user doesn't specify @mdl...
    if (@modes) {
	    @mdl = qw( xx );                ## ...but does specify @modes, set @mdl to dummy value
       } else {
	    @mdl = qw( ha hn hincl ha2018 hn2018 hg4bc hg4bertcasc geant);             ## else assume hA and hN
	}
}

    if (defined $vsn[0] != 1) {              ## is user doesn't specify GENIE version...
	if ($GENIE =~ m/devel/i) {           ## if $GENIE contains "devel" (regardless of case)
   $version = 'DEVEL';
   @vsn = ('DEVEL');
	} elsif (!($GENIE =~ m/\d/)) {       ## if $GENIE contains no digits
       @vsn = ('280');
       } else {
	    @nums = ($GENIE =~ m/(\d+)/g);   ## extract the digits from $GENIE
	    $v_num = join("",@nums);
	    @vsn = ("$v_num");
	}
}
    if ($vsn[0] == 266 || $vsn[1] == 266 || $vsn[2] == 266) {@mdl = qw( hA )};  ## eliminate hN if using v2.6.6
    if (($vsn[1]) && ($dorf[1] eq '')) {$dorf[1] = $dorf[0]};  ## assume date of second group of root files is same as first if user does not specify
    if (($vsn[2]) && ($dorf[2] eq '')) {$dorf[2] = $dorf[0]};  ## assume date of third group of root files is same as first if user does not specify
    $datadir = "data_files" unless defined $datadir;           ## default directory to find data files is present working directory
    $rootdir = "root_files" unless defined $rootdir;           ## default directory to find root files is pwd
    $pngdir = "png_files"   unless defined $pngdir;            ## default directory to put png files is png_files directory within pwd

    print "Output files will be placed in this directory: $pngdir\n";
    if (!(-e $pngdir)) {
       print "This directory ($pngdir) does not exist. Building it now.\n"; 
       system("mkdir -p $pngdir");
       if (-e $pngdir) {
           print "The directory ($pngdir) has been built.\n";
           } else {
               die("Could not find and could not build target directory ($pngdir).\n");
           }
       }

    $err_system = 'ni'      unless defined $err_system;        ## default error system (non-interactive)
};

## Subroutine to set detected particles ##

sub set_particles {
    %dp_hash = ('pip' => '211', 'pim' => '-211', 'pi0' => '111', 'p' => '2212', 'n' => '2112', 'h2' => '1000010020','h3' => '1000010030','he3' => '1000020030','he4' => '1000020040','kp' => '321', 'km' => '-321', 'k0' => '311', 'ak0' => '-311', 'mup' => '-13', 'mum' => '13');
    $dppdg = $dp_hash{$det};  ## detected particle pdg code
    %particle_hash = ('pip' => '#pi+', 'pim' => '#pi-', 'pi0' => '#pi0', 'p' => 'p', 'n' => 'n', 'h2'=>'h2', 'h3'=>'h3','he3'=>'he3','he4'=>'he4','he'=>'he4','kp' => 'k+', 'km' => 'k-', 'k0' => 'k0', 'ak0' => 'anti-k0', 'mup' => '#mu+', 'mum' => '#mu-');
    $detected = $particle_hash{$det};  ## detected particle as written in title
    $prbpart = $particle_hash{$probe};  ## probe particle as written in title
    %dpm_hash = ('pip' => '.1396', 'pim' => '.1396', 'pi0' => '.1350', 'p' => '.9383', 'h2'=>'1.8756129','h3'=>'2.8089211','he3'=>'2.8083915','he4'=>'3.7273793','n' => '.9396', 'kp' => '.4937', 'km' => '.4937', 'k0' => '.4976', 'ak0' => '.4976', 'mup' => '.1057', 'mum' => '.1057');
    $dpm = $dpm_hash{$det};  ## detected particle mass in GeV/c^2
};
###############3 Masse Particle alpha
#1.8756129"," 2.8089211","2.8083915","3.7273793"
## Subroutine to set names of files ##


#%ns_hash = qw(
#levenson_100 levenson
#);


sub set_file_names {
    $tgt = lc($tgt);
    ($tgt eq 'h2o') ? ($Tgt = 'H2O') : ($Tgt = ucfirst($tgt));
    $vname1 = "-$vsn[0]";
    #$ns_hash = (
    #'levenson_100'=>'levenson',
    #);
    ($vsn[1]) ? ($vname2 = "vs$vsn[1]") : ($vname2 = "");
    ($vsn[2]) ? ($vname3 = "vs$vsn[2]") : ($vname3 = "");
    $mdl[0] = lc($mdl[0]);
    if ($mdl[1]) {$mdl[1] = lc($mdl[1])};
    if ($mdl[2]) {$mdl[2] = lc($mdl[2])}; 
    if ($group =~ /^levenson*/){$author='levenson'};  ##This is not the proper way to do this, but works temporarily, at least
    if ($group =~ /^mckeown*/){$author ='mckeown'};
    if ($group=~ /^slypen*/){$author='slypen'};
    if ($group=~ /^amian*/){$author='amian'};
    if ($group=~/^cochran*/){$author='cochran'};
    if ($group=~/^bertrand*/){$author='bertrand'};
    if ($group=~/^benck*/){$author='benck'};
    #ns_hash = ('levenson_100'=>'levenson');
    if ($type eq 'ang') {$formatfilename = "fg-$author-$probe-$tgt-$det$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]$tag1$tag2"; $datafile = "$author-$probe-$tgt-$energy-$det-angdist.dat"};
    if ($type eq 'nrg') {$formatfilename = "fg-$author-$probe-$tgt-$energy-$det$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]$tag1$tag2"; $datafile = "$author-$probe-$tgt-$energy-$det-$angle.dat"}; 
    if ($type eq 'totxs') {$formatfilename = "fg-$probe-$tgt-$subtype$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]$tag1$tag2"; $datafile = "$author-$probe-$tgt-$subtype.dat"};
    %iso_hash = ('h' => 'h1', 'd' => 'h2','t'=>'h3', 'he3'=>'he3', 'he' => 'he4', 'li' => 'li7', 'li6' => 'li6', 'be' => 'be9', 'b' => 'b11', 'c' => 'c12', 'n' => 'n14', 'o' => 'o16', 'al' => 'al27', 'ca' => 'ca40','fe' => 'fe56', 
       'co' => 'co59', 'ni' => 'ni58', 'cu' => 'cu63', 'zr' => 'zr90', 'nb' => 'nb93', 'sn' => 'sn120', 'ta' => 'ta181', 'au'=>'Au','pb' => 'pb208', 'bi' => 'bi209');
    $isotope = $iso_hash{$tgt};
    $datafilename = "$datadir/$datafile";
    $dataerror = 0 unless defined $dataerror; $rooterror = 0 unless defined $rooterror; 
    if (!-e $datafilename) {$dataerror++};
};

## Subroutine to set name of root file ##

sub set_root_file_name {
    $date = $dorf[$_[0]];
    %mM_hash = ('ha' => 'hA', 'hn' => 'hN', 'ha2014' => 'hA2014', 'hn2014' => 'hN2014', 'ha2014' => 'hA2014', 'ha2015' => 'hA2015', 'hn2015' => 'hN2015' ,'GEANTS'=>'geant','geant'=>'GEANTS','GEANTS'=>'GEANTS', 'hg4bertcasc'=>'HG4BertCasc','hn2015nncorr-on' => 'hN2015NNCorr-on', 'hA2015nncorr-on' => 'hA2015NNCorr-on', 'hn2014nncorr-on' => 'hN2014NNCorr-on' , 'ha2014nncorr-on' => 'hA2014NNCorr-on'   , 'hn2015oset-on' => 'hN2015Oset-on','hn2014oset-on' => 'hN2014Oset-on', 'ha2014oset-on' => 'hA2014Oset-on', 'ha2015oset-on' => 'hA2015Oset-on' , 'hn2015oset-off' => 'hN2015Oset-off', 'ha2018' => 'hA2018', 'hn2018' => 'hN2018', 'hA2018'=>'hA2018', 'hN2018'=>'hN2018' , 'hincl' =>'HINCL', 'HINCL'=>'HINCL','hg4bc'=>'hG4BC', 'HG4BC'=>'hG4BC','hG4BC'=>'hG4BC');
    $mM = $mM_hash{$m};
    if ($v eq 'DEVEL' || $v eq 'DB') {$vee = '';} else {$vee = 'v';}
    if ($type eq 'ang' || $type eq 'nrg') {$rootfile = "$a_name$date\_$probe\_$Tgt\_$energy\_$vee$v\_$mM$tag1$tag2.ginuke.root"};
    if ($type eq 'totxs') {$rootfile = "$a_name$date\_$probe\_$Tgt\_totxs_$vee$v\_$mM$tag1$tag2.txt"};
    print "root file to be used = $rootfile \n" ;
    $rootfilename = "$rootdir/$rootfile";
    %version_hash = ('282' => '2.8.2', '280' => '2.8.0', '271' => '2.7.1', '266' => '2.6.6', 'DEVEL' => 'DEVEL', 'DB' => 'DB', '290' => '2.9.0', '210' => '2.10.0', '304' => '3.0.4');
    if (defined $version_hash{$v}) {
       $version = $version_hash{$v};
       } else {
           $version = $v;
       }
       if (!-e $rootfilename) {$rooterror++};
   };

## Subroutine to set name of png file ##

sub set_outfile_name {
    if ($type eq 'ang' && $tag1 eq '' && $tag2 eq '') {$outfile = "$author-$probe-$tgt-$energy-$det-angdist$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]"};
    if ($type eq 'ang' && $tag1 ne '' && $tag2 eq '') {$outfile = "$author-$probe-$tgt-$energy-$det-angdist$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag1"};  
    if ($type eq 'ang' && $tag1 eq '' && $tag2 ne '') {$outfile = "$author-$probe-$tgt-$energy-$det-angdist$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag2"};
    if ($type eq 'ang' && $tag1 ne '' && $tag2 ne '') {$outfile = "$author-$probe-$tgt-$energy-$det-angdist$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag1-$tag2"};

    if ($type eq 'nrg' && $tag1 eq '' && $tag2 eq '') {$outfile = "$author-$probe-$tgt-$energy-$det-$angle$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]"};
    if ($type eq 'nrg' && $tag1 ne '' && $tag2 eq '') {$outfile = "$author-$probe-$tgt-$energy-$det-$angle$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag1"};  
    if ($type eq 'nrg' && $tag1 eq '' && $tag2 ne '') {$outfile = "$author-$probe-$tgt-$energy-$det-$angle$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag2"};
    if ($type eq 'nrg' && $tag1 ne '' && $tag2 ne '') {$outfile = "$author-$probe-$tgt-$energy-$det-$angle$vname1$vname2$vname3$vname4$vname5$vname6-$mdl[0]$mdl[1]$mdl[2]$mdl[3]$mdl[4]$mdl[5]$mdl[6]-$dorf[0]-$tag1-$tag2"};

    if ($type eq 'totxs' && $tag1 eq '' && $tag2 eq '') {$outfile = "$probe-$tgt-$subtype$vname1$vname2$vname3-$mdl[0]$mdl[1]$mdl[2]-$dorf[0]"};
    if ($type eq 'totxs' && $tag1 ne '' && $tag2 eq '') {$outfile = "$probe-$tgt-$subtype$vname1$vname2$vname3-$mdl[0]$mdl[1]$mdl[2]-$dorf[0]-$tag1"};  
    if ($type eq 'totxs' && $tag1 eq '' && $tag2 ne '') {$outfile = "$probe-$tgt-$subtype$vname1$vname2$vname3-$mdl[0]$mdl[1]$mdl[2]-$dorf[0]-$tag2"};
    if ($type eq 'totxs' && $tag1 ne '' && $tag2 ne '') {$outfile = "$probe-$tgt-$subtype$vname1$vname2$vname3-$mdl[0]$mdl[1]$mdl[2]-$dorf[0]-$tag1-$tag2"};
};

## Subroutine to make format file ##

sub make_format_file {

    clear_values();

    if ($type eq 'ang') {
       if (-e $formatfilename) {unlink("$formatfilename")};
       open (File, ">> $formatfilename");
       foreach $energy (@nrg) {
           print File "[RECORD]\n";
           set_file_names();
           set_domain_and_range();
           print File " -1.,1.,0,$max_vert\n";
           print File " Angle\n";
           print File " $prbpart $Tgt #rightarrow $detected X T$prbpart = $energy MeV\n";
           set_outfile_name();
           print File " $outfile\n";
           print File " $bins\n";
           print File "[EXPERIMENTAL]\n";
           print File " $datafile\n";
           print File " xsec:TMath::Cos(cth*.01745):err1\n";
           print File " $energy MeV $Author $Tgt Data (ang dist)\n";
           for my $i (0 .. $#vsn) {
              $v = $vsn[$i];
              set_models($i);
              foreach $m (@mdl) {
                  set_root_file_name($i);
                  print File "[GENIE]\n";
                  print File " $rootfile\n";
                  print File " cth\n";
                  print File " pdgh==$dppdg";
                  if ($author eq 'mckeown' && $Tgt ne 'He') {print File "&&ph>=.27688";}
                  if ($author eq 'mckeown' && $Tgt eq 'He') {print File "&&ph>=.36913";}
                  print File "\n 1\n";
                  %mM_hash = ('ha' => 'hA', 'hn' => 'hN', 'ha2014' => 'hA2014', 'hn2014' => 'hN2014', 'ha2015' => 'hA2015', 'hn2015' => 'hN2015','GEANTS'=>'geant','geant'=>'GEANTS','GEANTS'=>'GEANTS', 'hincl'=>'HINCL','hg4bertcasc'=>'HG4BertCasc','HINCL'=>'HINCL','HG4BC'=>'hG4BC','hg4bc'=>'HG4BC','hn2018'=>'hN2018','hN2018'=>'hN2018','ha2018'=>'hA2018','hA2018'=>'hA2018' ,'hn2015nncorr-on' => 'hN2015NNCorr-on', 'hA2015nncorr-on' => 'hA2015NNCorr-on', 'hn2014nncorr-on' => 'hN2014NNCorr-on' , 'ha2014nncorr-on' => 'hA2014NNCorr-on'   , 'hn2015oset-on' => 'hN2015Oset-on','hn2014oset-on' => 'hN2014Oset-on', 'ha2014oset-on' => 'hA2014Oset-on', 'ha2015oset-on' => 'hA2015Oset-on', 'hn2015oset-off' => 'hN2015Oset-off'  ); $mM = $mM_hash{$m};
                  print File " GENIE $version $mM results\n";
              };
              unset_models();
          };
          print File "\n\n";
      };
      close (File);
  };


  if ($type eq 'nrg') {
   if (-e $formatfilename) {unlink("$formatfilename")};
   open (File, ">> $formatfilename");
   $i = 0;
   foreach $angle (@ang) {
       print File "[RECORD]\n";
       set_file_names();
       set_domain_and_range();
       print File " $domain,$range\n";
       print File " Energy\n";
       print File " $prbpart $Tgt #rightarrow $detected X T$prbpart = $energy MeV\n";
       set_outfile_name();
       print File " $outfile\n";
       print File " $bins\n";
       print File "[EXPERIMENTAL]\n";
       print File " $datafile\n";
       print File " xsec:E:err1\n";
       print File " $energy MeV $Author $Tgt Data ($angle deg)\n";
       for my $vsn_index (0 .. $#vsn) {
          $v = $vsn[$vsn_index];
          set_models($vsn_index);
          foreach $m (@mdl) {
              set_root_file_name($vsn_index);
              print File "[GENIE]\n";
              print File " $rootfile\n";
              print File " (Eh-$dpm)*1000\n";
              print File " pdgh==$dppdg&&cth>=$cthmin[$i]&&cth<=$cthmax[$i]&&probe_fsi>1\n";
              $diff = sprintf('%.4f', ($cthmax[$i] - $cthmin[$i]));
              print File " $diff\n";
              %mM_hash = ('ha' => 'hA', 'hn' => 'hN', 'ha2014' => 'hA2014','GEANTS'=>'geant','geant'=>'GEANTS','GEANTS'=>'GEANTS', 'hn2014' => 'hN2014', 'ha2015' => 'hA2015', 'hn2015' => 'hN2015','hg4bertcasc'=>'HG4BertCasc','hn2018'=>'hN2018','hN2018'=>'hN2018','ha2018'=>'hA2018','hA2018'=>'hA2018', 'hn2015nncorr-on' => 'hN2015NNCorr-on', 'hA2015nncorr-on' => 'hA2015NNCorr-on', 'hn2014nncorr-on' => 'hN2014NNCorr-on' , 'ha2014nncorr-on' => 'hA2014NNCorr-on'   , 'hn2015oset-on' => 'hN2015Oset-on','hn2014oset-on' => 'hN2014Oset-on', 'ha2014oset-on' => 'hA2014Oset-on', 'ha2015oset-on' => 'hA2015Oset-on', 'hn2015oset-off' => 'hN2015Oset-off', 'hincl'=>'HINCL',  'HINCL'=>'HINCL', 'hg4bc'=> 'HG4BC','HG4BC'=>'hG4BC'); $mM = $mM_hash{$m};
              print File " GENIE $version $mM results\n";
          };
          unset_models();
      };
      print File "\n\n";
      $i++;
  };
  close (File);
};

if ($type eq 'totxs') {
	if (-e $formatfilename) {unlink("$formatfilename")};
	open (File, ">> $formatfilename");
	$i = 0;
	print File "[RECORD]\n";
	print File " 0,$hmax,0,$vmax\n";
	print File " XS\n";
	print File " $prbpart $Tgt - #sigma $subtype\n";
	set_outfile_name();
	print File " $outfile\n";
	print File " 1\n";
	foreach $author (@authors) {
       set_file_names();
       if (-e $datafilename) {
          print File "[EXPERIMENTAL]\n";
          print File " $datafile\n";
          print File " E:$isotope\x{006e}xs:s$isotope\x{006e}xs\n";
          $Author = ucfirst($author);
          print File " $Author Data\n";
          print File " E:$isotope\x{006e}xs:s$isotope\x{006e}xs/1000.:s$isotope\x{006e}xs\n";
      };
  };
  for my $i (0 .. $#vsn) {
   $v = $vsn[$i];
   set_models($i);
   foreach $m (@mdl) {
      set_root_file_name($i);
      print File "[GENIE]\n";
      print File " $rootfile\n";
      print File " E:und:sund:cex:scex:el:sel:inel:sinel:abs:sabs:ko:sko:pipro:spipro:dcex:sdcex:reac:sreac:total:stotal\n";
      print File " $sbtp:E*1000\n";
      print File " 1\n";
      %mM_hash = ('ha' => 'hA', 'hn' => 'hN', 'ha2014' => 'hA2014', 'hn2014' => 'hN2014', 'ha2015' => 'hA2015', 'hn2015' => 'hN2015' ,'GEANTS'=>'geant','geant'=>'GEANTS','GEANTS'=>'GEANTS','hincl'=>'HINCL','HINCL'=>'HINCL','hg4bc'=>'hG4BC','hG4BC'=>'hG4BC','hg4bertcasc'=>'HG4BertCasc','HG4BC'=>'hG4BC','hN2018'=>'hN2018','hn2018'=>'hN2018','ha2018'=>'hA2018','hA2018'=>'hA2018', 'hn2015nncorr-on' => 'hN2015NNCorr-on', 'hA2015nncorr-on' => 'hA2015NNCorr-on', 'hn2014nncorr-on' => 'hN2014NNCorr-on' , 'ha2014nncorr-on' => 'hA2014NNCorr-on'   , 'hn2015oset-on' => 'hN2015Oset-on','hn2014oset-on' => 'hN2014Oset-on', 'ha2014oset-on' => 'hA2014Oset-on', 'ha2015oset-on' => 'hA2015Oset-on','hn2015oset-off' => 'hN2015Oset-off'  ); $mM = $mM_hash{$m};
      print File " GENIE $version $mM results\n";
  };
  unset_models();
};
};
};

## Subroutine to make png files ##

sub make_png_files {
    ## if ($type eq 'totxs') {$dataerror = 0; $rooterror = 0};
    if ($png ne 'off' && $dataerror > 0) {print "**Did not make png file** (Missing $dataerror data files.)\n"};
    if ($png ne 'off' && $dataerror == 0 && $rooterror > 0) {print "**Did not make png file** (Missing $rooterror root files.)\n"};
    if (($png ne 'off') && ($dataerror == 0) && ($rooterror == 0)) {
       if ($rmode == 1) {
           system "root -l './rootgInukeVal.C(\x{0022}$formatfilename\x{0022},\x{0022}$datadir\x{0022},\x{0022}$rootdir\x{0022},\x{0022}$pngdir\x{0022})'";
           } else {
               system "root -b -q './rootgINukeVal.C(\x{0022}$formatfilename\x{0022},\x{0022}$datadir\x{0022},\x{0022}$rootdir\x{0022},\x{0022}$pngdir\x{0022})'";
           }
           if ($remove eq 'yes') {unlink ("$formatfilename")};
       };
   };


## Subroutine to check for files ##

sub check_for_files {
    $dataerror = 0 unless defined $dataerror; $rooterror = 0 unless defined $rooterror; 
    if (!-e $datafilename) {print "Before: $dataerror   "; $dataerror++; print "After: $dataerror\n"};
    if (!-e $rootfilename) {$rooterror++};
};

## Subroutine to clear values before making new format file ##

sub clear_values {
    undef $dataerror;
    undef $rooterror;
};

## Subroutine to set domain and range ##

sub set_domain_and_range {
    if (-e $datafilename) {
       load_datafile();
       find_max_vert();
       find_max_horiz();
       find_min_vert();
       find_mean_vert();
       determine_scale();
       $domain = "0,$max_horiz";
       if ($rescale) {$max_vert *= $rescale;}
       $range = "$log$min_vert,$max_vert";
       } else {
           print "WARNING: Could not find $datafilename to set plot range!\n";
       };
   };

## Subroutine to find vertical mean in data file ##

sub find_mean_vert {
    $mean_vert = do { my $sum; $sum += $_ for @array; $sum / @array };  ## add up all the elements then divide by the number of elements
    $mean_vert =~ s/\s+$//;  ## put it into a nice format
};

## Subroutine to find vertical maximum in data file ##

sub find_max_vert {
    $max_vert = $sorted[0];  ## take the first element in the sorted array
    $max_vert =~ s/\s+$//;  ## put it into a nice format
    $max2 = $sorted[1];
    $max2 =~ s/\s+$//;
    $max3 = $sorted[2];
    $max3 =~ s/\s+$//;
};

## Subroutine to find maximum energy in data file ##

sub find_max_horiz {
    $max_horiz = 1.1 * $e_sorted[0];  ## set horizontal max to 110% of the maximum energy in the datafile
    $max_horiz =~ s/\s+$//;
};

## Subroutine to find vertical minimum in data file ##

sub find_min_vert {
    @sorted_small_first = sort {$a<=>$b} @array;
    $min_vert = $sorted_small_first[0];
    $min_vert =~ s/\s+$//; $min_vert =~ s/\.$//; $min_vert = $min_vert * 1;  ## trim empty space, remove trailing period, standardize format
    ($min_vert > 0) ? ($min_vert = $min_vert) : ($min_vert = 0);  ## if minimum is negative, regard it as 0
    $min2 = $sorted_small_first[1];
    $min2 =~ s/\s+$//; $min2 =~ s/\.$//; $min2 = $min2 * 1;  
    ($min2 > 0) ? ($min2 = $min2) : ($min2 = 0);  
    $min3 = $sorted_small_first[2];
    $min3 =~ s/\s+$//; $min3 =~ s/\.$//; $min3 = $min3 * 1;
    ($min3 > 0) ? ($min3 = $min3) : ($min3 = 0);
};

## Subroutine to determine scales ##

sub determine_scale {
    $scale = ""; $mid = ""; $median = ""; $ah3= ""; $ratio = ""; $elem = ""; ## clear variables from previous iterations 
    find_mean_vert();  ## find the mean value in the data file
    $elem = @array;  ## assign the number of data points in the data file to a scalar
    if ($elem > 6) {  ## if there are greater than 6 data points, continue
	if ($max_vert > 1.5) {  ## if the max in the data is greater than 1.5, continue
       $mid = sprintf("%.0f",.5*$elem);
	    $median = $array[$mid];  ## find the median in the data
	    $median =~ s/\s+$//;
	    $ah3 = ($max_vert+$max2+$max3)/3;  ## declare a scalar (ah3) that represents the average of the highest three values in the data file
	    ($median == 0) ? ($ratio = 0) : ($ratio = $ah3 / $median);  ## find the ratio of ah3 to the median if the median is nonzero
	    if ($ratio > 13) {  ## if the ratio is greater than 13, set scale to logarithmic
           $scale = "logarithmic";
	    } else { ($max_vert > 10) ? ($scale = "logarithmic") : ($scale = "linear"); };  ## if the ratio is less than 13 but the max is greater than 10, do logarithmic anyway
        } else {$scale = "linear"};  ## if the maximum value was less than 1.5 set scale to linear
    } else { ($max_vert > 10) ? ($scale = "logarithmic") : ($scale = "linear"); };  ## if there were fewer than 7 data points but the max is greater than 10, use logarithmic scale
    if ($type eq 'ang' || $type eq 'totxs') {$scale = "linear"};
    if ($scale eq "logarithmic") {
	$log = "-";  ## include key for logarithmic scale
	$max_vert = 3 * $max_vert;  ## set maximum to triple the max in the data
	((.5 * $min_vert) > (.0003 * $max_vert)) ? ($min_vert = .5 * $min_vert) : ($min_vert = .0003 * $max_vert);  ## set minimum to 1/2 the min in the data OR 3/10000ths the maximum, whichever is greater
};
if ($scale eq "linear") {
	$log = "";  ## do not include logarithmic key
	$max_vert = 1.35 * $max_vert;  ## set maximum to 135% the max in the data
	$min_vert = 0;  ## set minimum to 0
};
};

## Subroutine to load a datafile into an array ##

sub load_datafile {
    local $, = ' ';
    local $\ = "\n";
    open (DATAFILE, "$datafilename");
    open (ARRAY, "> array");
    open (ARRAY_energies, "> array_energies");
    while (<DATAFILE>) {
       ($Fld1,$Fld2,$Fld3) = split(' ', $_, -1);
       if (!/#/) {
	    print ARRAY $Fld2;  ## load all of the cross sections (2nd field) into a filehandle
	    print ARRAY_energies $Fld1;  ## load all of the energies (1st field) into a filehandle
	};
};
close(DATAFILE);
close(ARRAY);
close(ARRAY_energies);
open(NEWARRAY, "array");
    @array = <NEWARRAY>;  ## assign cross sections into an array
    chomp(@array);
    @sorted = sort {$b<=>$a} @array;  ## sort array numerically with largest values first
    close(NEWARRAY);
    unlink(array);
    open(NEWARRAY_energies, "array_energies");
    @e_array = <NEWARRAY_energies>;  ## assign energies into an array
    chomp(@e_array);
    @e_sorted = sort {$b<=>$a} @e_array;
    close(NEWARRAY_energies);
    unlink(array_energies);
};

## Subroutine to set models separately for each version ##

sub set_models {
    my $iteration = $_[0];
    if ($modes[0]) {
       if ($modes[$iteration]) {
           @cur_modes = split(',',$modes[$iteration]);
           } else {
               print "No models specified for this version of GENIE. Using same models as first GENIE version specified.\n";
               @cur_modes = split(',',$modes[0]);
           }
           @mdl = @cur_modes;
       }
   }

## Temporary subroutine to hack my way around a small problem instead of solving it ##

sub unset_models {
    if ($modes[0]) {
       @mdl = qw( xx );
   }
}


## Subroutine for incorrect usage ##

sub error_exit {
    if ($err_system ne 'i') {die("\nThere was a problem with the command line arguments (invalid $_[0]). \'Die\' signal given");}
    print "\nThere was a problem with the command line arguments. (Invalid $_[0].) ";
    print "Would you like to plot angular distributions, energy distributions, or total cross sections?\nEnter 'ang', 'nrg', or 'totxs': ";
    $answer = <STDIN>; chomp ($answer); $answer = lc($answer);
    if ($answer ne 'ang' && $answer ne 'nrg' && $answer ne 'totxs') {$understood = 'no'};
    while ($understood eq 'no') {
       print "\nAnswer not recognized. Please enter 'ang' for angular distributions, 'nrg' for energy distributions, or 'totxs' for total cross sections: ";
       $answer = <STDIN>; chomp ($answer); $answer = lc($answer);
       if ($answer eq 'ang' || $answer eq 'nrg' || $answer eq 'totxs') {$understood = 'yes'};
   };
   %hash = ('ang' => 'angular distributions', 'nrg' => 'energy distributions', 'totxs' => 'total cross sections');
   $choice = $hash{$answer};
   print "\nYou chose to get $choice. Here's how to do it:\n";
   if ($answer eq 'ang' || $answer eq 'nrg') {
       print "\nTo use, type: perl intranukeplotter.pl --paramater your_input --paramater your_input --paramater your_input\n\n";
       print "Parameters:\n";
       if ($answer eq 'ang') {print "**  --type    : select angular distributions by entering 'ang' as the argument\n"};
       if ($answer eq 'nrg') {print "**  --type    : select energy distributions by entering 'nrg' as the argument\n"};
       print "**  --a       : specifies author; see below for valid author inputs\n";
       print "    --v       : specifies GENIE version of root file; use no decimals; assumes \$GENIE if not specified\n";
       print "    --v2      : if using two root files, specifies GENIE version of second file\n";
       print "    --v3      : if using three root files, specifies GENIE version of third file\n";
       print "    --m       : specifies first GENIE model; assumes hA if neither model is specified\n";
       print "    --m2      : specifies second GENIE model; assumes hN if neither model is specified\n";
       print "**  --dorf    : specifies date of first root file; must match prefix of the root file\n";
       print "    --dorf2   : if using two root files, specifies date of second root file; assumes same as first root file if not specified\n";
       print "    --dorf3   : if using three root files, specifies date of third root file; assumes same as first root file if not specified\n";
       print "    --datadir : specifies directory of data files to be used; assumes present working directory if not specified\n";
       print "    --rootdir : specifies directory of root files to be used; assumes present working directory if not specified\n";
       print "    --pngdir  : specifies destination directory of png files; assumes png_files directory within pwd if not specified\n";
       print "    --rm      : the remove option; enter 'yes' as argument to discard format files after use; only possible if png files are produced\n";
       print "    --png     : enter 'off' as argument to turn off png file formation (ie, to only make format files)\n";
       print "    --name    : enter 'yes' to look for root files with the author's name in the front\n";
       print "    --rescale : specify a factor by which to multiply the vertical maxima of plots\n";
       print "** necessary input\n\n";
       print "Valid Author Inputs:\n";
       if ($answer eq 'ang') {print "cochran, hautala, ingram, levenson,benck ,bertrand, mckeown\n"};
       if ($answer eq 'nrg') {
           print "amian, baker, beck, crawford,bertrand, fidelus,letourneau, machner,sanami,benck,kondo,nica,carman, chen, cochran, franz, hautala, hayashi,benck ,ingram, nica,iwamoto,uozumi, kin,\n";
           print "levenson, mcgill, mckeown, meier, otsu, ouyang, roy, slypen, stamer,tippawan, tyren, zumbro\n"};
           die("\n");
       };
       if ($answer eq 'totxs') {
           print "\nTo use, type: perl intranukeplotter.pl --paramater your_input --paramater your_input --paramater your_input\n\n";
           print "Parameters:\n";
           print "**  --type    : select total cross sections by entering 'totxs' as the argument\n";
           print "**  --stype   : specifies a sub-type; enter 'cex' for charge exchange, 'reac' for reaction, etc.\n";
           print "**  --p       : specifies a probe; enter 'p' for proton, 'n' for neutron, 'pip' for positive pion, etc.\n";
           print "**  --t       : specifies a target; enter 'C' for carbon, 'Ca' for calcium, etc.\n";
           print "**  --hmax    : horizontal max on the plot, in MeV\n";
           print "**  --vmax    : vertical max on the plot, in millibarns\n";
           print "    --a       : specifies a specific author's data to be displayed; if no authors are specified, script will find up to five authors for the given reaction\n";
           print "    --a2      : specifies a second author's data\n"; 
           print "    --a3      : specifies a third author's data\n";
           print "    --a4      : specifies a fourth author's data\n";
           print "    --a5      : specifies a fifth author's data\n";
           print "    --v       : specifies GENIE version of root file; use no decimals; assumes 280 if not specified\n";
           print "    --v2      : if using two root files, specifies GENIE version of second file\n";
           print "    --v3      : if using three root files, specifies GENIE version of third file\n";
           print "    --m       : specifies first GENIE model; assumes hA if neither model is specified\n";
           print "    --m2      : specifies second GENIE model; assumes hN if neither model is specified\n";
           print "**  --dorf    : specifies date of first root file; must match prefix of the root file\n";
           print "    --dorf2   : if using two root files, specifies date of second root file; assumes same as first root file if not specified\n";
           print "    --dorf3   : if using three root files, specifies date of third root file; assumes same as first root file if not specified\n";
           print "    --datadir : specifies directory of data files to be used; assumes present working directory if not specified\n";
           print "    --rootdir : specifies directory of root files to be used; assumes present working directory if not specified\n";
           print "    --pngdir  : specifies destination directory of png files; assumes png_files directory within pwd if not specified\n";
           print "    --rm      : the remove option; enter 'yes' as argument to discard format files after use; only possible if png files are produced\n";
           print "    --png     : enter 'off' as argument to turn off png file formation (ie, to only make format files)\n";
           print "    --name    : enter 'yes' to look for root files with the author's name in the front\n";
           print "    --rescale : specify a factor by which to multiply the vertical maxima of plots\n";
           print "** necessary inputs\n";
           print "Valid Author Inputs:\n";
           print " Nucleon - abfalterer, auce, bauhof, dicello, dietrich, ibaraki, kirkby, mcgill, menet, mislivec, renberg, schimmerling,macgregor, voss, zanelli\n";
           print " Kaon - bugg, friedman, krauss\n";
          print " Pion - allardyce, ashery, clough, gelderloos, meirav, rowntree,,mashnik,saunders, wilkin\n";
           die("\n");
       };
   };

   sub error_exit_g {
    die("You must set up GENIE before running this script.\n");
}
