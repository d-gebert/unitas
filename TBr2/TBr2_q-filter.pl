#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: q-filter
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -f ['Sanger','Illumina']

Input files must be in FASTQ format. Avoid linebreaks within sequences!
This script will produce two self-explanatory output files (input file
= input.fastq):
input.fastq.passed
input.fastq.failed

You can use three different methods to define a quality cutoff:
1. average Phred score: -average_cutoff [value]
   Removes reads with an average Phred score below <value>. 
2. lowest Phred score: -lower_cutoff [value]
   Removes reads that contain one or more bases called with a Phred score
   below <value>.
3. overall accuracy: -accuracy_cutoff [value 0..1]
   Removes reads with an overall accuracy (probability for a read to
   contain 0 miscalled bases) below <value> (e.g. 0.95).

The three arguments can be combined as desired.

Default format is 'Sanger' (scores from 0-93 using ASCII 33-126). FASTQ
files in Sanger format are produced by Illumina's CASAVA pipeline 1.8 and
later. Alternatively you can use 'Illumina' (scores from 0-62 using ASCII
64-126) that is produced by Illumina 1.3 to 1.7. Selecting the correct
format is crucial for correct computation. Older versions with scores
from -5 to 62 using ASCII 59 to 126 are not supported.

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$format="Sanger";
$average_cutoff=0;
$lower_cutoff=0;
$accuracy_cutoff=0;
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"f=s"=>\$format,
	"average_cutoff=f"=>\$average_cutoff,
	"lower_cutoff=f"=>\$lower_cutoff,
	"accuracy_cutoff=f"=>\$accuracy_cutoff,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

if($format ne'Illumina'&&$format ne'Sanger')
	{
	print"\nInput format has to be 'Sanger' or 'Illumina'\n";
	exit;
	}

if($average_cutoff+$lower_cutoff+$accuracy_cutoff==0)
	{
	print"\nDefine a quality cutoff!\n";
	exit;
	}

print"
============================== NGS TOOLBOX ==============================
Program: q-filter
Version: 2.1
last modified: 11. March 2015
=========================================================================
";

# process input file
print"\nProcess sequences in $input_file...";

if($format eq'Illumina')
	{
	foreach(0..62)
		{
		$Phreds[$_]=0;
		$diff=64;
		}
	}
elsif($format eq'Sanger')
	{
	foreach(0..93)
		{
		$Phreds[$_]=0;
		$diff=33;
		}
	}

open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
open(PASSED,">$input_file.passed")||die print"\nCould not create output file $input_file.passed.\n$!\n\n";
open(FAILED,">$input_file.failed")||die print"\nCould not create output file $input_file.failed.\n$!\n\n";
$i=0;
@seq_data=();
while(<IN>)
	{
	$_=~s/\s*$//;
	push(@seq_data,$_);
	$i++;
	if($i==4)
		{
		$i=0;
		$pos=0;
		$READ_accuracy=1;
		$READ_lowest_score=128;
		$READ_average_score=0;
		@quality=split('',$seq_data[3]);
		foreach(@quality)
			{
			$pos++;
			$Phred=ord($_)-$diff;
			if($Phred<$READ_lowest_score)
				{
				$READ_lowest_score=$Phred;
				}
			$READ_average_score+=$Phred;
			$READ_accuracy=$READ_accuracy*(1-(10**(($Phred*-1)/10)));
			}
		$READ_average_score=$READ_average_score/(length$seq_data[3]);
		if($READ_lowest_score>=$lower_cutoff&&$READ_average_score>=$average_cutoff&&$READ_accuracy>=$accuracy_cutoff)
			{
			foreach(@seq_data)
				{
				print PASSED"$_\n";
				}
			}
		else
			{
			foreach(@seq_data)
				{
				print FAILED"$_\n";
				}
			}
		@seq_data=();
		}
	}
close IN;
close PASSED;
close FAILED;
exit;