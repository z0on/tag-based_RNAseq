#!/usr/bin/perl

$usage= "

splits multi-fasta file into several based on the pattern in the header line

arguments:
1 : fasta file name
2 : string to look for in the header with target sample name in parentheses, such as \"(S\d+)-\"
		 
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
			$fname=$1.".fasta";
			push @fnames,$fname unless ("@fnames"=~/$fname/);
			$seqs{$fname}.=">$name\n$seq\n";
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
	$fname=$1.".fasta";
	push @fnames,$fname unless ("@fnames"=~/$fname/);
	$seqs{$fname}.=">$name\n$seq\n";
}

foreach my $fname(@fnames) {
	open FA, ">$fname" or die "cannot create file $fname\n";
	print {FA} $seqs{$fname};
	close FA;
}
