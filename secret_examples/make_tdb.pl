#!/usr/bin/perl -w
#
#   Greetings and welcome to the new same auto_psisum/make_tdb script
#   Whichever latest GNU public licence applies.
#
#################################################################
#
# 18/Aug/11 : Updated to work with BLAST+ and chkparse
#
#################################################################
#
# TODO: Catch BLAST+ failures, at the moment these don't proogate back to the main loop to signal failures that should delete the tdb and not
#		    Enter the psichain.lst
#
#################################################################

use strict;
use English;
use FileHandle;
use Getopt::Long;
use lib("/blah");
use Data::Dumper;

#Assign our global, commandline variables
my $MIN_TDB_LINE_LENGTH = 5;
my $MIN_SEQUENCE_LENGTH = 5;
my $MAX_SEQ_LENGTH = 5000;
my $hDssp = {};
my $hX = {};
my $hY = {};
my $hZ = {};
my $aPhi = [];
my $aPsi = [];
my $aOmega = [];
my $aTsstruc = [];
my $aTrelacc = [];
my $aSeq = [];
my $hPsimat = {};
my $aIc = []; #array of insert codes
my $aRi = [];

my $aRescodes = ["A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S","T","W","Y","V","-","X"];
my $aSScodes = ["C","H","E","A","P","T"];
my $hAA = {
        'ALA'=>0,
        'ARG'=>1,
        'ASN'=>2,
        'ASP'=>3,
        'CYS'=>4,
        'GLN'=>5,
        'GLU'=>6,
        'GLY'=>7,
        'HIS'=>8,
        'ILE'=>9,
        'LEU'=>10,
        'LYS'=>11,
        'MET'=>12,
        'PHE'=>13,
        'PRO'=>14,
        'SER'=>15,
        'THR'=>16,
        'TRP'=>17,
        'TYR'=>18,
        'VAL'=>19,
        'GAP'=>20,
        'UNK'=>21,
            };

#Blosum62 values incase our mtx produces nothing.
my $aAAmat = [
    [4, -1, -2, -2, 0, -1, -1, 0, -2, -1, -1, -1, -1, -2, -1, 1, 0, -3,
     -2, 0, -2, -1, 0],
    [-1, 5, 0, -2, -3, 1, 0, -2, 0, -3, -2, 2, -1, -3, -2, -1, -1, -3,
     -2, -3, -1, 0, -1],
    [-2, 0, 6, 1, -3, 0, 0, 0, 1, -3, -3, 0, -2, -3, -2, 1, 0, -4,
     -2, -3, 3, 0, -1],
    [-2, -2, 1, 6, -3, 0, 2, -1, -1, -3, -4, -1, -3, -3, -1, 0, -1, -4,
     -3, -3, 4, 1, -1],
    [0, -3, -3, -3, 9, -3, -4, -3, -3, -1, -1, -3, -1, -2, -3, -1, -1, -2,
     -2, -1, -3, -3, -2],
    [-1, 1, 0, 0, -3, 5, 2, -2, 0, -3, -2, 1, 0, -3, -1, 0, -1, -2,
     -1, -2, 0, 3, -1],
    [-1, 0, 0, 2, -4, 2, 5, -2, 0, -3, -3, 1, -2, -3, -1, 0, -1, -3,
     -2, -2, 1, 4, -1],
    [0, -2, 0, -1, -3, -2, -2, 6, -2, -4, -4, -2, -3, -3, -2, 0, -2, -2,
     -3, -3, -1, -2, -1],
    [-2, 0, 1, -1, -3, 0, 0, -2, 8, -3, -3, -1, -2, -1, -2, -1, -2, -2,
     2, -3, 0, 0, -1],
    [-1, -3, -3, -3, -1, -3, -3, -4, -3, 4, 2, -3, 1, 0, -3, -2, -1, -3,
     -1, 3, -3, -3, -1],
    [-1, -2, -3, -4, -1, -2, -3, -4, -3, 2, 4, -2, 2, 0, -3, -2, -1, -2,
     -1, 1, -4, -3, -1],
    [-1, 2, 0, -1, -3, 1, 1, -2, -1, -3, -2, 5, -1, -3, -1, 0, -1, -3,
     -2, -2, 0, 1, -1],
    [-1, -1, -2, -3, -1, 0, -2, -3, -2, 1, 2, -1, 5, 0, -2, -1, -1, -1,
     -1, 1, -3, -1, -1],
    [-2, -3, -3, -3, -2, -3, -3, -3, -1, 0, 0, -3, 0, 6, -4, -2, -2, 1,
     3, -1, -3, -3, -1],
    [-1, -2, -2, -1, -3, -1, -1, -2, -2, -3, -3, -1, -2, -4, 7, -1, -1, -4,
     -3, -2, -2, -1, -2],
    [1, -1, 1, 0, -1, 0, 0, 0, -1, -2, -2, 0, -1, -2, -1, 4, 1, -3,
     -2, -2, 0, 0, 0],
    [0, -1, 0, -1, -1, -1, -1, -2, -2, -1, -1, -1, -1, -2, -1, 1, 5, -2,
     -2, 0, -1, -1, 0],
    [-3, -3, -4, -4, -2, -2, -3, -2, -2, -3, -2, -3, -1, 1, -4, -3, -2, 11,
     2, -3, -4, -3, -2],
    [-2, -2, -2, -3, -2, -1, -2, -3, 2, -1, -1, -2, -1, 3, -3, -2, -2, 2,
     7, -1, -3, -2, -1],
    [0, -3, -3, -3, -1, -2, -2, -3, -3, 3, 1, -2, 1, -1, -2, -2, 0, -3,
     -1, 4, -3, -2, -1],
    [-2, -1, 3, 4, -3, 0, 1, -1, 0, -3, -4, 0, -3, -3, -2, 0, -1, -4,
     -3, -3, 4, 1, -1],
    [-1, 0, 0, 1, -3, 3, 4, -2, 0, -3, -3, 1, -1, -3, -1, 0, -1, -3,
     -2, -2, 1, 4, -1],
    [0, -1, -1, -1, -2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, 0, 0, -2,
     -1, -1, -1, -1, 4]
];

