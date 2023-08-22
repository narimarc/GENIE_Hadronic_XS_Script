###########################################################################################################
##                                                                                                       ##
## Title:       runfast.pl                                                                               ##
##                                                                                                       ##
## Author:      Nicholas Geary, University of Pittsburgh (nig22@pitt.edu)                                ##
##              updated Narisoa Vololoniaina 2023                                                                                        ##
## Description: This script runs GENIE simulations with the gevgen_hadron command to produce             ##
##              gntp.inuke.***.ghep.root or gntp.***.ghep.root files. It then converts those files using ##
##              the gntpc command if the user selected 'root' as the type. If the user selected 'totxs'  ##
##              as the type, it instead uses the ***.ghep.root file and the gtestINukeHadroXSec command  ##
##              to produce a text file with cross sections.                                              ##
##                                                                                                       ##
## Use:         [] denotes optional argument                                                             ##
##                                                                                                       ##
##              To get ***.ginuke.root files to match an author's data:                                  ##
##                 perl runfast.pl --type root --a author [--n nev] [--r run] [--m mode] [--msg message] ##
##                 [--rm discard] [--name prepend] [--rootdir rdir] [--seed seed]                        ##
##                                                                                                       ##
##              To get ***.ginuke.root files for user-defined reactions:                                 ##
##                 perl runfast.pl --type root --p probe --k nrg --t target [--n nev] [--r run]          ##
##                 [--m mode] [--msg message] [--rm discard] [--name prepend] [--rootdir rdir]           ##
##                 [--seed seed]                                                                         ##
##                                                                                                       ##
##              To get total cross section text files:                                                   ##
##                 perl runfast.pl --type totxs --p probe --t target --min min_ke --max max_ke --s step  ##
##                 *[--el "ke1,ke2,ke3..."]* [--n nev] [--r run] [--m mode] [--msg message]              ##
##                 [--rm discard] [--name prepend] [--rootdir rdir] [--seed seed]                        ##
##                                                                                                       ##
##              Note: --min, --max, and --step are not necessary if --el (energy list) is used           ##
##                                                                                                       ##
##              Note: Where applicable, script supports up to 2 probes, 6 energies, 6 targets,           ##
##                    and 2 modes. Use switches --p2, --k2, --k3, --m2, etc.                             ##
##                                                                                                       ##
## Input:       (command line arguments only)                                                            ##
##                                                                                                       ##
## Output:      $rootdir/[author_]MMM_DD_YY_prb_tgt_nrg_vsn_mode.ginuke.root  and/or                     ##
##              $rootdir/[author_]MMM_DD_YY_prb_tgt_totxs_vsn_mode.txt                                   ##
##                                                                                                       ##
##              Note: $rootdir is ./root_files/ when not specified by the user                           ##
##                                                                                                       ##
###########################################################################################################


$GENIE = $ENV{"GENIE"};
if ($GENIE eq '') {error_exit_g();}

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);  ## call time function; used to name files and generate initial run number
my @abbr = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
$day = sprintf("%02d", $mday % 100);
$yr = sprintf("%02d", $year % 100);

$iarg = 0;
foreach (@ARGV) {
    if ($_ eq '--n')       { $n          = $ARGV[$iarg+1]; } ## number of events per run
    if ($_ eq '--k')       { $k[0]       = $ARGV[$iarg+1]; } ## kinetic energy 1 (must be defined)
    if ($_ eq '--k1')      { $k[0]       = $ARGV[$iarg+1]; } ## kinetic energy 1 (must be defined)
    if ($_ eq '--k2')      { $k[1]       = $ARGV[$iarg+1]; } ## kinetic energy 2
    if ($_ eq '--k3')      { $k[2]       = $ARGV[$iarg+1]; } ## kinetic energy 3
    if ($_ eq '--k4')      { $k[3]       = $ARGV[$iarg+1]; } ## kinetic energy 4
    if ($_ eq '--k5')      { $k[4]       = $ARGV[$iarg+1]; } ## kinetic energy 5
    if ($_ eq '--k6')      { $k[5]       = $ARGV[$iarg+1]; } ## kinetic energy 6
    if ($_ eq '--min')     { $min_ke     = $ARGV[$iarg+1]; } ## minimum energy
    if ($_ eq '--max')     { $max_ke     = $ARGV[$iarg+1]; } ## maximum energy
    if ($_ eq '--s')       { $step_size  = $ARGV[$iarg+1]; } ## size of energy intervals
    if ($_ eq '--p')       { $prbpdg[0]  = $ARGV[$iarg+1]; } ## probe 1 pdg code (must be defined)
    if ($_ eq '--p1')      { $prbpdg[0]  = $ARGV[$iarg+1]; } ## probe 1 pdg code (must be defined)
    if ($_ eq '--p2')      { $prbpdg[1]  = $ARGV[$iarg+1]; } ## probe 2 pdg code
    if ($_ eq '--r')       { $r          = $ARGV[$iarg+1]; } ## intial run number
    if ($_ eq '--t')       { $tgt[0]     = $ARGV[$iarg+1]; } ## target 1 (must be defined)
    if ($_ eq '--t1')      { $tgt[0]     = $ARGV[$iarg+1]; } ## target 1 (must be defined)
    if ($_ eq '--t2')      { $tgt[1]     = $ARGV[$iarg+1]; } ## target 2
    if ($_ eq '--t3')      { $tgt[2]     = $ARGV[$iarg+1]; } ## target 3
    if ($_ eq '--t4')      { $tgt[3]     = $ARGV[$iarg+1]; } ## target 4
    if ($_ eq '--t5')      { $tgt[4]     = $ARGV[$iarg+1]; } ## target 5
    if ($_ eq '--t6')      { $tgt[5]     = $ARGV[$iarg+1]; } ## target 6
    if ($_ eq '--msg')     { $msg        = $ARGV[$iarg+1]; } ## message thresholds
    if ($_ eq '--m')       { $m[0]       = $ARGV[$iarg+1]; } ## GENIE model 1
    if ($_ eq '--m1')      { $m[0]       = $ARGV[$iarg+1]; } ## GENIE model 1
    if ($_ eq '--m2')      { $m[1]       = $ARGV[$iarg+1]; } ## GENIE model 2
    if ($_ eq '--a')       { $author     = $ARGV[$iarg+1]; } ## author for group of runs (will define all necessary parameters)
    if ($_ eq '--type')    { $type       = $ARGV[$iarg+1]; } ## choose to get ROOT files or a text file with total cross sections
    if ($_ eq '--rm')      { $remove     = $ARGV[$iarg+1]; } ## choose to discard gntp files after they're used
    if ($_ eq '--name')    { $prepend    = $ARGV[$iarg+1]; } ## choose to prepend author's name to ROOT files
    if ($_ eq '--rootdir') { $rootdir    = $ARGV[$iarg+1]; } ## destination directory for ROOT files
    if ($_ eq '--err')     { $err_system = $ARGV[$iarg+1]; } ## input error handling system ('i' for interactive; defaults to non-interactive)
    if ($_ eq '--seed')    { $seed       = $ARGV[$iarg+1]; } ## seed
    if ($_ eq '--el')      { $nrg_list   = $ARGV[$iarg+1]; } ## list of energies
    if ($_ eq '--dv')      { $devvsn     = $ARGV[$iarg+1]; } ## extra flag to distinguish between DEVEL version w/ or w/o Brian's changes
    if ($_ eq '--tag1')    {$tag1        = $ARGV[$iarg+1]; } ##Optional tag to be included in the name of the root files (1/2)
    if ($_ eq '--tag2')    {$tag2        = $ARGV[$iarg+1]; } ##optional tag to be included in the name of the root file (2/2)
    $iarg++;
}

if ($k[0]) {$k[0] = .001 * $k[0]};  ## instead of GeV, take command line energies in units of MeV; this way, manual input is same format for this as for the plotter
if ($k[1]) {$k[1] = .001 * $k[1]};
if ($k[2]) {$k[2] = .001 * $k[2]};
if ($k[3]) {$k[3] = .001 * $k[3]};
if ($k[4]) {$k[4] = .001 * $k[4]};
if ($k[5]) {$k[5] = .001 * $k[5]};
if ($min_ke) {$min_ke = .001 * $min_ke};
if ($max_ke) {$max_ke = .001 * $max_ke};
if ($step_size) {$step_size = .001 * $step_size};


