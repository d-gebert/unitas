#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: q-check
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -o output -f ['Sanger','Illumina']

Input files must be in FASTQ format. Avoid linebreaks within sequences!
Default output is sdtout (console). Default format is <Sanger> (scores
from 0-93 using ASCII 33-126). FASTQ files in Sanger format are produced
by Illumina's CASAVA pipeline 1.8 and later.
Alternatively you can use <Illumina> (scores from 0-62 using ASCII 64-
126) that is produced by Illumina 1.3 to 1.7. Selecting the correct
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
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"i=s"=>\$input_file,
	"o=s"=>\$output_file,
	"f=s"=>\$format,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

if($format ne'Illumina'&&$format ne'Sanger')
	{
	print"\nInput format has to be <Sanger> or <Illumina>\n";
	exit;
	}

print"
============================== NGS TOOLBOX ==============================
Program: q-check
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
$i=0;
$bp_total=0;
$total_reads=0;
$terminal_Bs=0;
$seqs_with_terminal_Bs=0;
$terminal_rhombs=0;
$seqs_with_terminal_rhombs=0;
$average_P0errors=0;
@seq_data=();
@positional_Phred=();
@n_bases_at_position=();
while(<IN>)
	{
	$_=~s/\s*$//;
	push(@seq_data,$_);
	$i++;
	if($i==4)
		{
		$i=0;
		$total_reads++;
		
		if($seq_data[3]=~/B+$/)
			{
			$terminal_Bs+=length$&;
			$seqs_with_terminal_Bs++;
			}
		if($seq_data[3]=~/#+$/)
			{
			$terminal_rhombs+=length$&;
			$seqs_with_terminal_rhombs++;
			}
		
		$pos=0;
		$prob_0_errors=1;
		@quality=split('',$seq_data[3]);
		foreach(@quality)
			{
			$pos++;
			$Phred=ord($_)-$diff;
			$Phreds[$Phred]++;
			$prob_0_errors=$prob_0_errors*(1-(10**(($Phred*-1)/10)));
			$positional_Phred[$pos]+=$Phred;
			$n_bases_at_position[$pos]++;
			$average_score+=$Phred;
			$bp_total++;
			}
		$average_P0errors+=$prob_0_errors;
		@seq_data=();
		}
	}

$average_P0errors=$average_P0errors/$total_reads;
$average_score=$average_score/$bp_total;
$longest_read=@positional_Phred;
foreach(1..$longest_read)
	{
	if($n_bases_at_position[$_]>0)
		{
		$positional_Phred[$_]=$positional_Phred[$_]/$n_bases_at_position[$_];
		}
	}

while(1)
	{
	if($Phreds[-1]==0)
		{
		pop@Phreds;
		}
	else
		{
		last;
		}
	}

$results_text="\n\nRESULTS:\nAverage probability for overall accuracy of a read: $average_P0errors %\nAverage Phred score for base calling: $average_score\n\nPhred score\tNumber of base calls\n";
$i=-1;
foreach(@Phreds)
	{
	$i++;
	$results_text.="$i\t\t$_\n";
	}
$results_text.="\nSequences ending with 'B'-scored bases: $seqs_with_terminal_Bs\nSequences ending with '#'-scored bases: $seqs_with_terminal_rhombs\nTotal terminal 'B'-scored bases: $terminal_Bs\nTotal terminal '#'-scored bases: $terminal_rhombs\n\nInformation:\nIn Illumina 1.5+ stretches of B corresponding to a Phred score of 2\nare used to indicate that a specific final proportion of the read\nshould not be used in further analysis. In Illumina 1.8+ (Sanger\nformat) low quality ends are indicated by strectches of #.\n\nSeq. position\tAverage score for base calling:\n";
$i=0;
while(1)
	{
	$i++;
	last if(!$positional_Phred[$i]);
	$results_text.="$i\t\t$positional_Phred[$i]\n";
	}

if($output_file)
	{
	open(OUT,">$output_file")||die print"\nCould not create output file $output_file.\n$!\n\n";
	print OUT$results_text;
	close OUT;
	}
else
	{
	print"$results_text\n";
	}
exit;