#TODO: read in defaults from file rather than hard code
#my $list = '/webdata/data/cath_pdb/cath_list.txt';
my $list = '/home/dbuchan/make_tdb/cullpdb.lst';
my $output = "/home/dbuchan/make_tdb/psichain.lst";
#my $dssp = '/webdata/data/cath_pdb/dssp/';
my $dssp = '/home/dbuchan/make_tdb/';
my $DSSP = '/webdata/binaries/current/dssp/dsspcmbi';
#my $tdb = '/webdata/data/cath_pdb/tdb/';
my $tdb = '/home/dbuchan/make_tdb/';
my $blast = '/webdata/binaries/current/blast/bin/blastpgp';
my $evalue = 0.001;
my $blast_num_cores = 1;
my $chkparse = '/webdata/binaries/current/blast/bin/chkparse';
my $tcoffee = '/webdata/binaries/current/T-COFFEE_distribution_Version_7.54/bin/linux/t_coffee';
#my $pdb = '/webdata/data/cath_pdb/';
my $pdb = '/home/dbuchan/make_tdb/';
my $uniref = '/webdata/data/current/blast/db/uniref90_nofrag';
my $pdb_seq = '/webdata/data/current/blast/db/pdbaa_dir/cath_id_update.fa';
#my $tmp = '/webdata/tmp/';
my $tmp = '/home/dbuchan/make_tdb/';
#my $fsa = '/webdata/data/cath_pdb/fsa/';
my $fsa = '/home/dbuchan/make_tdb/';
#my $aln = '/webdata/data/cath_pdb/aln/';
my $aln = '/home/dbuchan/make_tdb/';
my $type = 'C';
#my $parsesource = '';
my $parsesource = '/home/dbuchan/make_tdb/parse_source';
#fasta file of scop domains
my $structuralseqdb = '/home/dbuchan/make_tdb/scop';

get_options();

my $identifier = '';
my $pdbcode ='';
my $chain_id = '';
my $pdb_path = '';
my $dssp_path = '';
my $tdb_path = '';

my $fhInput = new FileHandle($list,"r");
my $fhOutput = new FileHandle($output,"w");

#This loop is the main loop where things happen (whoo yay!)
while(my $line = $fhInput->getline)
{

	set_identifiers($line);
    #if ($identifier !~ /2pwaA0/){next;}

	#We are skipping this pdb as it can't be properly parsed
	#if ($identifier !~ /4ayoA0/){next;}

	print "Creating TDB for $identifier\n";
	`mkdir -p /webdata/tmp/autoupdate`;
    my $tdb_check = check_tdb();
    if($tdb_check == 1)
    {#We already have a tdb, so print the id to psichain.lst
        print "Valid TDB for $identifier exists.\nSkipping...\n";
		print $fhOutput $identifier."\n";
        next;
    }

	#exit;
    my $pdb_check = check_pdb();
    if($pdb_check == 0)
    {
        print STDERR "No valid pdb file for $identifier found.\nSkipping...\n";
        next;
    }

    my $dssp_check = check_dssp();
    if($dssp_check == 0)
    {
        print STDERR "Could not find or generate dssp file for $identifier\nSkipping\n";
        next;
    }
	#We've got this far, the data files are in place and there is no previous tdb file. So we open a new one for data entry
    my $fhTDBOutput = new FileHandle($tdb_path,"w");
    my $date_stamp = scalar localtime;
    print $fhTDBOutput "#TDB $identifier $date_stamp";

    #This function actually creates the TDB data and adds it to the file
    my $sequence_len = summary($fhTDBOutput);

    $fhTDBOutput->close;

    if ($sequence_len < $MIN_SEQUENCE_LENGTH)
    {
        print $identifier." - length error (len=".$sequence_len.")!\nClearing out tdb\n";
        $fhTDBOutput->close;
       `rm -f $tdb_path`;
	   #We should delete the pdb and dssp files for this tdb so we redo them
	   #Whenever we try and build a tdb (in case they fix the pdb in the meantime
	   print "Removing: $pdb_path\n";
	   `rm -f $pdb_path`;
	   print "Removing: $dssp_path\n";
	   `rm -f $dssp_path`;
    }
	else
	{#don't print to psichains unless it's a success!
		print $fhOutput $identifier."\n";
    }
	#tidy up any lose files that we don't want to keep
   clean_data();

    #last;
}

$fhInput->close;
$fhOutput->close;

sub summary
{
    my($fhTDBOutput) = @ARG;
    my $seq_length = 0;
    my $dssp_length = 0;
    my $nres = 0;
    my $compnd = '';

    #Call our C based DSSP and pdb parser
    ($seq_length, $nres, $compnd) = parse_source_data();
    printf $fhTDBOutput " %5d %s\n", $nres, $compnd;
    if($nres < $MIN_SEQUENCE_LENGTH)
    {
        return($nres)
    }

    my $chk_file = $tmp."/".$identifier.".chk";
    print STDERR "CHECKING CHK: ".$chk_file."\n";
    #Test that there isn't already a .chk file floating about.
    if(! -e $chk_file)
    #if(-e $chk_file)
	{
        my $fsa_file = $fsa.$identifier.".fsa";
        print_fsa($fsa_file,$seq_length);

        my $slx_file = $tmp."/".$identifier.".slx";
        print STDERR "CHECKING SLX: ".$slx_file."\n";
        my $error_test = 1;
        my $aFamilies = [];
        #Test that there isn't an slx file either
        if (! -e $slx_file)
        {
            print STDERR "FINDING STRUCTURAL RELATIVES\n";
			#if we're looking at a CATH domain we don't really need to do this we can just grab the ID as per the
			#H family membership
            #exit;
			($aFamilies, $error_test )= find_structural_alignments($fsa_file);
            if($error_test == 0){return(0);}
            #print "aFamilies array dump:\n";
            #print Dumper $aFamilies;
            #exit;
            if(scalar @$aFamilies > 0)
            {
                #use t_coffee to combine our sequence with the relavent structural alignments.
                print STDERR "BUILDING SEED ALIGNMENT\n";
                $error_test = build_seed_alignment($fsa_file,$slx_file,$aFamilies);
                if($error_test == 0){return(0);}
            }
         }
            #use the above alignment to find distant relatives using PSI-BLAST.
            print STDERR "FINDING ALL RELATIVES\n";
            $error_test = find_relatives($fsa_file,$slx_file, $chk_file, scalar(@$aFamilies));
            if($error_test == 0){return(0);}
			#next convert the .chk to the .mtx file
            ##rewrite this
			print STDERR "CONVERTING CHECKPOINT\n";
            convert_chk($fsa_file);
            if($error_test == 0){return(0);}

            #read in the matrix and populate the psimat array
            print STDERR "READING MATRIX\n";
            $error_test = read_matrix($nres);
            if($error_test == 0){return(0);}

            #output our data to the tdb file
            print STDERR "OUTPUTING TDB DATA\n";
            print_tdb_data($fhTDBOutput,$nres);


    }
    return($seq_length);
}

