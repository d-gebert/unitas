#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: clip
Version: 2.1
LAST MODIFIED: 13. March 2015

Usage: perl $script -i input -o output -m motif

Input files can be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Default output is 'clip.out'. A motif can be a plain sequence.
The full IUPAC code [ATGCYRWSKMDVHBNX] is supported. You can use '5' or
'3' to define the left/right end of the sequence, respectively.

EXAMPLE 1:
-m 5TTAGCA
TTAGCATTAGCACCGTACTATGACTGCATGACCC  INPUT SEQUENCE
XXXXXX----------------------------  X = clipped positions

EXAMPLE 2:
-m 5N
TTAGCATGCATCCTTAGCAATGACTGCATGACCC  INPUT SEQUENCE
X---------------------------------  X = clipped positions

You may also use '.' as a wildcard for an arbitrary (0-n) number of Ns.

EXAMPLE 3:
-m GATTCCATG.3
GCATGCATCCTTATGCACGGATTCCATGACTC  INPUT SEQUENCE
-------------------XXXXXXXXXXXXX  X = clipped positions

Use multiple motifs like this:
-m 5TTAGCANNNN -m GATTCCATG.3

Motifs will be clipped in order of user input. In case of multiple
occurences of a motif within one sequence only the first match will
be removed.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

@motifs=();
$output_file="clip.out";
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"o=s"=>\$output_file,
	"m=s"=>\@motifs,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

if(@motifs==0)
	{
	print"\nNo motif(s) defined.\n\n";
	exit;
	}

# check input format (FASTA/FASTQ)
print"\nChecking input file format...";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
$i=0;
$fasta_heads=0;
$fastq_heads=0;
while(<IN>)
	{
	$i++;
	last if($i==1000);
	if($_=~/^>/)
		{
		$fasta_heads++;
		}
	elsif($_=~/^@/||$_=~/^\+/)
		{
		$fastq_heads++;
		}
	}
close IN;
if($fasta_heads>$fastq_heads)
	{
	$format='FASTA';
	}
elsif($fastq_heads>$fasta_heads)
	{
	$format='FASTQ';
	}
else
	{
	die print"\nUnknown file format of input file $input_file.\n\n";
	}
print" done. -> $format";

# IUPAC nucleotide code
%IUPAC=
	(
	'Y'=>'[CT]',
	'R'=>'[AG]',
	'W'=>'[AT]',
	'S'=>'[GC]',
	'K'=>'[TG]',
	'M'=>'[CA]',
	'D'=>'[AGT]',
	'V'=>'[ACG]',
	'H'=>'[ACT]',
	'B'=>'[CGT]',
	'N'=>'.',
	'X'=>'.',
	'5'=>'^',
	'3'=>'$',
	'.'=>'.*',
	);

print"
============================== NGS TOOLBOX ==============================
Program: clip
Version: 2.1
last modified: 13. March 2015
=========================================================================
";

# transform motifs to Perl regex
@regex=();
foreach$motif(@motifs)
	{
	$regex="";
	@motif=split('',$motif);
	foreach(@motif)
		{
		if($IUPAC{$_})
			{
			$regex.=$IUPAC{$_};
			}
		else
			{
			$regex.=$_;
			}
		}
	push(@regex,$regex);
	}

# motif search
print"\nClip sequences in $input_file...";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
open(OUT,">$output_file")||die print"\nCould not create output file $output_file.\n$!\n\n";

$i=0;
@seq_data=();
$found=0;
$missed=0;
while(<IN>)
	{
	$_=~s/\s*$//;
	push(@seq_data,$_);
	if($format eq'FASTQ')
		{
		$i+=0.25;
		}
	elsif($format eq'FASTA')
		{
		$i+=0.5;
		}
	if($i==1)
		{
		$i=0;
		$ok=1;
		foreach$regex(@regex)
			{
			if($seq_data[1]=~/$regex/)
				{
				if($format eq'FASTQ')
					{
					$replace=$&;
					$replace=~s/./-/g;
					$seq_data[1]=~s/$regex/$replace/;
					@s=split('',$seq_data[1]);
					@q=split('',$seq_data[3]);
					$seq_data[1]="";
					$seq_data[3]="";
					foreach(1..@s)
						{
						if($s[$_-1]ne'-')
							{
							$seq_data[1].=$s[$_-1];
							$seq_data[3].=$q[$_-1];
							}
						}
					}
				else
					{
					$seq_data[1]=~s/$regex//;
					}
				}
			else
				{
				$ok=0;
				last;
				}
			}
		if($ok==1)
			{
			$found++;
			if($format eq'FASTQ')
				{
				print OUT"$seq_data[0]\n$seq_data[1]\n$seq_data[2]\n$seq_data[3]\n";
				}
			else
				{
				print OUT"$seq_data[0]\n$seq_data[1]\n";
				}
			}
		else
			{
			$missed++;
			}
		@seq_data=();
		}
	}

close IN;
close OUT;
$total_seqs=$found+$missed;
print" done.\nFound (all) motifs in $found out of $total_seqs sequences.\n\n";
exit;