%prb_input_hash = ( '2212' => '2212', '2112' => '2112', '211' => '211', '-211' => '-211', '111' => '111', '321' => '321', '-321' => '-321', '311' => '311', '-311' => '-311', '22' => '22', '13' => '13', '-13' => '13', 'p' => '2212', 
    'n' => '2112', 'pip' => '211', 'pi+' => '211', 'pim' => '-211', 'pi-' => '-211', 'pi0' => '111', 'kp' => '321', 'k+' => '321', 'km' => '-321', 'k-' => '-321', 'k0' => '311', 'ak0' => '-311', 'gam' => '22', 'gamma' => '22',
                    'mup' => '-13', 'mu+' => '-13', 'mum' => '13', 'mu-' => '13');  ## hash to allow varied inputs for probes
if ($prbpdg[0]) {$prbpdg[0] = $prb_input_hash{$prbpdg[0]}}; 
if ($prbpdg[1]) {$prbpdg[1] = $prb_input_hash{$prbpdg[1]}};

%tgt_input_hash = (  ## a hash to allow different input formats for targets
    'n'   => '1000',    '1000'    => '1000',
    'h'   => '1',    '1'    => '1',
	'd'   => '1001', '1001' => '1001',                   ## i'm just adding 1000 for less common isotopes
    'he'  => '2',    '2'    => '2', 
    'li'  => '3',    '3'    => '3',
	'li6' => '1003', '1003' => '1003',                    ## same thing here
    'be'  => '4',    '4'    => '4',
    'b'   => '5',    '5'    => '5',
	'ca40' => '4020', '4020'=> '4020',                    #Should probably decide on a standard way to hash the isotopes
	'ca42' => '4220', '4220'=> '4220',
	'ca44' => '4420', '4420'=> '4420',
	'ca48' => '4820', '4820'=> '4820',
	'c'    => '6',    '6'   => '6',
    'c12'   => '126',    '126'    => '126',
    'n'   => '7',    '7'    => '7',
    'o'   => '8',    '8'    => '8',
	'h2o' => '1008', '1008' => '1008',                     ## adding 1000 to oxygen to make it mean water
    'al'  => '13',   '13'   => '13',
    'si'  => '14',   '14'   => '14',
    'ar'  => '18',   '18'   => '18',
    'ca'  => '20',   '20'   => '20',
	'fe'  => '26',  '26'  => '26',                         ##This is natural iron, for now at least
	'fe54' => '5426', '5426' => '5426',                    ##First number is mass number, second is atomic number
    'fe56'  => '5626',   '5626'   => '5626', 
    'fe57' => '5726', '5726' => '5726',
    'fe58' => '5826', '5826' => '5826',
    'co'  => '27',   '27'   => '27',
    'ni'  => '28',   '28'   => '28',
    'cu'  => '29',   '29'   => '29',
    'zr'  => '40',   '40'   => '40',
    'nb'  => '41',   '41'   => '41',
    'ag'  => '47',   '47'   => '47',
    'sn'  => '50',   '50'   => '50',
    'xe'  => '54',   '54'  => '54',
    'sn112'  => '11250',   '11250'   => '11250',
    'sn114'  => '11450',   '11450'   => '11450',
    'sn116'  => '11650',   '11650'   => '11650',
    'sn117'  => '11750',   '11750'   => '11750',
    'sn118'  => '11850',   '11850'   => '11850',
    'sn119'  => '11950',   '11950'   => '11950',
    'sn120'  => '12050',   '12050'   => '12050',
    'sn122'  => '12250',   '12250'   => '12250',
    'sn124'  => '12450',   '12450'   => '12450',
    'ta'  => '73',   '73'   => '73',
    'pb'  => '82',   '82'   => '82',
    'pb208'  => '20882',   '20882'   => '20882',
    'bi'  => '83',   '83'   => '83',
    );
if ($tgt[0]) {$tgt[0] = lc($tgt[0]); $tgt[0] = $tgt_input_hash{$tgt[0]}};
if ($tgt[1]) {$tgt[1] = lc($tgt[1]); $tgt[1] = $tgt_input_hash{$tgt[1]}};
if ($tgt[2]) {$tgt[2] = lc($tgt[2]); $tgt[2] = $tgt_input_hash{$tgt[2]}};
if ($tgt[3]) {$tgt[3] = lc($tgt[3]); $tgt[3] = $tgt_input_hash{$tgt[3]}};
if ($tgt[4]) {$tgt[4] = lc($tgt[4]); $tgt[4] = $tgt_input_hash{$tgt[4]}};
if ($tgt[5]) {$tgt[5] = lc($tgt[5]); $tgt[5] = $tgt_input_hash{$tgt[5]}};

$r = 100000 * $sec + 100 * $yday + $yr  unless defined $r;  ## default initial run number
$type = lc($type);
if ($type ne 'root' && $type ne 'totxs' && $type ne 'both') {error_exit("type")};
%totxs_hash = ('root' => 'no', 'totxs' => 'yes', 'both' => 'yes');
$totxs = $totxs_hash{$type};
%root_hash = ('root' => 'yes', 'totxs' => 'no', 'both' => 'yes');
$root = $root_hash{$type};

if ($author) {
    $author = lc ($author);
    $Author = ucfirst ($author);
}
%author_hash = (  ## acceptable author inputs are those listed at top of script
    'amian' => '1', 'baker' => '1', 'beck' => '1', 'bertrand' => '1','fidelus'=>'1' ,'crawford'=>'1','abertrand'=>'1','febertrand'=>'1','sanami'=>'1','machner'=>'1','watanabe'=>'1','carman' => '1', 'chen' => '1', 'cochran' => '1',
    'franz' => '1', 'franzbi'=>'1','Letourneau'=>'1','hautala' => '1', 'hayashi' => '1', 'ingram' => '1', 'iwamoto' => '1', 'uozumi'=>'1','benk'=>'1','uozumi_c'=>'1','nika'=>'1','uozumi_nb'=>'1','uozumi_au'=>'1','uozumi_al'=>'1','kin' => '1', 'kormanyos' => '1',
    'levenson' => '1', 'levenson_100' => '1', 'levenson_160'=>'1', 'levenson_220'=>'1',  'mcgill' => '1', 'mckeown' => '1', 'meier' => '1', 'otsu' => '1', 'ouyang' => '1', 'roy' => '1',
    'shibata' => '1', 'shibata_p' => '1', 'shibata_pi' => '1', 'segel' => '1', 'slypen' => '1', 'stamer' => '1', 'tippawan' => '1', 'tyren' => '1', 'zumbro' => '1',
    'mckeown1' => '1', 'mckeown2' => '1', 'mckeown3' => '1', 'mckeown4' => '1', 'mckeown5' => '1', 'mckeown6' => '1', 'mckeown_pip' => '1',

############################################################   Subsets of authors ##########################################################################################
'mckeown100pip' => '1', 'mckeown160pip' => '1', 'mckeown220pip' => '1', 'mckeown100pim' => '1', 'mckeown160pim' => '1', 'mckeown220pim' => '1',
'slypen26.5' => '1',  'slypen50'=> '1', 'slypen62.7' => '1', 'slypen72.8' => '1', 'slypen25.5' => '1', 'slypen49' => '1',
'amian597' => '1', 'amian800' => '1', 
'cochran_be' => '1', 'cochran_c' => '1', 'cochran_cu' => '1', 'cochran_d' => '1', 'cochran_h' => '1', 'cochran_pb' => '1', 'cochran_al' => '1'
);
$valid_author = $author_hash {$author};
if ($valid_author ne '1' && $author ne '') { error_exit("author. The author you typed was not recognized") };
if ($msg) { $msg = lc ($msg) };
if ($m[0] eq '') { @m = qw( hA hN ) };  ## run both hA and hN models if user does not specify
%mM_hash = ('ha' => 'hA', 'Ha' => 'hA', 'HA' => 'hA', 'hA' => 'hA', 'hn' => 'hN', 'Hn' => 'hN', 'HN' => 'hN', 'hN' => 'hN', 'ha2014' => 'hA2014', 'hA2014' => 'hA2014', 'hN2014' => 'hN2014', 'ha2014' => 'hA2014', 'hA2018' => 'hA2018', 'hN2018' => 'hN2018','HINCL'=>'HINCL','HG4BertCasc'=>'HG4BertCasc');
$m[0] = $mM_hash{$m[0]};
if ($m[1]) {$m[1] = $mM_hash{$m[1]}}; 