#clean up any files we don't care to keep around
sub clean_data
{
    print STDERR "TIDYING\n";
    `rm -f $fsa/$identifier.pn`;
    `rm -f $fsa/$identifier.sn`;
    `rm -f $fsa/$identifier.mtx`;
    `rm -f $tmp/$identifier.aux`;
    `rm -f $tmp/$identifier.mn`;
    `rm -f $tmp/$identifier.tcoffee.pir_aln`;
    `rm -f $tmp/blast_log.bls`;
    `rm -f $tmp/data_summary`;
    `rm -f $tmp/initial.bls`;
}

#lastly we print out the data into the tdb file
sub print_tdb_data
{
    my($fhTDBOutput, $nres) = @ARG;

    for (my $i = 0; $i < $nres; $i++)
    {
       printf $fhTDBOutput  "%4d %s %s %3d %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %4d%c ",
                ($i+1), @$aRescodes[@$aSeq[$i]], @$aSScodes[@$aTsstruc[$i]],
                @$aTrelacc[$i], @$aPhi[$i], @$aPsi[$i], @$aOmega[$i],
                $hX->{$i}{"NATOM"}, $hY->{$i}{"NATOM"}, $hZ->{$i}{"NATOM"},
                $hX->{$i}{"CAATOM"}, $hY->{$i}{"CAATOM"}, $hZ->{$i}{"CAATOM"},

                $hX->{$i}{"CATOM"}, $hY->{$i}{"CATOM"}, $hZ->{$i}{"CATOM"},
                $hX->{$i}{"OATOM"}, $hY->{$i}{"OATOM"}, $hZ->{$i}{"OATOM"},
                $hX->{$i}{"CBATOM"}, $hY->{$i}{"CBATOM"}, $hZ->{$i}{"CBATOM"},
                @$aRi[$i], @$aIc[$i];

        for (my $j = 0; $j < 20; $j++)
        {
            printf $fhTDBOutput "%6s", $hPsimat->{$i}{$j};
        }
        print $fhTDBOutput "\n";
    }

}

#read in the psiblast matrix data and populate our psimat array (or fill with default values if there was nothin in the matrix)
sub read_matrix
{
    my ($nres) = @ARG;
    my $psimat_count = 0;
    my $valid_matrix = 1;
    if(-e  $fsa.$identifier.".mtx")
    {
        my $fhMtx = new FileHandle($fsa.$identifier.".mtx","r");
        while(my $line = $fhMtx->getline)
        {
            if($line =~ /^-32768\s+(.+?)\s+.+?\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+(.+?)\s+.+?\s+(.+?)\s+/)
            {
                $hPsimat->{$psimat_count}{$hAA->{ALA}} = $1;
                $hPsimat->{$psimat_count}{$hAA->{CYS}} = $2;
                $hPsimat->{$psimat_count}{$hAA->{ASP}} = $3;
                $hPsimat->{$psimat_count}{$hAA->{GLU}} = $4;
                $hPsimat->{$psimat_count}{$hAA->{PHE}} = $5;
                $hPsimat->{$psimat_count}{$hAA->{GLY}} = $6;
                $hPsimat->{$psimat_count}{$hAA->{HIS}} = $7;
                $hPsimat->{$psimat_count}{$hAA->{ILE}} = $8;
                $hPsimat->{$psimat_count}{$hAA->{LYS}} = $9;
                $hPsimat->{$psimat_count}{$hAA->{LEU}} = $10;
                $hPsimat->{$psimat_count}{$hAA->{MET}} = $11;
                $hPsimat->{$psimat_count}{$hAA->{ASN}} = $12;
                $hPsimat->{$psimat_count}{$hAA->{PRO}} = $13;
                $hPsimat->{$psimat_count}{$hAA->{GLN}} = $14;
                $hPsimat->{$psimat_count}{$hAA->{ARG}} = $15;
                $hPsimat->{$psimat_count}{$hAA->{SER}} = $16;
                $hPsimat->{$psimat_count}{$hAA->{THR}} = $17;
                $hPsimat->{$psimat_count}{$hAA->{VAL}} = $18;
                $hPsimat->{$psimat_count}{$hAA->{TRP}} = $19;
                $hPsimat->{$psimat_count}{$hAA->{TYR}} = $20;
                $psimat_count++;
            }
        }
        $fhMtx->close;
    }
    else
    {
        return(0);
    }

    if($nres != $psimat_count)
    {
        $valid_matrix = 0;
    }

    #If the matrix was invalid for some reason (no lines of data or a mismatched nubmer of lines)
    if(!$valid_matrix)
    {
        # Use matrix scores by default */
        for (my $i = 0; $i < $nres; $i++)
        {

            if (@$aSeq[$i] < 20)
            {
                for (my $j = 0; $j < 20; $j++)
                {
                   $hPsimat->{$i}{$j} = @{@$aAAmat[@$aSeq[$i]]}[$j] * 100;
                }
             }
             else
             {
                for (my $j = 0; $j < 20; $j++)
		        {
                    $hPsimat->{$i}{$j} = 0;
                }
             }
         }
         $psimat_count = $nres;
    }
    #print Dumper $hPsimat;
    return($psimat_count);
}

