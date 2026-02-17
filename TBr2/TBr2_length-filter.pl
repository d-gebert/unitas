#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: length-filter
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -o output -min [value] -max [value]

Input files can be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Default output is 'length-filter.out'. Set the minimum and
maximum sequence length [nt] with the options -min and -max,
respectively.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$min=0;
$max="inf.";
$output_file="length-filter.out";
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"o=s"=>\$output_file,
	"min=i"=>\$min,
	"max=i"=>\$max,
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
Program: length-filter
Version: 2.1
last modified: 11. March 2015
=========================================================================
";

# process input file
print"\nProcess sequences in $input_file...";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
open(OUT,">$output_file")||die print"\nCould not create output file $output_file.\n$!\n\n";

$i=0;
@seq_data=();
$cutoff_low=0;
$cutoff_high=0;
$cutoff_ok=0;
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
		
		if(length$seq_data[1]<$min)
			{
			$cutoff_low++;
			}
		elsif(length$seq_data[1]>$max)
			{
			$cutoff_high++;
			}
		else
			{
			$cutoff_ok++;
			if($format eq'FASTQ')
				{
				print OUT"$seq_data[0]\n$seq_data[1]\n$seq_data[2]\n$seq_data[3]\n";
				}
			else
				{
				print OUT"$seq_data[0]\n$seq_data[1]\n";
				}
			}
		@seq_data=();
		}
	}
print" done.\nFound $cutoff_low sequences < $min nt.\nFound $cutoff_high sequences > $max nt.\nFound $cutoff_ok sequences from $min-$max nt.\n\n";
exit;