if ($author eq '' && $type eq 'root') {
    if ($prbpdg[0] ne '2212' && $prbpdg[0] ne '2112' && $prbpdg[0] ne '211' && $prbpdg[0] ne '-211' && $prbpdg[0] ne '111' && $prbpdg[0] ne '311' &&  $prbpdg[0] ne '-311' && $prbpdg[0] ne '321' &&  $prbpdg[0] ne '-321' 
        &&  $prbpdg[0] ne '22' &&  $prbpdg[0] ne '13' &&  $prbpdg[0] ne '-13') {error_exit("probe")};
    error_exit("energy") unless defined $k[0];  ## exit if author undefined and beam energy undefined
    error_exit("target") unless defined $tgt[0];  ## exit if author undefined and target undefined
}

if ($type eq 'totxs' || $type eq 'both') {
    if ($prbpdg[0] ne '2212' && $prbpdg[0] ne '2112' && $prbpdg[0] ne '211' && $prbpdg[0] ne '-211' && $prbpdg[0] ne '111' && $prbpdg[0] ne '311' &&  $prbpdg[0] ne '-311' && $prbpdg[0] ne '321' &&  $prbpdg[0] ne '-321'
        &&  $prbpdg[0] ne '22' &&  $prbpdg[0] ne '13' &&  $prbpdg[0] ne '-13') {error_exit("probe")};
    error_exit("target") unless defined $tgt[0];
    ($nrg_list) ? ($use_steps = 0) : ($use_steps = 1); 
    error_exit("minimum energy") unless (defined $min_ke || !($use_steps));
    error_exit("maximum energy") unless (defined $max_ke || !($use_steps));
    error_exit("step size") unless (defined $step_size || !($use_steps));
    error_exit("energies") unless (($type eq 'totxs' && (defined $nrg_list) || $use_steps));
}


%group_hash = (  ## link author input to all groups associated with that author
    'amian'     => ['amian'],
    'baker'     => ['baker_c', 'baker_ca'],
    'beck'      => ['beck'],
    'bertrand'  => ['bertrand'],
    'sanami'  => ['sanami'],
    'fidelus'=>['fidelus_12','fidelus_19','fidelus_25'],
    'crawford'=>['crawford_c','crawford_ni'],
    'watanabe'  => ['watanabe'],
    'machner'  => ['machner'],
    'abertrand' => ['abertrand_28','abertrand_61'],
    'febertrand'=>['febertrand_n','febertrand_p'],
    'uozumi'  => ['uozumi','uozumi_c', 'uozumi_al','uozumi_nb','uozumi_au'],
    'carman'    => ['carman'],
    'chen'      => ['chen'],
    'cochran'   => ['cochran'],
    'franz'     => ['franz'],
    'Letourneau'=>['Letourneau'],
    'franzbi'  =>['franzbi'],
    'hautala'   => ['hautala'],
    'hayashi'   => ['hayashi'],
    'nika' => ['nika'],
    'benk'=>['benk'],
    'ingram'    => ['ingram_o', 'ingram_h2o'],
    'iwamoto'   => ['iwamoto_870', 'iwamoto_2100'],
    'kin'       => ['kin'],
    'kormanyos' => ['kormanyos'],
    'levenson'  => ['levenson', 'levenson_c'],
    'levenson_100' => ['levenson_100_c','levenson_100_he','levenson_100_pb','levenson_100_ni'],    
    'levenson_160' => ['levenson_160_c', 'levenson_160_he', 'levenson_160_pb', 'levenson_160_ni'], 
    'levenson_220' => ['levenson_220_c', 'levenson_220_he', 'levenson_220_pb', 'levenson_220_ni'],
    'mcgill'    => ['mcgill'],    
    'mckeown'   => ['mckeown'],
    'mckeown1'  => ['mckeown1'],
    'mckeown2'  => ['mckeown2'],
    'mckeown3'  => ['mckeown3'],
    'mckeown4'  => ['mckeown4'],
    'mckeown5'  => ['mckeown5'],
    'mckeown6'  => ['mckeown6'],
    'mckeown_pip' => ['mckeown_pip'],
    'meier'     => ['meier', 'meier_al'],
    'otsu'      => ['otsu'],
    'ouyang'    => ['ouyang'],
    'roy'       => ['roy'],
    'shibata'   => ['shibata1', 'shibata2', 'shibata3', 'shibata4', 'shibata5'],
    'shibata_p' => ['shibata1', 'shibata2', 'shibata3'],
    'segel'     => ['segel_ni'],
    'shibata_pi'=> [ 'shibata4', 'shibata5'],
    'slypen'    => ['slypen_c', 'slypen_fe'],
    'stamer'    => ['stamer'],
    'tippawan'  => ['tippawan'],
    'tyren'     => ['tyren'],
    'zumbro'    => ['zumbro'],
############################################################   Subsets of authors ##########################################################################################
'mckeown100pip' => ['mckeown100pip_al', 'mckeown100pip_be', 'mckeown100pip_c', 'mckeown100pip_he', 'mckeown100pip_li', 'mckeown100pip_ni', 'mckeown100pip_ta'],
'mckeown160pip' => ['mckeown160pip_al', 'mckeown160pip_be', 'mckeown160pip_c', 'mckeown160pip_he', 'mckeown160pip_li', 'mckeown160pip_ni', 'mckeown160pip_ta'],
'mckeown220pip' => ['mckeown220pip_al', 'mckeown220pip_be', 'mckeown220pip_c', 'mckeown220pip_he', 'mckeown220pip_li', 'mckeown220pip_ni', 'mckeown220pip_ta'],

'mckeown100pim' => ['mckeown100pim_al', 'mckeown100pim_be', 'mckeown100pim_c', 'mckeown100pim_he', 'mckeown100pim_li', 'mckeown100pim_ni', 'mckeown100pim_ta'],
'mckeown160pim' => ['mckeown160pim_al', 'mckeown160pim_be', 'mckeown160pim_c', 'mckeown160pim_he', 'mckeown160pim_li', 'mckeown160pim_ni', 'mckeown160pim_ta'],
'mckeown220pim' => ['mckeown220pim_al', 'mckeown220pim_be', 'mckeown220pim_c', 'mckeown220pim_he', 'mckeown220pim_li', 'mckeown220pim_ni', 'mckeown220pim_ta'],

'slypen26.5' => ['slypen26.5'],  
'slypen50'=> ['slypen50'], 
'slypen62.7' => ['slypen62.7'], 
'slypen72.8' => ['slypen72.8'], 
'slypen25.5' => ['slypen25.5'], 
'slypen49' => ['slypen49'],

'amian597' => ['amian597_b', 'amian597_be', 'amian597_c', 'amian597_o', 'amian597_pb'],
'amian800' => ['amian800_b', 'amian800_be', 'amian800_c', 'amian800_o', 'amian800_pb'],

'cochran_be' => ['cochran_be'],
'cochran_c' => ['cochran_c'],
'cochran_cu' => ['cochran_cu'],
'cochran_d' => ['cochran_d'],
'cochran_h' => ['cochran_h'],
'cochran_pb' => ['cochran_pb'],
'cochran_al' => ['cochran_al']

);