#write out the pn and sn files you need then run makemat
sub convert_chk
{
    my($fsa_file) = @ARG;

    #`/bin/cp $fsa ./`;

    #my $fhPN = new FileHandle($fsa."/".$identifier.".pn","w");
    #print $fhPN $identifier.".chk";
    #$fhPN->close;
#
#    my $fhSN = new FileHandle($fsa."/".$identifier.".sn","w");
#    print $fhSN $identifier.".fsa";
#    $fhSN->close;

    print STDERR "RUNNING: ".$chkparse." ".$fsa.$identifier.".chk > ".$fsa.$identifier.".mtx\n";
    `$chkparse $fsa$identifier.chk > $fsa$identifier.mtx`;
    if($? != 0)
    {
        print STDERR $fsa.$identifier." : Error when running chkparse: command did not run\n";
        return(0);
    }
    if(! -e $fsa.$identifier.".mtx")
    {
        print STDERR $fsa.$identifier." : no mtx file generated\n";
        return(0);
    }

    return(1);
}

#routine runs psi-blast/blastpgp to generate the .chk and mtx files for our sequence
#This rewrite is for blast+
sub find_relatives
{
    my($fsa, $slx, $chk, $family_count) = @ARG;
    my $nblasthits = 0;
    my $pass = 0;

    #Here we run keep running 2 iterations of our blast or until the number of hits reaches
    #our max level; 6000/3000.
    my $max_relatives = 0;

    if($type =~ /C/)
    {
        $max_relatives = 6000;
    }
    else
    {
        $max_relatives = 3000;
    }
    my $blast_cmd = '';

	do
    {
        #test if this is the first iteration, if yes run one blast command in no then run the other
        $blast_cmd = select_blast_command($fsa,$slx, $chk, $nblasthits, $family_count);
        print STDERR "RUNNING: ".$blast_cmd."\n";
        #print STDERR "Hi there\n";
        `$blast_cmd`;
        #print STDERR "Hi there\n";
        #exit;
        #Check that worked
        if($? != 0)
        {
            print STDERR $identifier." : Error when running blast to find relatives: command did not run\n";
            return(0);
        }
        my $fhBlastOut = new FileHandle($tmp."/blast_log.bls","r");
        if(! $fhBlastOut)
        {
            print STDERR $identifier." : Could not open blast_log.bls!\n";
            return(0);
        }

		my $results_found = 0;
        while(my $line = $fhBlastOut->getline)
        {
            #print $line;
			if($line =~ /Number of sequences better than\s.+?:\s(\d+)/)
            {
                   $nblasthits = $1;
            }

			#Count up the number of hits in case the summary stats aren't at the bottom of the file
			if($line =~ /^Sequences\sproducing\ssignificant\salignments/)
			{
				$results_found++;
			}
			if($results_found == 3)
			{
				if($line =~ /Score\s+E/){next;}
				if($line =~ /^\s{2}.{66}\s+\S+\s+(\S+)/)
				{
					my $local_evalue = $1;
					#print $line;
					if($pass == 0)
					{
						if($local_evalue <= 0.1)
						{
							$nblasthits++;
						}
					}
					else
					{
						if($local_evalue <= 20)
						{
							$nblasthits++;
						}
					}
				}
			}
        }
        if (!$pass)
        {
            printf STDERR "NBLASTHITS ".$nblasthits."\n";
        }
		#exit;
        $pass++;
    } while($nblasthits < $max_relatives && $pass < 2);

	printf STDERR "NBLASTHITS ".$nblasthits."\n";
    return(1);
}

#routine runs psi-blast/blastpgp to generate the .chk and mtx files for our sequence
sub find_relatives_old
{
    my($fsa, $slx, $chk, $family_count) = @ARG;
    my $nblasthits = 0;
    my $pass = 0;

    #Here we run keep running 2 iterations of our blast or until the number of hits reaches
    #our max level; 6000/3000.
    my $max_relatives = 0;

    if($type =~ /C/)
    {
        $max_relatives = 6000;
    }
    else
    {
        $max_relatives = 3000;
    }
    my $blast_cmd = '';
    do
    {
        #test if this is the first iteration, if yes run one blast command in no then run the other
        $blast_cmd = select_blast_command($fsa,$slx, $chk, $nblasthits, $family_count);
        print STDERR "RUNNING: ".$blast_cmd."\n";
        #print STDERR "Hi there\n";
        `$blast_cmd`;
        #print STDERR "Hi there\n";
        #exit;
        #Check that worked
        if($? != 0)
        {
            print STDERR $identifier." : Error when running blast to find relatives: command did not run\n";
            return(0);
        }
        my $fhBlastOut = new FileHandle($tmp."/blast_log.bls","r");
        if(! $fhBlastOut)
        {
            print STDERR $identifier." : Could not open blast_log.bls!\n";
            return(0);
        }

        while(my $line = $fhBlastOut->getline)
        {
            #print $line;
			if($line =~ /Number of sequences better than\s.+?:\s(\d+)/)
            {
                   $nblasthits = $1;
            }
        }
        if (!$pass)
        {
            printf STDERR "NBLASTHITS ".$nblasthits."\n";
        }
		#exit;
        $pass++;
    } while($nblasthits < $max_relatives && $pass < 2);

    return(1);
}

