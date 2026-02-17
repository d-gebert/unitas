#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: fastq2fasta
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -o output

Input files must be in FASTQ format. Avoid linebreaks within sequences!
Default output is 'fastq2fasta.out'.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$output_file="fastq2fasta.out";
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"o=s"=>\$output_file,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

print"
============================== NGS TOOLBOX ==============================
Program: fastq2fasta
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
	$i+=0.25;
	if($i==1)
		{
		$i=0;
		$seq_data[0]=~s/^\@/>/;
		print OUT"$seq_data[0]\n$seq_data[1]\n";
		@seq_data=();
		}
	}
close IN;
close OUT;
print"\n done.\n\n";
exit;