if ($author ne '') {  ## if author was specified, define parameters accordingly
    foreach $group ( @{$group_hash {$author}} ) {

## AUTHOR PRESETS
%prbpdg1_hash = (                                 ## probe 1
    'amian'        => '2212',
    'baker_c'      => '2212',
    'baker_ca'     => '2212',
    'beck'         => '2212',
    'bertrand'     => '2212',
    'sanami'     => '2112',
    'machner'     => '2212',
    'fidelus'=>'2212',
    'crawford_c'=>'2212',
    'crawford_ni'=>'2212',
    'fidelus_12'=>'2212',
    'fidelus_19'=>'2212',
    'fidelus_25'=>'2212',
    'watanabe'=> '2112',
    'abertrand'   =>'2212',
    'abertrand_28'   =>'2212',
    'abertrand_61'   =>'2212',
    'febertrand_n'=>'2112',
    'febertrand_p'=>'2212',
    'uozumi'       =>'2212',
    'nika' =>'2112',
    'benk'=>'2212',
    'carman'       => '2212',
    'chen'         => '2212',
    'cochran'      => '2212',
    'franz'        => '2112',
    'franzbi'        => '2112',
    'Letourneau'=>'2212',
    'hautala'      => '2212',
    'hayashi'      => '2112',
    'ingram_o'     => '211',
    'ingram_h2o'   => '211',

    'uozumi_c' =>'2212',
    'uozumi_al'=>'2212',
    'uozumi_nb'=>'2212',
    'uozumi_au'=>'2212',
    'iwamoto_870'  => '211',
    'iwamoto_2100' => '211',
    'kin'          => '2212',
    'kormanyos'    => '321',
    'levenson'     => '211',
    'levenson_c'   => '211',
    'levenson_100_c' => '211',
    'levenson_100_he'=>'211',
    'levenson_100_pb'=>'211',
    'levenson_100_ni'=>'211',
    'levenson_160_c' => '211', 
    'levenson_160_ni' => '211',
    'levenson_160_pb' => '211',
    'levenson_160_he' => '211',
    'levenson_220_c' => '211', 
    'levenson_220_ni' => '211',
    'levenson_220_pb' => '211',
    'levenson_220_he' => '211',
    'mcgill'       => '2212',    
    'mckeown'      => '211',
    'mckeown1'     => '211',
    'mckeown2'     => '211',
    'mckeown3'     => '211',
    'mckeown4'     => '211',
    'mckeown5'     => '211',
    'mckeown6'     => '211',
    'mckeown_pip'  => '211',
    'meier'        => '2212',
    'meier_al'     => '2212',
    'otsu'         => '2212',
    'ouyang'       => '-211',
    'roy'          => '2212',
#    'segel_c'      => '2212',
'segel_ni'     => '2212',
'shibata1'     => '2212',
'shibata2'     => '2212',
'shibata3'     => '2212',
'shibata4'     => '211', 
'shibata5'     => '211',
'slypen_c'     => '2112',
'slypen_fe'    => '2112',
'stamer'       => '2212',
'tippawan'     => '2112',
'tyren'        => '2212',
'zumbro'       => '211',
############################################################   Subsets of authors18 ##########################################################################################
'mckeown100pip_al' => '211',
'mckeown100pip_be' => '211',
'mckeown100pip_c' => '211',
'mckeown100pip_he' => '211',
'mckeown100pip_li' => '211',
'mckeown100pip_ni' => '211',
'mckeown100pip_ta' => '211',

'mckeown160pip_al' => '211',
'mckeown160pip_be' => '211',
'mckeown160pip_c' => '211',
'mckeown160pip_he' => '211',
'mckeown160pip_li' => '211',
'mckeown160pip_ni' => '211',
'mckeown160pip_ta' => '211',

'mckeown220pip_al' => '211',
'mckeown220pip_be' => '211',
'mckeown220pip_c' => '211',
'mckeown220pip_he' => '211',
'mckeown220pip_li' => '211',
'mckeown220pip_ni' => '211',
'mckeown220pip_ta' => '211',

'mckeown100pim_al' => '-211',
'mckeown100pim_be' => '-211',
'mckeown100pim_c' => '-211',
'mckeown100pim_he' => '-211',
'mckeown100pim_li' => '-211',
'mckeown100pim_ni' => '-211',
'mckeown100pim_ta' => '-211',

'mckeown160pim_al' => '-211',
'mckeown160pim_be' => '-211',
'mckeown160pim_c' => '-211',
'mckeown160pim_he' => '-211',
'mckeown160pim_li' => '-211',
'mckeown160pim_ni' => '-211',
'mckeown160pim_ta' => '-211',

'mckeown220pim_al' => '-211',
'mckeown220pim_be' => '-211',
'mckeown220pim_c' => '-211',
'mckeown220pim_he' => '-211',
'mckeown220pim_li' => '-211',
'mckeown220pim_ni' => '-211',
'mckeown220pim_ta' => '-211',

'slypen26.5' => '2112',
'slypen50' => '2112',
'slypen62.7' => '2112',
'slypen72.8' => '2112',
'slypen25.5' => '2112',
'slypen49' => '2112',

'amian597_b' => '2212',
'amian597_be' => '2212',
'amian597_c' => '2212',
'amian597_o' => '2212',
'amian597_pb' => '2212',

'amian800_b' => '2212',
'amian800_be' => '2212',
'amian800_c' => '2212',
'amian800_o' => '2212',
'amian800_pb' => '2212',

'cochran_be' => '2212',
'cochran_c' => '2212',
'cochran_cu' => '2212',
'cochran_d' => '2212',
'cochran_h' => '2212',
'cochran_pb' => '2212',
'cochran_al' => '2212'


);
$prbpdg[0] = $prbpdg1_hash {$group};
%prbpdg2_hash = (                                 ## probe 2
    'iwamoto_870' => '-211',
    'mckeown'     => '-211',
    'mckeown1'    => '-211',
    'mckeown2'    => '-211',
    'mckeown3'    => '-211',
    'mckeown4'    => '-211',
    'mckeown5'    => '-211',
    'mckeown6'    => '-211',
    );
if ($prbpdg2_hash{$group} ne '') {$prbpdg[1] = $prbpdg2_hash{$group}};
%target1_hash = (                                 ## target 1
    'amian'        => '5',
    'baker_c'      => '6',
    'baker_ca'     => '20',
    'beck'         => '26',
    'bertrand'     => '26',
    'sanami'     => '13',
    'fidelus'=>'13',
    'fidelus_12'=>'13',
    'fidelus_19'=>'13',
    'fidelus_25'=>'13',
    'machner'     => '13',
    'watanabe'    => '14', 
    'abertrand'    => '13',
    'abertrand_28'    => '13',
    'abertrand_61'    => '13',
    'febertrand_n'    => '26',
    'febertrand_p'    => '26',
    'uozumi'=>'13',
    'uozumi_c'=>'6',
    'uozumi_al'=>'13',
    'uozumi_nb'=>'41',
    'uozumi_au'=>'79',
    'nika'=>'27',
    'benk'=>'13',
    'carman'       => '6',
    'chen'         => '82',
    'cochran'      => '13',
    'franz'        => '29',
    'franzbi'      => '83',
    'Letourneau' =>'79',
    'hautala'      => '6',
    'hayashi'      => '6',
    'ingram_o'     => '8',
    'ingram_h2o'   => '1008',
    'iwamoto_870'  => '26',
    'iwamoto_2100' => '26',
    'kin'          => '6',
    'kormanyos'    => '6',
    'levenson'     => '2',
    'levenson_c'   => '6', 
    'levenson_100_c'=>'6',
    'levenson_100_he'=>'2',
    'levenson_100_ni'=>'28',
    'levenson_100_pb'=>'82',
    'levenson_160_c'=>'6',
    'levenson_160_he'=>'2',
    'levenson_160_ni'=>'28',
    'levenson_160_pb'=>'82',
    'levenson_220_c'=>'6',
    'levenson_220_he'=>'2',
    'levenson_220_ni'=>'28',
    'levenson_220_pb'=>'82',
    'mcgill'       => '6',    
    'mckeown'      => '13',
    'mckeown1'     => '13',
    'mckeown2'     => '4',
    'mckeown3'     => '6',
    'mckeown4'     => '3',
    'mckeown5'     => '28',
    'mckeown6'     => '73',
    'mckeown_pip'  => '6',
    'meier'        => '82',
    'meier_al'     => '13',
    'otsu'         => '6',
    'ouyang'       => '6',
    'roy'          => '2',
#    'segel_c'      => '6',
'segel_ni'     => '28',						  
'shibata1'     => '47',
'shibata2'     => '29',
'shibata3'     => '6',
'shibata4'     => '6',
'shibata5'     => '29',
'slypen_c'     => '6',
'slypen_fe'    => '26',
'stamer'       => '13',
'tippawan'     => '6',
'tyren'        => '6',
'zumbro'       => '6',
############################################################   Subsets of authors ##########################################################################################
'mckeown100pip_al' => '13',
'mckeown100pip_be' => '4',
'mckeown100pip_c' => '6',
'mckeown100pip_he' => '2',
'mckeown100pip_li' => '3',
'mckeown100pip_ni' => '28',
'mckeown100pip_ta' => '73',

'mckeown160pip_al' => '13',
'mckeown160pip_be' => '4',
'mckeown160pip_c' => '6',
'mckeown160pip_he' => '2',
'mckeown160pip_li' => '3',
'mckeown160pip_ni' => '28',
'mckeown160pip_ta' => '73',

'mckeown220pip_al' => '13',
'mckeown220pip_be' => '4',
'mckeown220pip_c' => '6',
'mckeown220pip_he' => '2',
'mckeown220pip_li' => '3',
'mckeown220pip_ni' => '28',
'mckeown220pip_ta' => '73',

'mckeown100pim_al' => '13',
'mckeown100pim_be' => '4',
'mckeown100pim_c' => '6',
'mckeown100pim_he' => '2',
'mckeown100pim_li' => '3',
'mckeown100pim_ni' => '28',
'mckeown100pim_ta' => '73',

'mckeown160pim_al' => '13',
'mckeown160pim_be' => '4',
'mckeown160pim_c' => '6',
'mckeown160pim_he' => '2',
'mckeown160pim_li' => '3',
'mckeown160pim_ni' => '28',
'mckeown160pim_ta' => '73', 

'mckeown220pim_al' => '13',
'mckeown220pim_be' => '4',
'mckeown220pim_c' => '6',
'mckeown220pim_he' => '2',
'mckeown220pim_li' => '3',
'mckeown220pim_ni' => '28',
'mckeown220pim_ta' => '73',

'slypen26.5' => '6',
'slypen50' => '6',
'slypen62.7' => '6',
'slypen72.8' => '6',
'slypen25.5' => '26',
'slypen49' => '26', 

'amian597_b' => '5',
'amian597_be' => '4',
'amian597_c' => '6',
'amian597_o' => '8',
'amian597_pb' => '82',

'amian800_b' => '5',
'amian800_be' => '4',
'amian800_c' => '6',
'amian800_o' => '8',
'amian800_pb' => '82',


'cochran_be' => '4', 
'cochran_c' => '6',
'cochran_cu' => '29', 
'cochran_d' =>'1001', 
'cochran_h' => '1',
'cochran_pb' => '82',
'cochran_al' => '13',
'crawford_c'=>'6',
'crawford_ni'=>'28'
);
$tgt[0] = $target1_hash {$group};
%target2_hash = (                                 ## target 2
    'amian'       => '4',
    'beck'        => '82',
    'cochran'     => '4',
    'hautala'     => '20',
    'levenson'    => '28',
    'mcgill'      => '20',    
    'mckeown'     => '4',
    'mckeown_pip' => '26',
    'meier'       => '6',
    'ouyang'      => '83',
    'roy'         => '28',
    #'segel'       => '28',
    'shibata1'    => '13',
    'shibata3'    => '82',
    'shibata4'    => '82',
    'stamer'      => '82',
    'slypen62.7' => '26',

    );
if ($target2_hash{$group} ne '') {$tgt[1] = $target2_hash {$group}};
%target3_hash = (                                 ## target 3
    'amian'    => '6',
    'cochran'  => '6',
    'levenson' => '82',     
    'mckeown'  => '6',
    'mckeown_pip' => '82',
    'meier'    => '26',
    'roy'      => '73',
    'shibata1' => '73',
    'stamer'   => '40',    
    );
if ($target3_hash{$group} ne '') {$tgt[2] = $target3_hash{$group}};
%target4_hash = (                                 ## target 4
    'amian'   => '8',
    'cochran' => '29',
    'mckeown' => '3',
    'meier'   => '8',
    'shibata1'=> '6',
    );
if ($target4_hash{$group} ne '') {$tgt[3] = $target4_hash{$group}};
%target5_hash = (                                 ## target 5
    'amian'   => '82',
    'cochran' => '82',    
    'mckeown' => '28',
    );
if ($target5_hash{$group} ne '') {$tgt[4] = $target5_hash{$group}};
%target6_hash = (                                 ## target 6
    'cochran' => '1',    
    'mckeown' => '73',
    );
if ($target6_hash{$group} ne '') {$tgt[5] = $target6_hash{$group}};
%k1_hash = (                                      ## beam energy 1
    'amian'        => '.597',
    'baker_c'      => '.318',
    'baker_ca'     => '.320',
    'beck'         => '.558',
    'bertrand'     => '.065',
    'sanami'     => '.075',
    'fidelus_12' =>'1.2',
    'fidelus_19' =>'1.9',
    'fidelus_25' =>'2.5',
    'machner'     => '.2',
    'watanabe' =>'.1754',
    'Letourneau'=>'2.5',
    'abertrand_28'    => '.0288',
    'abertrand_61'    => '.0617',
    'febertrand_n'  => '.0617',
    'febertrand_p'  => '.0617',
    'carman'       => '.200',
    'chen'         => '.290',
    'cochran'      => '.730',
    'franz'        => '.383',
    'franzbi'      => '.383',
    'hautala'      => '.197',
    'hayashi'      => '.147',
    'ingram_o'     => '.114',
    'ingram_h2o'   => '.114',
    'iwamoto_870'  => '.870',
    'iwamoto_2100' => '2.100',
    'kin'          => '.300',
    'kormanyos'    => '.367',
    'levenson'     => '.100',
    'levenson_c'   => '.100',
    'levenson_100_c' => '.100', 
    'levenson_100_he'=> '.100',
    'levenson_100_pb'=> '.100',
    'levenson_100_ni'=> '.100',
    'levenson_160_c' => '.160',
    'levenson_160_he'=>'.160',
    'levenson_160_ni'=>'.160',
    'levenson_160_pb'=>'.160',
    'levenson_220_c' => '.220',
    'levenson_220_he'=>'.220',
    'levenson_220_ni'=>'.220',
    'levenson_220_pb'=>'.220',
    'mcgill'       => '.800',    
    'mckeown'      => '.100',
    'mckeown1'     => '.100',
    'mckeown2'     => '.100',
    'mckeown3'     => '.100',
    'mckeown4'     => '.100',
    'mckeown5'     => '.100',
    'mckeown6'     => '.100',
    'mckeown_pip'  => '.100',
    'meier'        => '.113',
    'meier_al'     => '.256',
    'otsu'         => '.392',
    'ouyang'       => '.500',
    'roy'          => '.500',
#    'segel_c'      => '.155',
'segel_ni'      => '.164',						  
'shibata1'     => '11.0984',
'shibata2'     => '.747063',
'shibata3'     => '3.1703',
'shibata4'     => '3.86286',
'shibata5'     => '1.26737',
'slypen_c'     => '.0265',
'slypen_fe'    => '.0255',
'uozumi' => '.392',
'uozumi_c'=>'.300',
'uozumi_al'=>'.300',
'uozumi_nb'=>'.300',
'uozumi_au'=>'.300',
'nika'=>'.0627',
'benk'=>'.0627',
'stamer'       => '.256',
'tippawan'     => '.0956',
'tyren'        => '.185',
'zumbro'       => '.500',
############################################################   Subsets of authors ##########################################################################################
'mckeown100pip_al' => '.100',
'mckeown100pip_be' => '.100',
'mckeown100pip_c' => '.100',
'mckeown100pip_he' => '.100',
'mckeown100pip_li' => '.100',
'mckeown100pip_ni' => '.100',
'mckeown100pip_ta' => '.100',

'mckeown160pip_al' => '.160',
'mckeown160pip_be' => '.160',
'mckeown160pip_c' => '.160',
'mckeown160pip_he' => '.160',
'mckeown160pip_li' => '.160',
'mckeown160pip_ni' => '.160',
'mckeown160pip_ta' => '.160',

'mckeown220pip_al' => '.220',
'mckeown220pip_be' => '.220',
'mckeown220pip_c' => '.220',
'mckeown220pip_he' => '.220',
'mckeown220pip_li' => '.220',
'mckeown220pip_ni' => '.220',
'mckeown220pip_ta' => '.220',

'mckeown100pim_al' => '.100',
'mckeown100pim_be' => '.100',
'mckeown100pim_c' => '.100',
'mckeown100pim_he' => '.100',
'mckeown100pim_li' => '.100',
'mckeown100pim_ni' => '.100',
'mckeown100pim_ta' => '.100',

'mckeown160pim_al' => '.160',
'mckeown160pim_be' => '.160',
'mckeown160pim_c' => '.160',
'mckeown160pim_he' => '.160',
'mckeown160pim_li' => '.160',
'mckeown160pim_ni' => '.160',
'mckeown160pim_ta' => '.160',

'mckeown220pim_al' => '.220',
'mckeown220pim_be' => '.220',
'mckeown220pim_c' => '.220',
'mckeown220pim_he' => '.220',
'mckeown220pim_li' => '.220',
'mckeown220pim_ni' => '.220',
'mckeown220pim_ta' => '.220',

'slypen26.5' => '.0265',
'slypen50' => '.050',
'slypen62.7' => '.0627',
'slypen72.8' => '.0728',
'slypen25.5' => '.0255',
'slypen49' => '.049',

'amian597_b' => '.597',
'amian597_be' => '.597',
'amian597_c' => '.597',
'amian597_o' => '.597',
'amian597_pb' => '.597',

'amian800_b' => '.800',
'amian800_be' => '.800',
'amian800_c' => '.800',
'amian800_o' => '.800',
'amian800_pb' => '.800',

'cochran_be' => '.730', 
'cochran_c' => '.730',
'cochran_cu' => '.730', 
'cochran_d' =>'.730', 
'cochran_h' => '.730',
'cochran_pb' => '.730',
'cochran_al' => '.730',
'crawford_c'=>'.585',
'crawford_ni'=>'.585',
'cochran_be'=>'.585',

);
$k[0] = $k1_hash {$group};
%k2_hash = (                                      ## beam energy 2
    'amian'       => '.800',
    'franz'       => '.425',
    'franzbi' =>'.425',
    'ingram_o'    => '.163',
    'ingram_h2o'  => '.163',
    'kin'         => '.392',
    'levenson'    => '.160',
    'levenson_c'  => '.160',
    'mckeown'     => '.160',
    'mckeown1'    => '.160',
    'mckeown2'    => '.160',
    'mckeown3'    => '.160',
    'mckeown4'    => '.160',
    'mckeown5'    => '.160',
    'mckeown6'    => '.160',
    'mckeown_pip' => '.160',
    'otsu'        => '.400',
    #'segel'       => '.164',
    'shibata2'    => '1.732',
    'shibata5'    => '2.36432',
    'slypen_c'    => '.050',
    'slypen_fe'   => '.049',
    'stamer'      => '.800',
    );
if ($k2_hash{$group} ne '') {$k[1] = $k2_hash{$group}};
%k3_hash = (                                      ## beam energy 3
    'franz'      => '.477',
    'franzbi'  =>'.477',
    'ingram_o'   => '.240',
    'ingram_h2o' => '.240',
    'levenson'   => '.220',
    'levenson_c' => '.220',
    'mckeown'    => '.220',
    'mckeown1'   => '.220',
    'mckeown2'   => '.220',
    'mckeown3'   => '.220',
    'mckeown4'   => '.220',
    'mckeown5'   => '.220',
    'mckeown6'   => '.220',
    'mckeown_pip'=> '.220',
    'shibata2'   => '3.1703',
    'shibata5'   => '2.86367',
    'slypen_c'   => '.0627',
    'slypen_fe'  => '.0627',
    );
if ($k3_hash{$group} ne '') {$k[2] = $k3_hash{$group}};
%k4_hash = (                                      ## beam energy 4
    'franz'      => '.542',
    'franzbi'=>'.542',
    'levenson_c' => '.300',
    'shibata2'   => '2.20503',
    'shibata5'   => '3.86286', 
    'slypen_c'   => '.0728',
    );
if ($k4_hash{$group} ne '') {$k[3] = $k4_hash{$group}};
%k5_hash = (                                      ## beam energy 5
    'franz' => '.3174',
    'franzbi'=>'.3174',
    'shibata2' => '11.0984',
    );
if ($k5_hash{$group} ne '') {$k[4] = $k5_hash{$group}};
%k6_hash = (                                      ## beam energy 6
    'franz' => '.3477',
    'franzbi'=>'.3477',
    );
if ($k6_hash{$group} ne '') {$k[5] = $k6_hash{$group}};
definitions();  ## call subroutine that defines all parameters that are not group-specific
check_directories();
execute();  ## call subroutine that executes gevgen and gntpc commands
clear_values();
}
} else {  ## if author was not defined, use the manual inputs
    definitions();  ## call subroutine that defines all paramaters that are not group-specific
    check_directories();
    open_files();
    execute();  ## call subroutine that executes gevgen and gntpc commands (or gevgen and gtestINukeHadroXSec) 
}




