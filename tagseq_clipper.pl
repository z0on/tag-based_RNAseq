#!/usr/bin/perl

$usage= "

tagseq_clipper.pl  : 

Clips 5'-leader off Illumina fastq reads in RNA-seq

Removes duplicated reads sharing the same degenerate header and 
the first 20 bases of the sequence (reads containing N bases in this
region are discarded, too)

prints to STDOUT

arguments:
1 : fastq file name
2 : string to define the leading sequence, default '[ATGC]?[ATGC][AC][AT]GGG+|[ATGC]?[ATGC]TGC[AC][AT]GGG+|[ATGC]?[ATGC]GC[AT]TC[ACT][AC][AT]GGG+'

Example:
tagseq_clipper.pl D6.fastq

					 
";

my $fq=shift or die $usage;
my $lead="";
if ($ARGV[0]) { $lead=$ARGV[0];}
else { $lead="[ATGC]?[ATGC][AC][AT][AT][AC][AT][ACT]GGG+|[ATGC]?[ATGC][AC][AT]GGG+|[ATGC]?[ATGC]TGC[AC][AT]GGG+|[ATGC]?[ATGC]GC[AT]TC[ACT][AC][AT]GGG+";}
my $trim=0;
my $name="";
my $name2="";
my $seq="";
my $qua="";
my %seen={};
open INP, $fq or die "cannot open file $fq\n";
my $ll=3;
my $nohead=0;
my $dups=0;
my $ntag=0;
my $tot=0;
my $goods=0;
while (<INP>) {
	if ($ll==3 && $_=~/^(\@.+)$/ ) {
		$tot++;
		$name2=$1; 
		if ($seq=~/^($lead)(.+)/) {	
			my $start=substr($2,0,20);
			my $idtag=$1.$start;
			if (!$seen{$idtag} and $idtag!~/N/) {
				$seen{$idtag}=1;
				$trim=length($1);
				print "$name\n$2\n+\n",substr($qua,$trim),"\n";
				$goods++;
			}
			elsif ($seen{$idtag}) { $dups++; }
			else { $ntag++; }
		} 
		elsif ($tot>1) {
			$nohead++;
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

if ($seq=~/^($lead)(.+)/) {
		my $start=substr($2,0,20);
		my $idtag=$1.$start;
		if (!$seen{$idtag} and $idtag!~/N/) {
				$seen{$idtag}=1;
				$trim=length($1);
				print "$name\n$2\n+\n",substr($qua,$trim),"\n";
				$goods++;
		}
		elsif ($seen{$idtag}) { $dups++; }
		else { $ntag++; }
}
elsif ($tot>1) {
	$nohead++;
}

warn "$fq\ttotal:$tot\tgoods:$goods\tdups:$dups\tnoheader:$nohead\tN.in.header:$ntag\n";
