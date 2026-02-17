#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: rev-comp
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -o output

Input files can be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Default output is 'rev-comp.out'. The full IUPAC code [ATGCYRW
SKMDVHBNX.-] is supported. If you only want to reverse sequences use the
option -r. If you only want the complementary sequences use the option
-c. The default is making sequences reverse complemetary.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

@motifs=();
$output_file="rev-comp.out";
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"o=s"=>\$output_file,
	"r"=>\$reverse,
	"c"=>\$complementary,
	"m=s"=>\@motifs,
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
Program: rev-comp
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
		
		if($reverse)
			{
			$seq_data[1]=reverse$seq_data[1];
			$seq_data[3]=reverse$seq_data[3];
			}
		if($complementary)
			{
			$seq_data[1]=~tr/AGCTYRWSKMDVHBXN\-\./TCGARYWSMKHBDVXN\-\./;
			}
		if(!$reverse&&!$complementary)
			{
			$seq_data[1]=~tr/AGCTYRWSKMDVHBXN\-\./TCGARYWSMKHBDVXN\-\./;
			$seq_data[1]=reverse$seq_data[1];
			$seq_data[3]=reverse$seq_data[3];
			}
		if($format eq'FASTQ')
			{
			print OUT"$seq_data[0]\n$seq_data[1]\n$seq_data[2]\n$seq_data[3]\n";
			}
		else
			{
			print OUT"$seq_data[0]\n$seq_data[1]\n";
			}
		@seq_data=();
		}
	}
print" done.\n\n";
exit;