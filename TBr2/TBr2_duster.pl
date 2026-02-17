#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: duster
Version: 2.1
LAST MODIFIED: 13. March 2015

Usage: perl $script -i input -t [value 0..1] -min [value] -max [value]

Input files can be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Set the minimum and maximum length [nt] for simple repeat
motifs with the options -min (default=1) and -max (default=4),
respectively. Set the threshold for the fraction of the read occupied by
a simple repeat motif with the option -t (default=0.75).

This script will produce two self-explanatory output files (input file
= input.fastq):
input.fastq.dust
input.fastq.no-dust

Here are some example reads that will be removed when using the default
settings:
AAGAAAAAAAAATAAAAAAAAAATTA
GTCAGTGTGTGTGTGTGTGTGTGTGTGAA
CTTTAGATAGATAGATAGATAGATAGAC
GACTGACTGACTTGACTGACTGACT

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$min_period_size=1;	# min size of repeat motif
$max_period_size=4;	# max size of repeat motif
$threshold=0.75;	# amount of read occupied by motif
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"t=f"=>\$threshold,
	"min=i"=>\$min_period_size,
	"max=i"=>\$max_period_size,
	);

# print info
if($print_info)
	{
	print$info_text;
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

print"
============================== NGS TOOLBOX ==============================
Program: duster
Version: 2.1
last modified: 13. March 2015
=========================================================================
";

# process input file
print"\nProcess sequences in $input_file...";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
open(OK,">$input_file.no-dust")||die print"\nCould not create output file $input_file.no-dust.\n$!\n\n";
open(DUST,">$input_file.dust")||die print"\nCould not create output file $input_file.dust.\n$!\n\n";

$i=0;
$simple=0;
$complex=0;
@seq_data=();
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
		$read_length=length$seq_data[1];
		%fragments=();
		foreach$frag_size($min_period_size..$max_period_size)
			{
			$gnaw=$seq_data[1];
			while(length$gnaw>=$frag_size)
				{
				$gnaw=~s/^.{$frag_size}//;
				$fragments{$&}=1;
				}
			}
		foreach$fragment(keys%fragments)
			{
			$check=$seq_data[1];
			$check=~s/$fragment//g;
			if(length$check<=$read_length*(1-$threshold))
				{
				$ok=0;
				last;
				}
			}
		undef%fragments;
		
		if($format eq'FASTQ')
			{
			$output="$seq_data[0]\n$seq_data[1]\n$seq_data[2]\n$seq_data[3]\n";
			}
		else
			{
			$output="$seq_data[0]\n$seq_data[1]\n";
			}
		if($ok==1)
			{
			$complex++;
			print OK$output;
			}
		else
			{
			$simple++;
			#print"\n$seq_data[0]\t$seq_data[1]";
			print DUST$output;
			}
		@seq_data=();
		}
	}
print"\nFound $simple dusty (low-complexity) reads.\n$complex reads are ok.\n\n";
exit;