### SUBROUTINES USED IN SCRIPT ###

## The definitions subroutine ##

sub definitions {

    $msg = 'laconic'         unless defined $msg;          ## default message thresholds
    $n = 100000              unless defined $n;            ## default number of events per run
    $err_system = 'ni'       unless defined $err_system;   ## default error system (non-interactive)

    ($seed) ? ($seed_switch = "--seed $seed") : ($seed_switch = "");

    ($prepend eq 'yes') ? ($a_name = "$author\_") : ($a_name = "");

    ## GENIE VERSION
    if ($GENIE =~ m/devel/i) {           ## if $GENIE contains "devel" (regardless of case)
    if (lc($devvsn) eq 'b') {
       $version = 'DB';
       } else {
           $version = 'DEVEL';
       }
    } elsif (!($GENIE =~ m/\d/)) {       ## if $GENIE contains no digits
       $version = 'v280';
       } else {
	@nums = ($GENIE =~ m/(\d+)/g);   ## extract the digits from $GENIE
	$v_num = join("",@nums);
	$version = "v$v_num";
}
if ($version eq 'v266') {
	@m = qw(hA);
	$prefix = 'gntp';
    } else {
       $prefix = 'gntp.inuke';
   }
    #####Hardcoding for GENIEtrunk-fsi which will become GENIE_v212###
    if($GENIE =~ m/trunk-fsi/i){
       $version = 'v212devel'; 
   }
    ## MESSAGE THRESHOLDS
    %msg_hash = (
        'laconic' => '--message-thresholds Messenger_laconic.xml',
        'normal' => '--message-thresholds Messenger.xml',
        'verbose' => '--message-thresholds Messenger_inuke_verbose.xml',
        );
    $msngr = $msg_hash {$msg};


    ## PROBES
    %prb_hash = (
        '2212' => 'p',
        '2112' => 'n',
        '211'  => 'pip',
        '-211' => 'pim',
        '111'  => 'pi0',
        '22'   => 'gam',
        '311'  => 'k0',
        '-311' => 'ak0',
        '321'  => 'kp',
        '-321' => 'km',
        '-13'  => 'mup',
        '13'   => 'mum',
        );
    $probe = $prb_hash{$probepdg};

    ## TARGETS
    %t_hash = (
        '1000' => '1000000010',
        '1'    => '1000010010',
        '1001' => '1000010020',
        '2'    => '1000020040',
        '3'    => '1000030070',
        '1003' => '1000030060',
        '4'    => '1000040090',
        '5'    => '1000050110',
	'6'    => '1000060120',  ##[.9893],1000060130[.0107]', ##Needs to be a correction - This doesn't work.
    '126'  => '1000060120', 
    '4020' => '1000200400', 
    '4220' => '1000200420', 
    '4420' => '1000200440',
    '4820' => '1000200480',
    '7'    => '1000070140',
    '8'    => '1000080160',
    '1008' => '1000080160[.8881],1000010010[.1119]', 
    '13'   => '1000130270',
    '14'   => '1000140280',
    '18'   => '1000180400',
    '20'   => '1000200400',
	'26'   => '1000260560', #[.91754],1000260540[.05845],1000260570[.02119],1000260580[.00282]',  ##Likewise here 
	'5426'  => '1000260540', 
    '5626'   => '1000260560', 
    '5726'  => '1000260570',  
    '5826' =>  '1000260580', 
    '27'   => '1000270590',
    '28'   => '1000280580',
    '29'   => '1000290630',
    '40'   => '1000400900',
    '47'   => '1000471070',
    '41'   => '1000410930',
	'50'   => '1000501180', #[.2422],1000501120[.0097],1000501140[.0066],1000501150[.0034],1000501160[.1454],1000501170[.0768],1000501190[.0859],1000501200[.0859],1000501220[.0859],1000501220[.0463],1000501240[.0579]',
    '54'   => '1000541310',
    '11250'   => '1000501120',
    '11450'   => '1000501140',
    '11650'   => '1000501160',
    '11750'   => '1000501170',
    '11850'   => '1000501180',
    '11950'   => '1000501190',
    '12050'   => '1000501200',
    '12250'   => '1000501220',
    '12450'   => '1000501240',
    '73'   => '1000731810',
    '79' =>'1000791970',
    '82'   => '1000822080[.524],1000822070[.221],1000822060[.241],1000822040[.014]',
    '20882'   => '1000822080',
    '83'   => '1000832090',
    );
    $tcode = $t_hash{$target};

    ## TARGETS
    %atom_hash = (
        '1000' => 'n',
        '1'    => 'H',
        '1001' => 'D',
        '2'    => 'He',
        '3'    => 'Li',
        '1003' => 'Li6',
        '4'    => 'Be',
        '5'    => 'B',
        '6'    => 'C',
        '126'  => 'C12',
        '4018' => 'Ar40',
        '4020' => 'Ca40',
        '4220' => 'Ca42',
        '4420' => 'Ca44',
        '4820' => 'Ca48',
        '7'    => 'N',
        '8'    => 'O',
        '1008' => 'H2O',
        '13'   => 'Al',
        '14'   => 'Si',
        '18'   => 'Ar',
        '20'   => 'Ca',
        '26'   => 'Fe',
        '5426' => 'Fe54',
        '5626'   => 'Fe56',
        '5726' => 'Fe57',  
        '5826' => 'Fe58',
        '27'   => 'Co',
        '28'   => 'Ni',
        '29'   => 'Cu',
        '40'   => 'Zr',
        '41'   => 'Nb',
        '47'   => 'Ag',
        '50'   => 'Sn',
        '54'   => 'Xe',
        '11250' => 'Sn112',
        '11450' => 'Sn114',
        '11650' => 'Sn116',
        '11750' => 'Sn117',
        '11850' => 'Sn118',
        '11950' => 'Sn119',
        '12050' => 'Sn120',
        '12250' => 'Sn122',
        '12450' => 'Sn124',
        '73'    => 'Ta',
        '79' => 'Au',
        '82'    => 'Pb',
        '20882'=> 'Pb208',
        '83'   => 'Bi',
        );
    $Atom = $atom_hash{$target};
    $atom = lc($Atom);

    ## OUTPUT DIRECTORY
    $rootdir = 'root_files'  unless defined $rootdir;
    $rootdir =~ s|/$||;

    ## ENERGIES
    if ($use_steps==0) {
       @nrg_array = split(',',$nrg_list);
   }
}

