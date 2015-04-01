#!/usr/bin/perl

$usage= "

outputs entries from a multi-fasta file that match a pattern in the header line

arguments:
1 : fasta file name
2 : string to look for in the header with target sample name in parentheses, such as \"(S\d\d+)-\"
		 
";

my $fq=shift or die $usage;
my $pattern=shift or die $usage;;
my $name="";
my $name2="";
my $seq="";
my %seqs={};
open INP, $fq or die "cannot open file $fq\n";
while (<INP>) {
	if ($_=~/^>(.+)$/) {
		$name2=$1; 
		if ($name=~/$pattern/) {
			print ">$name\n$seq\n";
		}
		$seq="";
		$ll=0;
		$name=$name2;
	}
	else{
		chomp;
		$seq.=$_;
	}
}
$name2=$1; 
if ($name=~/$pattern/) {
	print ">$name\n$seq\n";
}