#small routine takes a couple of parameters and decides which blastcommand we're going to run
sub select_blast_command
{
    my($fsa, $slx, $chk,$nblasthits, $family_count) = @ARG;
    my $command = '';
    if($nblasthits == 0)
    {
        if($family_count)
        {
            #$command = "$blast -a 4 -v 10000 -e 0.1 -j 3 -b 0 -h ".$evalue." -d ".$uniref." -i ".$fsa." -B ".$slx." -C ".$chk." -o ".$tmp."blast_log.bls";
            #$command = "$blast -num_threads 4 -num_descriptions 10000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_msa ".$slx." -out_pssm ".$chk." > ".$tmp."blast_log.bls";
            #$command = "$blast -comp_based_stats 1 -num_descriptions 10000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_msa ".$slx." -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
            $command = "$blast -num_threads $blast_num_cores -comp_based_stats 1 -num_descriptions 10000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_msa ".$slx." -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
        }
        else
        {
            #$command = "$blast -a 4 -v 8000 -e 0.1 -j 3 -b 0 -h ".$evalue." -d ".$uniref." -i ".$fsa." -C ".$chk." -o ".$tmp."blast_log.bls";
            #$command = "$blast -num_threads 4 -num_descriptions 8000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -query ".$fsa." -out_pssm ".$chk." > ".$tmp."blast_log.bls";
            #$command = "$blast -comp_based_stats 1 -num_descriptions 8000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -query ".$fsa." -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
            $command = "$blast -num_threads $blast_num_cores -comp_based_stats 1 -num_descriptions 8000 -evalue 0.1 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -query ".$fsa." -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
        }
    }
    else
    {
        #move our chk file out of the way
        `/bin/mv -f $chk psisum_tmp.chk`;
        if($family_count)
        {
            #$command = "$blast -a 4 -v 10000 -e 20 -j 3 -b 0 -h ".$evalue." -d ".$uniref." -i ".$fsa." -R psisum_tmp.chk -B ".$slx." -C ".$chk." -o ".$tmp."blast_log.bls";
            #$command = "$blast -num_threads 4 -num_descriptions 10000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." > ".$tmp."blast_log.bls";
            #$command = "$blast -comp_based_stats 1 -num_descriptions 10000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
            $command = "$blast -num_threads $blast_num_cores -comp_based_stats 1 -num_descriptions 10000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
        }
        else
        {
            #$command = "$blast -a 4 -v 8000 -e 20 -j 3 -b 0 -h ".$evalue." -d ".$uniref." -i ".$fsa." -R psisum_tmp.chk -C ".$chk." -o ".$tmp."blast_log.bls";
            #$command = "$blast -num_threads 4 -num_descriptions 8000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." > ".$tmp."blast_log.bls";
            #$command = "$blast -comp_based_stats 1 -num_descriptions 8000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
            $command = "$blast -num_threads $blast_num_cores -comp_based_stats 1 -num_descriptions 8000 -evalue 20 -num_iterations 3 -num_alignments 0 -inclusion_ethresh ".$evalue." -db ".$uniref." -in_pssm psisum_tmp.chk -out_pssm ".$chk." -out ".$tmp."blast_log.bls";
        }
    }

    return($command);
}

#Take the list of structural alignments and run t_coffee to align them and our target sequence together, then parse the file to output
#psiblast slx file
sub build_seed_alignment
{
    my($fasta, $slx,$aFamilies) = @ARG;
    #We move that files fsa and alignments to temp files because t_coffee, in some enviroments, has trouble handling v.long file names.
    `cp $fasta $tmp/tmp.fsa`;
    my $tcoffee_cmd = $tcoffee." -in S".$tmp."/tmp.fsa";

    my $align_count = 0;
    foreach my $structural_alignment_location (@$aFamilies)
    {
        print $structural_alignment_location."\n";
        my $temp_struct = "tmp_struct_".$align_count.".aln";
        $align_count++;
        `cp $structural_alignment_location $tmp/$temp_struct`;
        $tcoffee_cmd .= " R".$tmp."/".$temp_struct;
    }
    $tcoffee_cmd .= " Mlalign_id_pair Mslow_pair -output=pir_aln -outfile=".$tmp."/".$identifier.".tcoffee.pir_aln";
    print STDERR $tcoffee_cmd."\n";

   `$tcoffee_cmd`;
    #Check that worked
    if($? != 0)
    {
        print STDERR $identifier." : Error when running t_coffee: command did not run\n";
        return(0);
    }
    my $fhTCoffee = new FileHandle($tmp."/".$identifier.".tcoffee.pir_aln","r");
    if(! $fhTCoffee)
    {
        print STDERR $identifier." : Could not open ".$tmp."/".$identifier.".tcoffee.pir_aln\n";
        return(0);
    }
    my $current_id = '';
    my $hResults = {};
    my $ids = 0;
    #read in t_coffee alignment
    while(my $line = $fhTCoffee->getline)
    {
        chomp $line;
        if($line =~ /^>.+;(.+)/)
        {
            $current_id = $1;
            $ids++;
            $fhTCoffee->getline;
        }
        elsif($line =~ /^\*/)
        {
            next;
        }
        else
        {
            if(exists $hResults->{$ids}{$current_id})
            {
                $hResults->{$ids}{$current_id} .= $line;
            }
            else
            {
                $hResults->{$ids}{$current_id} = $line;
            }
        }

    }
    $fhTCoffee->close;
    my $fhSLX = new FileHandle($slx,"w");
    #output .slx file
    foreach my $count (sort {$a <=> $b} keys %$hResults)
    {
        foreach my $id (keys %{$hResults->{$count}})
        {
         my $print_id = $id;
         if($print_id =~ /^.+?\|(.+?)\|.+/)
         {
            $print_id = $1;
         }
         printf $fhSLX "%-8s",$print_id;
         print $fhSLX $hResults->{$count}{$id}."\n";
        }
    }
    $fhSLX->close;
    `rm -f $tmp/tmp.fsa`;
    `rm -f $tmp/tmp_struct*`;
    return(1);
}

