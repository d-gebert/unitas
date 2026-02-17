#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: split
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -s ['size','seq','parts'] -n [integer]

Input files should be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Other formats will we processed nevertheless. Default split
modus is 'parts'. -n defines the number of parts, filesize in Kbytes or
number of sequences per output file, respectively. Output files will be
numbered consecutively.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$split_modus='parts';
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"s=s"=>\$split_modus,
	"n=i"=>\$n,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

# check arguments
if($n!~/^\d+$/)
	{
	exit;
	}
if($split_modus ne'size'&&$split_modus ne'seq'&&$split_modus ne'parts')
	{
	print"\nUnknown split modus: $split_modus. Will use default:'parts'.\n";
	$split_modus='parts';
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
	$format='unknown';
	}
print" done. -> $format";



print"
============================== NGS TOOLBOX ==============================
Program: split
Version: 2.1
last modified: 11. March 2015
=========================================================================
";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";

$i=0;
$c=1;
$sequences=0;
$input_size=-s"$input_file";

open(OUT,">$input_file.$c.split")||die print"\nCould not create output file $input_file.$c.split.\n$!\n\n";
print"\nCreate $input_file.$c.split";
while(<IN>)
	{
	if($format eq'FASTQ')
		{
		$i+=0.25;
		}
	elsif($format eq'FASTA')
		{
		$i+=0.5;
		}
	else
		{
		$i+=0.1;
		}
	print OUT$_;
	if($i==1)
		{
		$i=0;
		if($split_modus eq'size')
			{
			$size=-s"$input_file.$c.split";
			if($size>=($n*1000))
				{
				new_splitfile();
				}
			}
		elsif($split_modus eq'parts')
			{
			$size=-s"$input_file.$c.split";
			if($size>=($input_size/$n))
				{
				new_splitfile();
				}
			}
		else
			{
			$sequences++;
			if($sequences==$n)
				{
				$sequences=0;
				new_splitfile();
				}
			}
		sub new_splitfile
			{
			close OUT;
			$c++;
			open(OUT,">$input_file.$c.split")||die print"\nCould not create output file $input_file.$c..split\n$!\n\n";
			print"\nCreate $input_file.$c.split";
			}
		}
	}
close IN;
close OUT;
exit;