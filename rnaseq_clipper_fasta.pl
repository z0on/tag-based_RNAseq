#!/usr/bin/perl

$usage= "

rnaseq_clipper: selects fasta records the the specific 5'-leading sequence, trims the 
leader off

arguments:
1 : fasta file name
2 : string to define the leading sequence, default \'[NATGC][ATGC][AC][AT]GGG+\'
	(Illumina RNA-seq leader)
3 : (optional) keep=1|0 whether to keep reads without the leader sequence (default 0)
		 
";

my $fq=shift or die $usage;
my $keep=0;
my $lead="[NATGC][ATGC][AC][AT]GGG+";
if ($ARGV[0]) { $lead=$ARGV[0];}
if ($ARGV[1] eq "keep=1") { $keep=1;}
my $trim=0;
my $name="";
my $name2="";
my $seq="";
my $qua="";
open INP, $fq or die "cannot open file $fq\n";
while (<INP>) {
	if ($_=~/^>(.+)$/) {
		$name2=$1; 
		if ($seq=~/^($lead)(.+)/) {
			$trim=length($1);
			print ">$name\n$2\n";
		}
		elsif ($keep) { print "$name\n$seq\n"; }
		$seq="";
		$ll=0;
		@sites=();
		$name=$name2;
	}
	else{
		chomp;
		$seq.=$_;
	}
}
$name2=$1; 
if ($seq=~/^($lead)(.+)/) {
	$trim=length($1);
	print ">$name\n$2\n";
}
elsif ($keep) { print "$name\n$seq\n"; }