#Uses blast to search our database of structural families for families related to our sequence, returns an array of all the families it found
# NOTE: we only take the first (highest scoring and lowest e-value) structural alignment. t_coffee doesn't seem to like combining structural alignments of
# differing lengths.
sub find_structural_alignments
{
    my($fasta) = @ARG;
    my $lastcode = '';
    my $hFamilies = {};
    my $aFamilies = [];
    my $blast_log = $tmp."/initial.bls";
    #Run the structural sequence db blast
    print STDERR "RUNNING: $blast -num_threads $blast_num_cores -num_descriptions 500 -evalue 0.001 -num_iterations 1 -num_alignments 0 -db $structuralseqdb -query $fasta -out $blast_log\n";
	`$blast -num_threads $blast_num_cores -num_descriptions 500 -evalue 0.001 -num_iterations 1 -num_alignments 0 -db $structuralseqdb -query $fasta -out $blast_log`;

	#Check that worked
    if($? != 0)
    {
        print STDERR $identifier." : Error when running Initial BLAST: command did not run\n";
        return(0,0);
    }
    #Check the results file is there
    my $fhBlast = new FileHandle($blast_log,"r");
    if(! $fhBlast)
    {
        print STDERR $identifier." : Could not open initial.bls\n";
        return(0,0);
    }

    #parse the blast hits for the scop/cath codes of the best hitting sequences
    my $found_hits = 0;
    LOOP: while(my $line = $fhBlast->getline)
    {
        if($line =~ /^Sequences\sproducing\ssignificant\salignments/){$found_hits = 1;next;}
        if($line =~ /^\s+Database:/){$found_hits = 0;next;}
        if($found_hits)
        {
            #print $line;
            #only add data for rows that list a structural alignment
            if($line =~ /^(.+?)\s+(\d+)\.(\d+)\.(\d+)\.(\d+)(__SSG.__\d+)/)
            {

                   #we use $2 to identify which CORA alignment we should be using with tcoffee

                   print STDERR $1." ".$2.".".$3.".".$4.".".$5.$6."\n";
                    my $c = sprintf("%05d", $2);
                    my $a = sprintf("%05d", $3);
                    my $t = sprintf("%05d", $4);
                    my $h = sprintf("%05d", $5);

                   my $struct_family = $c.".".$a.".".$t.".".$h.$6;
                   my $structural_alignment_location = '';
                   if($type =~ /C/)
                   {
                       $structural_alignment_location = $aln.$struct_family.".aln_domains_mafft.fa";

                   }
                   elsif($type =~ /D/)
                   {
                       $structural_alignment_location = $aln.$struct_family.".aln_domains_mafft.fa";
                   }
                   # add alignment location to non_redundant hash
                   $hFamilies->{$structural_alignment_location} = 1;
                   last LOOP;
            }
        }
    }
    $fhBlast->close;
    #print Dumper($hFamilies);
    foreach my $path (keys %$hFamilies)
    {
        if(-e $path)
        {
            push @$aFamilies, $path;
        }
    }
    #print Dumper $aFamilies;

    return($aFamilies,1);
}

#prints out the fasta file of the sequence read from the dssp file
sub print_fsa
{
    my($file,$seqlen) = @ARG;
    #output a fasta file
    print STDERR "WRITING: ".$file."\n";
    my $fhFasta = new FileHandle($file,"w");
    print $fhFasta ">".$identifier."\n";
    #print Dumper @$aSeq;
    for (my $i = 0; $i < $seqlen; $i++)
    {
        if (@$aSeq[$i] < 20)
        {
               print $fhFasta @$aRescodes[@$aSeq[$i]];
	}
        else
        {
            print $fhFasta "X";
        }
    }
    print $fhFasta "\n";
    $fhFasta->close;
}

