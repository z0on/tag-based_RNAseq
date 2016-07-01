#!/usr/bin/perl

$usage= "

rnaseq_clipper.pl  : 

Clips 5'-leader off Illumina fastq reads in RNA-seq

Removes duplicated reads sharing the same degenerate header and 
the first 20 bases of the sequence (reads containing N bases in this
region are discarded, too)

prints to STDOUT

arguments:
1 : fastq file name
2 : string to define the leading sequence, default '[ATGC]?[ATGC][AC][AT]GGG+'
'keep' : optional flag to say whether the sequences without leader should be kept. 
		 By default, they are discarded.

Example:
rnaseq_clipper.pl D6.fq

					 
";

my $fq=shift or die $usage;
my $lead="";
my $keep=0;
if ($ARGV[0]) { $lead=$ARGV[0];}
else { $lead="[ATGC][ATGC][AC][AT]GGG+";}
if ($ARGV[1]) {$keep=1;}
my $trim=0;
my $name="";
my $name2="";
my $seq="";
my $qua="";
my %seen={};
my $dups=0;
my $tot=0;
my $nohead=0;
my $kept=0;
open INP, $fq or die "cannot open file $fq\n";
my $ll=3;
while (<INP>) {
	if ($ll==3 && $_=~/^(\@.+)$/ ) {
		$name2=$1; 
		$tot++;
		if ($seq=~/^($lead)(.+)/) {	
			my $start=substr($2,0,20);
			my $idtag=$1.$start;
			if (!$seen{$idtag} and $idtag!~/N/) {
				$seen{$idtag}=1;
				$trim=length($1);
				$kept++;
				print "$name\n$2\n+\n",substr($qua,$trim),"\n";
			} else { $dups++; }
		} 
		else { 
			$nohead++; 
			if ($keep and $name) { print "$name\n$seq\n+\n",$qua,"\n";}
		}
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
	my $start=substr($2,0,20);
	my $idtag=$1.$start;
	if (!$seen{$idtag} and $idtag!~/N/) {
		$seen{$idtag}=1;
		$trim=length($1);
		print "$name\n$2\n+\n",substr($qua,$trim),"\n";
		$kept++;
	} else { $dups++; }
} 
else { 
	$nohead++; 
	if ($keep and $name) { print "$name\n$seq\n+\n",$qua,"\n";}
}
warn "
file\ttotal\tnoheader\tduplicates\tkept
$fq\t$tot\t$nohead\t$dups\t$kept

";
