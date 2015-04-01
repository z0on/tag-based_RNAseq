#!/usr/bin/perl

$usage= "

rnaseq_clipper: clips 5'-leader off Illumina fastq reads in RNA-seq
arguments:
1 : fastq file name
2 : string to define the leading sequence, default \'[NATGC]?[ATGC][AC][AT]GGG+\'
'keep' : optional flag to say whether the sequences without leader should be kept. 
		 By default, they are discarded.
		 
";

my $fq=shift or die $usage;
my $lead="";
my $keep=0;
if ($ARGV[0]) { $lead=$ARGV[0];}
else { $lead="[NATGC][ATGC][AC][AT]GGG+";}
if ($ARGV[1]) {$keep=1;}
my $trim=0;
my $name="";
my $name2="";
my $seq="";
my $qua="";
open INP, $fq or die "cannot open file $fq\n";
my $ll=3;
while (<INP>) {
	if ($ll==3 && $_=~/^(\@.+)$/ ) {
		$name2=$1; 
		if ($seq=~/^($lead)(.+)/) {
			$trim=length($1);
			print "$name\n$2\n+\n",substr($qua,$trim),"\n";
		}
		elsif ($keep && $name) { print "$name\n$seq\n+\n",$qua,"\n";}
		$seq="";
		$ll=0;
		$qua="";
		@sites=();
		$name=$name2;
	}
	elsif ($ll==0){
		chomp;
		$seq=$_;
		$ll=1;
	}
	elsif ($ll==2) { 
		chomp;
		$qua=$_; 
		$ll=3; 
	}
	else { $ll=2;}
}
$name2=$1; 
if ($seq=~/^($lead)(.+)/) {
	$trim=length($1);
        print "$name\n$2\n+\n",substr($qua,$trim),"\n";
}
elsif ($keep) { print "$name\n$seq\n+\n",$qua,"\n";}