#routine runs the bit of C code the reads and summarises the dssp and pdb files.
sub parse_source_data
{
    #run the c code that parses the dssp and pdb files and cludges the data together
    print STDERR "RUNNING: $parsesource $dssp_path $pdb_path $type $chain_id > $tmp/data_summary\n";
    `$parsesource $dssp_path $pdb_path $type $chain_id > $tmp/data_summary`;
    my $found_dssp = 0;
    my $found_phi = 0;
    my $found_psi = 0;
    my $found_omega = 0;
    my $found_x = 0;
    my $found_y = 0;
    my $found_z = 0;
    my $found_tsstruc = 0;
    my $found_trelacc = 0;
    my $found_seq = 0;
    my $found_ri = 0;
    my $found_ic = 0;
    my $sequence_length = 0;
    my $nres = 0;
    my $compnd = '';

    my $fhSummary = new FileHandle($tmp."/data_summary","r");
    while(my $line = $fhSummary->getline)
    {
        chomp $line;
        if($line =~ /DSSPLEN:\s(\d+)/){$sequence_length = $1;}
        if($line =~ /NRES VALUE:\s(\d+)/){$nres = $1;}
        if($sequence_length != $nres)
        {
            $sequence_length=$nres;
        }
        if($line =~ /COMPND VALUE:\s(.+)/){$compnd = $1;}
        if($line =~ /BEGIN DSSP SUMMARY/){$found_dssp = 1;next;}
        if($line =~ /END DSSP SUMMARY/){$found_dssp = 0;next;}
        if($line =~ /BEGIN PHI DUMP/){$found_phi = 1;next;}
        if($line =~ /END PHI DUMP/){$found_phi = 0;next;}
        if($line =~ /BEGIN PSI DUMP/){$found_psi = 1;next;}
        if($line =~ /END PSI DUMP/){$found_psi = 0;next;}
        if($line =~ /BEGIN OMEGA DUMP/){$found_omega = 1;next;}
        if($line =~ /END OMEGA DUMP/){$found_omega = 0;next;}
        if($line =~ /BEGIN OMEGA DUMP/){$found_omega = 1;next;}
        if($line =~ /END OMEGA DUMP/){$found_omega = 0;next;}
        if($line =~ /BEGIN X DUMP/){$found_x = 1;next;}
        if($line =~ /END X DUMP/){$found_x = 0;next;}
        if($line =~ /BEGIN Y DUMP/){$found_y = 1;next;}
        if($line =~ /END Y DUMP/){$found_y = 0;next;}
        if($line =~ /BEGIN Z DUMP/){$found_z = 1;next;}
        if($line =~ /END Z DUMP/){$found_z = 0;next;}
        if($line =~ /BEGIN TSSTRUC DUMP/){$found_tsstruc = 1;next;}
        if($line =~ /END TSSTRUC DUMP/){$found_tsstruc = 0;next;}
        if($line =~ /BEGIN TRELACC DUMP/){$found_trelacc = 1;next;}
        if($line =~ /END TRELACC DUMP/){$found_trelacc = 0;next;}
        if($line =~ /BEGIN SEQ DUMP/){$found_seq = 1;next;}
        if($line =~ /END SEQ DUMP/){$found_seq = 0;next;}
        if($line =~ /BEGIN IC DUMP/){$found_ic = 1;next;}
        if($line =~ /END IC DUMP/){$found_ic = 0;next;}
        if($line =~ /BEGIN RI DUMP/){$found_ri = 1;next;}
        if($line =~ /END RI DUMP/){$found_ri = 0;next;}

        if($found_dssp)
        {
            my $aEntries = [];
            @$aEntries = split /\t/, $line;
            $hDssp->{@$aEntries[0]}{RESID} = @$aEntries[1];
            $hDssp->{@$aEntries[0]}{INSCODE} = @$aEntries[2];
            $hDssp->{@$aEntries[0]}{SSTRUC} = @$aEntries[3];
            $hDssp->{@$aEntries[0]}{ACC} = @$aEntries[4];
        }
        if($found_phi)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aPhi[@$aEntries[0]] = @$aEntries[1];
        }
        if($found_psi)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aPsi[@$aEntries[0]] = @$aEntries[1];
        }
        if($found_omega)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aOmega[@$aEntries[0]] = @$aEntries[1];
        }
        if($found_x)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            $hX->{@$aEntries[0]}{@$aEntries[1]} = @$aEntries[2];
        }
        if($found_y)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            $hY->{@$aEntries[0]}{@$aEntries[1]} = @$aEntries[2];
        }
        if($found_z)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            $hZ->{@$aEntries[0]}{@$aEntries[1]} = @$aEntries[2];
        }
        if($found_tsstruc)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aTsstruc[@$aEntries[0]] = @$aEntries[1];
        }
        if($found_trelacc)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aTrelacc[@$aEntries[0]] = @$aEntries[1];
        }
        if($found_seq)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aSeq[@$aEntries[0]] = @$aEntries[1];
        }

        if($found_ic)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aIc[@$aEntries[0]] = @$aEntries[1];
        }

        if($found_ri)
        {
            my $aEntries = [];
            @$aEntries = split /\s/, $line;
            @$aRi[@$aEntries[0]] = @$aEntries[1];
        }
    }

    $fhSummary->close;

    return($sequence_length,$nres,$compnd);
}


#check for a valid dssp file or create one if not present
sub check_dssp
{
    print $dssp_path."\n";
    my $wc_out = `wc -m $dssp_path`;
    my $aEntries = [];
    @$aEntries = split /\s+/, $wc_out;

    if(-e $dssp_path && @$aEntries[0] > 300)
    {
        return(1);
    }
    else
    {
        print "Running: dssp $pdb_path $dssp_path\n";
        `$DSSP $pdb_path $dssp_path`;
        if($? == 0)
        {
           return(1);
        }
        else
        {
			`rm -f $pdb_path`;
			`rm -f $dssp_path`;
           return(0);
        }
    }
}

#Check for the pdb flatfile we need for this tdb, if not there try and get it.
sub check_pdb
{
 	print $pdb_path."\n";
    if(-e $pdb_path)
    {
        return(1);
    }
    else
    {
        if($type eq "D")
        {
            #don't do anything for domains, all the domain pdbs should come in a synced bundle from CATH.
            #if(-e $pdb.)
			#{
			#	return(1)
			#}
			#else
			#{
				return(0);
        	#}
		}
        elsif($type eq "C")
        {
            print "Running: wget -O $pdb_path ftp://ftp.ebi.ac.uk/pub/databases/msd/pdb_uncompressed/pdb$pdbcode.ent\n";
            `wget -O $pdb_path ftp://ftp.ebi.ac.uk/pub/databases/msd/pdb_uncompressed/pdb$pdbcode.ent`;
            if($? == 0)
            {
				my $pdb_size = `wc -l $pdb_path`;
				if($pdb_size =~ /^(\d+)\s/)
				{
					$pdb_size = $1;
				}
				print "PDB SIZE : ".$pdb_size."\n";
				if($pdb_size == 0)
				{
					`rm -f $pdb_path`;
					return(0);
				}
				else
				{
                	return(1);
				}
            }
            else
            {
				`rm -f $pdb_path`;
                return(0);
            }
        }
    }
}

#check if TDB file exists and that it has something in it.
sub check_tdb
{
	#print $tdb_path."\n";
    if(-e $tdb_path)
    {
        my $fhTDB = new FileHandle($tdb_path,"r");
        my $line_count = 0;
        while(my $line = $fhTDB->getline)
        {
            $line_count++;
        }
		#print $line_count."\n";
       if($line_count > $MIN_TDB_LINE_LENGTH)
       {
            return(1);
       }
       else
       {
           return(0);
       }
    }
    else
    {
        return(0);
    }
}

