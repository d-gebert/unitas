#!/usr/bin/perl
use Getopt::Long;
$|=1;

$script=$0;
$script=~s/^.+[\\\/]//;
$info_text=
"
============================== NGS TOOLBOX ==============================
Program: concatenate
Version: 2.1
LAST MODIFIED: 11. March 2015

Usage: perl $script -d directory -e extension -o output

Default directory is the current working directory. Default output file
is 'concatenate.out'. Without -e all files whithin the current directory
will be concatenated. State multiple extensions like this:
-e .fas -e .fasta -e .txt

-h or -help will print this information.

Contact:
David Rosenkranz
Institute of Anthropology
Johannes Gutenberg University Mainz, Germany
email: rosenkranz\@uni-mainz.de

";

$output_file="concatenate.out";
GetOptions
	(
	"help"=>\$print_info,
	"h"=>\$print_info,
	"d=s"=>\$directory,
	"e=s"=>\@extensions,
	"o=s"=>\$output_file,
	);

# print info
if($print_info)
	{
	print$info_text;
	exit;
	}

# grep files
@files=();
unless(@extensions)
	{
	$extensions[0]="";
	}

foreach$e(@extensions)
	{
	if($directory)
		{
		opendir(DIR,$directory)||die print"\nCould not open directory $directory.\n$!\n\n";
		if($directory!~/\/$/)
			{
			$directory.='/';
			}
		}
	else
		{
		opendir(DIR,".")||die print"\nCould not open current directory.\n$!\n\n";
		}
	@f=grep(/$e$/,readdir(DIR));
	@files=(@files,@f);
	closedir(DIR);
	}

open(OUT,">$output_file")||die print"\nCould not create output file $output_file.\n$!\n\n";

print"
============================== NGS TOOLBOX ==============================
Program: concatenate
Version: 2.1
last modified: 11. March 2015
=========================================================================
";
foreach$file(@files)
	{
	if($file ne$script&&$file ne'.'&&$file ne'..')
		{
		print"\nConcatenate $file";
		open(IN,"$directory$file")||print" -> Could not open $directory$file. $!. Skip $file.";
		while(<IN>)
			{
			print OUT$_;
			}
		close IN;
		}
	}
close OUT;
print"\nFinished.\n";
exit;