## Subroutine to check directory structure ##

sub check_directories {
    print "Output files will be placed in this directory: $rootdir\n";
    if (!(-e $rootdir)) {
       print "This directory ($rootdir) does not exist. Building it now.\n";
       system("mkdir -p $rootdir");
       if (-e $rootdir) {
           print "The directory ($rootdir) has been built.\n";
           } else {
               die("Could not find and could not build target directory ($rootdir).\n");
           }
       }
   }


## The execute subroutine ##

sub execute {
    q^   
    if ($nncorr=='on' && $oset=='on'){
       $nncorr='nncorron'; $oset='oseton'}
       elsif ($nncorr=='on'
       ^ if 0;
       $np = @prbpdg; $nt = @tgt; $ne = @k; $nm = @m;
       foreach $probepdg (@prbpdg) {
           foreach $target (@tgt) {
               definitions();
               if ($type eq 'root') {
                  foreach $nrg (@k) {
                      $nrgmev = $nrg * 1000;
                      foreach $mode (@m) {
                         print "Executing this command: gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $nrg -m $mode $msngr $seed_switch\n";
                         system ("gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $nrg -m $mode $msngr $seed_switch");
                         system ("gntpc -f ginuke -i $prefix.$r.ghep.root -o $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_$nrgmev\_$version\_$mode$tag1$tag2.ginuke.root $msngr");
                         if ($remove eq 'yes') {
                             unlink ("$prefix.$r.ghep.root", "genie-mcjob-$r.status");
                             } elsif ($rootdir ne '.') {
                                 system ("mv $prefix.$r.ghep.root $rootdir/; mv genie-mcjob-$r.status $rootdir/");
                             }
                             $r++;
                         }
                     }
                 }
                 if ($totxs eq 'yes') {
                  if ($use_steps==1) {
		    ## use min. max, and steps
		    $nrg = $min_ke;
		    $max_ke = $max_ke + .00000001;
		    while ($nrg < $max_ke) {
             $nrgmev = $nrg * 1000;
             foreach $mode (@m) {
                 if (-e gevgen_hadron_xsection.txt) {unlink ("gevgen_hadron_xsection.txt")};
                 print "Executing this command: gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $nrg -m $mode $msngr $seed_switch\n";
                 system ("gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $nrg -m $mode $msngr $seed_switch");
                 if ($root eq 'yes') {system ("gntpc -f ginuke -i $prefix.$r.ghep.root -o $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_$nrgmev\_$version\_$mode$tag1$tag2.ginuke.root $msngr")};
			    ## system ("gtestINukeHadroXSec -f $prefix.$r.ghep.root -w -o gevgen_hadron_xsection_$r.txt");
			    ## system ("gawk '!/#/ {print}' gevgen_hadron_xsection_$r.txt >> $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode.txt");
			    system ("gtestINukeHadroXSec -f $prefix.$r.ghep.root -w -m $mode");
			    system ("gawk '!/#/ {print}' gevgen_hadron_xsection.txt >> $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode$tag1$tag2.txt");
			    unlink ("gevgen_hadron_xsection.txt");
			    ## unlink ("gevgen_hadron_xsection_$r.txt");
			    if ($remove eq 'yes') {
                    unlink ("$prefix.$r.ghep.root", "genie-mcjob-$r.status");
                    } elsif ($rootdir ne '.')  {                                             
                        system ("mv $prefix.$r.ghep.root $rootdir/; mv genie-mcjob-$r.status $rootdir/");
                    }
                    $r++;
                }
                $nrg = $nrg + $step_size;
            }
            } else {
		    ## use list of energies
		    foreach $cur_nrg_MeV (@nrg_array) {
             $cur_nrg = .001 * $cur_nrg_MeV;
             foreach $mode (@m) {
                 if (-e gevgen_hadron_xsection.txt) {unlink ("gevgen_hadron_xsection.txt")};
                 print "Executing this command: gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $cur_nrg -m $mode $msngr $seed_switch\n";
                 system ("gevgen_hadron -p $probepdg -t $tcode -n $n -r $r -k $cur_nrg -m $mode $msngr $seed_switch");
                 if ($root eq 'yes') {system ("gntpc -f ginuke -i $prefix.$r.ghep.root -o $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_$cur_nrgmev\_$version\_$mode$tag1$tag2.ginuke.root $msngr")};
			    ## system ("gtestINukeHadroXSec -f $prefix.$r.ghep.root -w -o gevgen_hadron_xsection_$r.txt");
			    system ("gtestINukeHadroXSec -f $prefix.$r.ghep.root -w -m $mode");
			    ## system ("gawk '!/#/ {print}' gevgen_hadron_xsection_$r.txt >> $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode.txt");
			    system ("gawk '!/#/ {print}' gevgen_hadron_xsection.txt >> $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode$tag1$tag2.txt");
			    unlink ("gevgen_hadron_xsection.txt");
			    ## unlink ("gevgen_hadron_xsection_$r.txt");
			    if ($remove eq 'yes') {
                  unlink ("$prefix.$r.ghep.root", "genie-mcjob-$r.status");
                  } elsif ($rootdir ne '.')  {
                      system ("mv $prefix.$r.ghep.root $rootdir/; mv genie-mcjob-$r.status $rootdir/");
                  }
                  $r++;
              }
          }
      }
  }
}   
}
}


## Subroutine to begin cross section files ##

sub open_files {
    if ($totxs eq 'yes') {
       foreach $probepdg (@prbpdg) {
           foreach $target (@tgt) {
              foreach $mode (@m) {
                  definitions();
                  $do = 'maybe';
                  (-e "$rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode$tag1$tag2.txt") ? ($do = 'no') : ($do = 'yes');
                  if ($do eq 'yes') {
                     open (FILE, "> $rootdir/$a_name$abbr[$mon]\_$day\_$yr\_$probe\_$Atom\_totxs_$version\_$mode$tag1$tag2.txt");
                     print FILE "#KE     Undef   sig     CEx     sig     Elas    sig     Inelas  sig     Abs     sig     KO      sig     PiPro   sig     DCEx    sig     Reac    sig     Tot     sig     \n";
                     close(FILE);
                 }
             }
         }
     }
 }
}


## The incorrect usage subroutine ##

sub error_exit {
    if ($err_system ne 'i') {die("\nThere was a problem with the command line arguments (invalid $_[0]). \'Die\' signal given");}
    print "\nThere was a problem with the command line arguments. (Invalid $_[0].) ";
    print "Would you like to get ****.ginuke.root files, text files with total cross sections, or both?\nEnter 'R' for root files, 'T' for text total cross section files, or 'B' for both: ";
    $answer = <STDIN>; $answer = uc($answer); chomp ($answer);
    if ($answer ne 'R' && $answer ne 'T' && $answer ne 'B') {$understood = 'no'};
    while ($understood eq 'no') {
       print "\nAnswer not recognized. Please enter 'R' for root files, 'T' for text total cross section files, or 'B' for both: ";
       $answer = <STDIN>; $answer = uc($answer); chomp ($answer);
       if ($answer eq 'R' || $answer eq 'T' || $answer eq 'B') {$understood = 'yes'};
   }
   %hash = ('R' => 'root files', 'T' => 'text files with total cross sections', 'B' => 'both root files and total xs text files');
   $choice = $hash{$answer};
   print "\nYou chose to get $choice. Here's how to do it:\n";
   if ($answer eq 'R') {
       print "\nTo use, type: perl runfast.pl --paramater your_input --paramater your_input --paramater your_input\n\n";
       print "Parameters:\n";
       print "**  --type   : specifies type of output file; enter 'root' to get ****.ginuke.root files\n";
       print "++  --a      : specifies author; see below for valid author inputs\n";
       print "    --m      : specifies first GENIE model; assumes hA if neither model is specified\n";
       print "    --m2     : specifies second GENIE model; assumes hN if neither model is specified\n";
       print "    --n      : specifies number of events; assumes 100000 if not specified\n";
       print "**  --p      : specifies probe; letter abbreviation or pdg code is acceptable\n";
       print "    --p2     : specifies an additional probe\n";
       print "**  --k      : specifies kinetic energy of probe in units of MeV\n";
       print "    --k2     : specifies an additional kinetic energy of probe\n";
       print "    --k3     : specifies a third kinetic energy\n";
       print "    --k4     : specifies a fourth kinetic energy\n";
       print "    --k5     : specifies a fifth kinetic energy\n";
       print "    --k6     : specifies a sixth kinetic energy\n";
       print "**  --t      : specifies a target; letter symbol or atomic number is acceptable\n";
       print "    --t2     : specifies an additional target\n";
       print "    --t3     : specifies a third target\n";
       print "    --t4     : specifies a fourth target\n";
       print "    --t5     : specifies a fifth target\n";
       print "    --t6     : specifies a sixth target\n";
       print "    --r      : specifies an initial run number; automatically generated if not specified\n";
       print "    --msg    : specifies message thresholds; choose laconic, normal, or verbose; assumes laconic if not specified\n";
       print "    --rm     : enter 'yes' to discard gntp files after they've been used\n";
       print "    --name   : enter 'yes' to prepend the author's name to the root file\n";
       print "    --rootdir: specifies the destination directory of the output files\n"; 
       print "++ automatically defines all probes, energies, and targets\n";
       print "** necessary inputs\n\n";
       print "Valid Author Inputs:\n";
       print "amian, baker, beck, bertrand, abertrand,fidelus,sanami,carman,machner,watanabe,chen, cochran,Letourneau ,franz, franzbi,hautala, hayashi, ingram, iwamoto,uozumi, kin,\n";
       print "levenson, mcgill, mckeown, meier, otsu, ouyang, roy, slypen, stamer,benk, tippawan, tyren, zumbro\n";
       die("\n");
   }
   if ($answer eq 'T') {
       print "\nTo use, type: perl runfast.pl --paramater your_input --paramater your_input --paramater your_input\n\n";
       print "Parameters:\n";
       print "**  --type   : specifies type of output file; enter 'totxs' to get text files with total cross sections\n";
       print "    --m      : specifies first GENIE model; assumes hA if neither model is specified\n";
       print "    --m2     : specifies second GENIE model; assumes hN if neither model is specified\n";
       print "**  --p      : specifies probe; letter abbreviation or pdg code is acceptable\n";
       print "    --p2     : specifies an additional probe\n";
       print "**  --t      : specifies a target; letter symbol or atomic number is acceptable\n";
       print "    --t2     : specifies an additional target\n";
       print "    --t3     : specifies a third target\n";
       print "    --t4     : specifies a fourth target\n";
       print "    --t5     : specifies a fifth target\n";
       print "    --t6     : specifies a sixth target\n";
       print "**  --min    : specifies the minimum kinetic energy of probe in units of MeV\n";
       print "**  --max    : specifies the maximum kinetic energy of probe in units of MeV\n";
       print "**  --s      : specifies the step size of kinetic energy increments\n";
       print "    --n      : specifies number of events per step; assumes 100000 if not specified\n";
       print "    --r      : specifies an initial run number; automatically generated if not specified\n";
       print "    --msg    : specifies message thresholds; choose laconic, normal, or verbose; assumes laconic if not specified\n";
       print "    --rm     : enter 'yes' to discard gntp files after they've been used\n";
       print "    --name   : enter 'yes' to prepend the author's name to the cross section text file\n";
       print "    --rootdir: specifies the destination directory of the output files\n";
       print "** necessary inputs\n";
       die("\n");
   }
   if ($answer eq 'B') {
       print "\nTo use, type: perl runfast.pl --paramater your_input --paramater your_input --paramater your_input\n\n";
       print "Parameters:\n";
       print "**  --type   : specifies type of output file; enter 'both' to get root files and total xs text files\n";
       print "    --m      : specifies first GENIE model; assumes hA if neither model is specified\n";
       print "    --m2     : specifies second GENIE model; assumes hN if neither model is specified\n";
       print "**  --p      : specifies probe; letter abbreviation or pdg code is acceptable\n";
       print "    --p2     : specifies an additional probe\n";
       print "**  --t      : specifies a target; letter symbol or atomic number is acceptable\n";
       print "    --t2     : specifies an additional target\n";
       print "    --t3     : specifies a third target\n";
       print "    --t4     : specifies a fourth target\n";
       print "    --t5     : specifies a fifth target\n";
       print "    --t6     : specifies a sixth target\n";
       print "**  --min    : specifies the minimum kinetic energy of probe in units of MeV\n";
       print "**  --max    : specifies the maximum kinetic energy of probe in units of MeV\n";
       print "**  --s      : specifies the step size of kinetic energy increments\n";
       print "    --n      : specifies number of events per step; assumes 100000 if not specified\n";
       print "    --r      : specifies an initial run number; automatically generated if not specified\n";
       print "    --msg    : specifies message thresholds; choose laconic, normal, or verbose; assumes laconic if not specified\n";
       print "    --rm     : enter 'yes' to discard gntp files after they've been used\n";
       print "    --name   : enter 'yes' to prepend the author's name to the output files\n";
       print "    --rootdir: specifies the destination directory of the output files\n";
       print "** necessary inputs\n";
       print "Note: Selecting 'both' will give you ****.ginuke.root files at each energy step\n";
       die("\n");
   }
}

sub error_exit_g {
    die("You must set up GENIE before running this script.\n");
}

## Subroutine to clear values before doing another group ##

sub clear_values {
    undef @prbpdg;
    undef @prb;
    undef @tgt;
    undef @atom;
    undef @t;
    undef @k;
}