sub set_identifiers
{
        my($line) = @ARG;
        if($type eq "C")
        {
            if($line =~ /^(.{5})/)
            {
                $identifier = $1;
                #if the pdb code only contain a code and chain id add a default domain number
                if(length $identifier == 5)
                {
                    $identifier.="0";
                }
            }
        }
        elsif($type eq "D")
        {
            if($line =~ /^(.{7})/)
            {
                $identifier = $1;
            }
            $pdbcode = $identifier;
        }

        #make all alpha characters lower case
        $identifier = lc $identifier;
        #reset the chain id uppercase
        $identifier =~ s/^(.{4})([a-z])/$1.(uc $2)/e;
        $pdbcode = substr $identifier, 0 , 4;
        $chain_id = substr $identifier, 4 , 1;
        if($type =~ /C/)
        {
            $pdb_path = $pdb."/pdb".$pdbcode.".ent";
            $dssp_path = $dssp."/".$pdbcode.".dssp";
	}
        if($type =~ /D/)
        {
            $pdb_path = $pdb."/".$identifier;
	    $dssp_path = $dssp."/".$identifier.".dssp";
        }
        #$dssp_path = $dssp."/".$pdbcode.".dssp";
        $tdb_path = $tdb."/".$identifier.".tdb";
}

sub get_options
{
    GetOptions(
                'i|list=s' => \$list,
                'o|output=s' => \$output,
                'd|dssp=s' => \$dssp,
                's|dsspbin=s' => \$DSSP,
                't|tdb=s' => \$tdb,
                'u|uniref=s' => \$uniref,
                'b|blast=s' => \$blast,
                'v|evalue=f' => \$evalue,
                'h|threads=i' => \$blast_num_cores,
                'm|chkparse=s' => \$chkparse,
                'c|tcoffee=s' => \$tcoffee,
                'p|pdb=s' => \$pdb,
                'q|pdb_seq=s' => \$pdb_seq,
                'r|tmp=s' => \$tmp,
                'f|fsa=s' => \$fsa,
                'a|aln=s' => \$aln,
                'y|type=s' => \$type,
                'e|parsesource=s' => \$parsesource,
                'l|structuralseqs=s' => \$structuralseqdb
              );
}

#i|list = the list of pdb or cath chains (cullpdb.lst)
#o|output = erm... (psichains.lst)
#d|dssp = location of the dssp directory
#s|dsspbin = location of the dssp executable
#t|tdb = location of the tdb directory, where you're going to write your tdb files.
#u|uniref = location of the uniref blast database you're using
#b|blast = location of the PSIBLAST executable
#v|evalue = the blast evalue we use when looking for sequence relatives
#h|threads = number of cores used to run PSIBLAST
#m|chkparse = location of the chkparse executable
#c|tcoffee = location of the tcoffee binary
#p|pdb = location of all the pdb coordinate files you're using could be cath domains or pdb chains
#q|pdb_seq = location of the blast database file with all the chain'ss/domain's sequences, names must be as per the location in -l and -p
#r|tmp = location of whichever tmp or scratch dir you're using
#f|fsa = location of all the fasta files for each cullpdb.lst domain/chain
#a|aln = location of the cora/structural alignments for the domains/chains
#y|type = the type of tdb you are building chains or domains C|D
#e|parsesource = location of the parsesource exe
#l|structuralseqs = location of the blast db of the sequences that are in the structural alignments

#dev command
#./make_tdb.pl -i /webdata/data/cath_pdb/cath_list.txt -o output -d /webdata/data/cath_pdb/dssp/ -D /webdata/binaries/current/dssp/dsspcmbi -t /webdata/data/cath_pdb/tdb/ -u /webdata/data/current/blast/db/uniref90_nofrag -b /webdata/binaries/current/blast/ -c /usr/local/bin/t_coffee -p /webdata/data/cath_pdb/ -q /webdata/data/current/blast/db/pdbaa_dir/cath_id_update.fa -r /webdata/tmp/ -f /webdata/data/cath_pdb/fsa/ -s /webdata/data/cath_pdb/aln -y C

#cluster command for whole chains
#./make_tdb.pl -i /cluster/project0/new_tdb/culltest.lst -o /cluster/project0/new_tdb/cath_chain_tdb/psichains.lst -d /cluster/project0/new_tdb/dssp/ -s /cluster/project0/new_tdb/bin/dssp/dsspcmbi -t /cluster/project0/new_tdb/cath_chain_tdb/ -u /cluster/project0/new_tdb/blast_db/uniref90.fasta -b /cluster/project0/new_tdb/bin/blast/blastpgp -c /cluster/project0/new_tdb/bin/T-COFFEE_distribution_Version_8.91/bin/binaries/linux/t_coffee -p /cluster/project0/new_tdb/pdb/ -q /cluster/project0/new_tdb/cath_data/CathDomainSeqs.S100.ATOM.annotated -r /cluster/project0/new_tdb/cath_chain_tmp/ -f /cluster/project0/new_tdb/cath_chain_tmp/ -a /cluster/project0/new_tdb/cath_data/v3_3_0-structural_alignments/ -y C -e /cluster/project0/new_tdb/bin/parse_source -l /cluster/project0/new_tdb/cath_data/CathDomainSeqs.S100.ATOM.annotated -m /cluster/project0/new_tdb/bin/blast/makemat

#cluster command for domains
#./make_tdb.pl -i /cluster/project0/new_tdb/cullsrep.lst -o /cluster/project0/new_tdb/cath_chain_tdb/srepchains.lst -d /cluster/project0/new_tdb/cath_dssp/ -s /cluster/project0/new_tdb/bin/dssp/dsspcmbi -t /cluster/project0/new_tdb/cath_domain_tdb/ -u /cluster/project0/new_tdb/blast_db/uniref90.fasta -b /cluster/project0/new_tdb/bin/blast/blastpgp -c /cluster/project0/new_tdb/bin/T-COFFEE_distribution_Version_8.91/bin/binaries/linux/t_coffee -p /cluster/project0/new_tdb/dompdb/ -q /cluster/project0/new_tdb/cath_data/CathDomainSeqs.S100.ATOM.annotated -r /cluster/project0/new_tdb/cath_domain_tmp/ -f /cluster/project0/new_tdb/cath_domain_tmp/ -a /cluster/project0/new_tdb/cath_data/v3_3_0-structural_alignments/ -y D -e /cluster/project0/new_tdb/bin/parse_source -l /cluster/project0/new_tdb/cath_data/CathDomainSeqs.S100.ATOM.annotated -m /cluster/project0/new_tdb/bin/blast/makemat
