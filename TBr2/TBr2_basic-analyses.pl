#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: basic-analyses
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -i input -o output

Input files can be in FASTA or FASTQ format. Avoid linebreaks within
sequences! Default output is stdout (usually console).

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

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

# read sequences
print"\nRead sequence file...";
open(IN,$input_file)||die print"\nCould not open input file $input_file.\n$!\n\n";
%seqs=();
if($format eq'FASTA')
	{
	while(<IN>)
		{
		$_=~s/\s*$//;
		if($_!~/^>/)
			{
			$seqs{$_}++;
			}
		}
	}
elsif($format eq'FASTQ')
	{
	$i=0;
	while(<IN>)
		{
		$i++;
		$_=~s/\s*$//;
		if($i==2)
			{
			$seqs{$_}++;
			}
		elsif($i==4)
			{
			$i=0;
			}
		}
	}
close IN;
print" done.";

# analyze sequences
%length_reads=();
%length_seqs=();
%nucl_reads=();
%nucl_seqs=();
%nucl_total=();

$min_length=0;
$max_length=0;

$reads=0;
$sequences=0;

print"\nAnalyze sequences...";
foreach$seq(keys%seqs)
	{
	$reads+=$seqs{$seq};
	$sequences++;
	
	$l=length$seq;
	if($l<$min_length||$min_length==0)
		{
		$min_length=$l;
		}
	if($l>$max_length)
		{
		$max_length=$l;
		}
	$length_reads{$l}+=$seqs{$seq};
	$length_seqs{$l}++;
	
	foreach$pos(0..$l-1)
		{
		$nucl_reads{$pos}{substr($seq,$pos,1)}+=$seqs{$seq};
		$nucl_seqs{$pos}{substr($seq,$pos,1)}++;
		$nucl_total{substr($seq,$pos,1)}++;
		}
	}
@letters=keys%nucl_total;
@letters=sort@letters;
print" done.\n";

if($output_file!~/^\s*$/)
	{
	open(OUT,">$output_file")||die print"\nCould not create output file $output_file.\n$!\n\n";
	
	print OUT"Input file: $input_file (format=$format)\nNumber of sequence reads: $reads\nNumber of non-identical sequences: $sequences\n\nLength distribution\nlength\treads\tnon-identical sequences\n";
	foreach$l($min_length..$max_length)
		{
		print OUT"$l\t$length_reads{$l}\t$length_seqs{$l}\n";
		}
	
	print OUT"\nTotal nucleotide composition\nA\t$nucl_total{A}\nT\t$nucl_total{T}\nG\t$nucl_total{G}\nC\t$nucl_total{C}\n";
	$total_residues=0;
	foreach$res(@letters)
		{
		$total_residues+=$nucl_total{$res};
		if($res!~/[ATGC]/)
			{
			print OUT"$res\t$nucl_total{$res}\n";
			}
		}
	$perc_GC=(($nucl_total{'G'}+$nucl_total{'C'})/($nucl_total{'G'}+$nucl_total{'C'}+$nucl_total{'A'}+$nucl_total{'T'}))*100;
	$perc_AT=100-$perc_GC;
	print OUT"TOTAL\t$total_residues\nGC\t$perc_GC %\nAT\t$perc_AT %\n\nPositional nucleotide composition (reads)\npos.\tA\tT\tG\tC";
	foreach$res(@letters)
		{
		if($res!~/[ATGC]/)
			{
			print OUT"\t$res";
			}
		}
	print OUT"\n";
	foreach$pos(0..$max_length-1)
		{
		$fpos=$pos+1;
		print OUT"$fpos\t$nucl_reads{$pos}{A}\t$nucl_reads{$pos}{T}\t$nucl_reads{$pos}{G}\t$nucl_reads{$pos}{C}";
		foreach$res(@letters)
			{
			if($res!~/[ATGC]/)
				{
				print OUT"\t$nucl_reads{$pos}{$res}";
				}
			}
		print OUT"\n";
		}
	print OUT"\nPositional nucleotide composition (non-identical sequences)\npos.\tA\tT\tG\tC";
	foreach$res(@letters)
		{
		if($res!~/[ATGC]/)
			{
			print OUT"\t$res";
			}
		}
	print OUT"\n";
	foreach$pos(0..$max_length-1)
		{
		$fpos=$pos+1;
		print OUT"$fpos\t$nucl_seqs{$pos}{A}\t$nucl_seqs{$pos}{T}\t$nucl_seqs{$pos}{G}\t$nucl_seqs{$pos}{C}";
		foreach$res(@letters)
			{
			if($res!~/[ATGC]/)
				{
				print OUT"\t$nucl_seqs{$pos}{$res}";
				}
			}
		print OUT"\n";
		}
	close OUT;
	}
else
	{
	print"
============================== NGS TOOLBOX ==============================
Program: basic-analyses
Version: 2.1
last modified: 11. March 2015
=========================================================================

Input file: $input_file (format=$format)
Number of sequence reads: $reads
Number of non-identical sequences: $sequences

Length distribution\nlength\treads\tnon-identical sequences\n";

	foreach$l($min_length..$max_length)
		{
		print"$l\t$length_reads{$l}\t$length_seqs{$l}\n";
		}
	
	print"\nTotal nucleotide composition\nA\t$nucl_total{A}\nT\t$nucl_total{T}\nG\t$nucl_total{G}\nC\t$nucl_total{C}\n";
	$total_residues=0;
	foreach$res(@letters)
		{
		$total_residues+=$nucl_total{$res};
		if($res!~/[ATGC]/)
			{
			print"$res\t$nucl_total{$res}\n";
			}
		}
	$perc_GC=(($nucl_total{'G'}+$nucl_total{'C'})/($nucl_total{'G'}+$nucl_total{'C'}+$nucl_total{'A'}+$nucl_total{'T'}))*100;
	$perc_AT=100-$perc_GC;
	print"TOTAL\t$total_residues\nGC\t$perc_GC %\nAT\t$perc_AT %\n\nPositional nucleotide composition (reads)\npos.\tA\tT\tG\tC";
	foreach$res(@letters)
		{
		if($res!~/[ATGC]/)
			{
			print"\t$res";
			}
		}
	print"\n";
	foreach$pos(0..$max_length-1)
		{
		$fpos=$pos+1;
		print"$fpos\t$nucl_reads{$pos}{A}\t$nucl_reads{$pos}{T}\t$nucl_reads{$pos}{G}\t$nucl_reads{$pos}{C}";
		foreach$res(@letters)
			{
			if($res!~/[ATGC]/)
				{
				print"\t$nucl_reads{$pos}{$res}";
				}
			}
		print"\n";
		}
	print"\nPositional nucleotide composition (non-identical sequences)\npos.\tA\tT\tG\tC";
	foreach$res(@letters)
		{
		if($res!~/[ATGC]/)
			{
			print"\t$res";
			}
		}
	print"\n";
	foreach$pos(0..$max_length-1)
		{
		$fpos=$pos+1;
		print"$fpos\t$nucl_seqs{$pos}{A}\t$nucl_seqs{$pos}{T}\t$nucl_seqs{$pos}{G}\t$nucl_seqs{$pos}{C}";
		foreach$res(@letters)
			{
			if($res!~/[ATGC]/)
				{
				print"\t$nucl_seqs{$pos}{$res}";
				}
			}
		print"\n";
		}
	}
exit;