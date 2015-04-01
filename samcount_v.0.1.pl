#!/usr/bin/perl

$usage="

samcount v.0.1 (October 2014):

counts reads mapping to isogrops in SAM files

Arguments:

arg1: SAM file (by cluster, contig, or isotig)
arg2: a table in the form 'reference_seq<tab>gene_ID', giving the correspondence of 
reference sequences to genes. With 454-deived transcriptome, the gene_ID would be isogroup; 
with Trinity-derived transcriptiome,it would be component.

dup.reads=keep|toss : whether to remove exact sequence-duplicate reads mapping to the 
same position in the reference. Default keep (duplicates are supposed to be tossed at the 
trimming stage).

aligner=gmapper|bowtie2 : aligner that made the SAM file. Default gmapper (SHRiMP package).
                          bowtie2 is assumed to be used in -k mode.

mult.iso=random|toss : (for aligner=gmapper) if a read maps to multiple isogroups, it is 
disregarded by default. Set this option to 'random' if you want to randomly pick an 
isogroup to assign a count to.

";

my $t1=shift @ARGV or die $usage;
my $t2=shift @ARGV or die $usage;
my $rmdup="keep";
if ("@ARGV"=~/dup.reads=toss/) { 
	$rmdup="toss";
}
my $miso="toss";
my $aligner="gmapper";
if ("@ARGV"=~/aligner=bowtie2/) {  
	$aligner="bowtie2";
	if ("@ARGV"=~/min.mapq=(\d+)/) {  $minmapq=$1; }
}
else {
	if ("@ARGV"=~/mult.iso=random/) { 
		$miso="random";
		warn "adding a count to a randomly picked isogroup when a read maps to multiple isogroups\n";
	}
	else { warn "disregarding reads mapping to multiple isogroups\n"; }	
}

open SAM, $t1 or die "cannot open $t1\n";
open C2I, $t2 or die "cannot open $t2\n";

my %c2i={};
my %count={};
my %hit={};
my %refhit={};
my $c="";
my $i="";
my $f="";
my $r="";
my $pos="";
my $seq="";

while (<C2I>) {
	chop;
	($c,$i)=split(/\s+/,$_);
	$c2i{$c}=$i;
}

my $mapq;
my $cigar;
my $flag;
my @rest;
my %bestmatch={};
my %trust={};
my %ciglen;

while (<SAM>) {
	if ($_=~/^@/) { next;}
	chop;
	($r,$flag,$c,$pos,$mapq,$cigar,@rest)=split(/\s/,$_);
	my $matchlen;
	if (@ms = $cigar=~m/(\d+)M/g) { 
		for (@ms) {	
			$matchlen+=$_; 
		}	
	} 
	else { next; }
	if ($r=~/@/) {next;}
	$i=$c2i{$c};
	if ($i!~/\d+/) { warn "$c has no isogroup designation\n" and next;} 
	my @sseq=grep(/[ATGCatgc-]{30,}/,@rest);
	next if (!$sseq[0]);
	if ($aligner eq "bowtie2") {
		if ($matchlen<$bestmatch{$r}) { 
#warn "$r:mapq=$mapq:cig=$cigar:ml=$matchlen:best=$bestmatch{$r}: 	SKIP\n";
			next;
		}
		elsif ($ciglen{$r} and $ciglen{$r}<length($cigar)){
			next; 
#warn "$r:mapq=$mapq:cig=$cigar:ml=$matchlen:best=$bestmatch{$r}: 	SKIP		(ciglen)\n";
		}
		else { 
#warn "$r:mapq=$mapq:cig=$cigar:ml=$matchlen:best=$bestmatch{$r}:ciglen=",length($cigar)," RETAIN\n";
			$bestmatch{$r}=$matchlen;
			$ciglen{$r}=length($cigar);
		}
	}
	$seq=$sseq[0];
	my $toss=0;
	if ($rmdup eq "toss") {
		foreach $sr (@{$refhit{$c}{$pos}}) {
			if ($sr=~/^$seq/ | $seq=~/^$sr/) {
				$toss=1;
				last;
			}
		}
	}
	if ($toss==0) {
#warn "$r:mapq=$mapq:cig=$cigar:ml=$matchlen:best=$bestmatch{$r}:ciglen=",length($cigar)," RETAIN\n";
		push @{$refhit{$c}{$pos}},$seq;
		push @{$hit{$r}},$i unless (" @{$hit{$r}} "=~/ $i /); 
	}
}

foreach $r (keys %hit){
	next if ($r=~/HASH/);
	if($#{$hit{$r}}>0) {
#warn "$r:isogroups: @{$hit{$r}}\n";
		if($miso eq "random") {
			my $pick=${$hit{$r}}[rand @{$hit{$r}}];
			$count{$pick}++;
		}
	}
	else { 
		$count{${$hit{$r}}[0]}++;
	}
}

foreach $i (sort keys %count) {
	next if ($i=~/HASH/);
	print "$i\t$count{$i}\n";
}

