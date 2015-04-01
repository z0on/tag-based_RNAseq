#!/usr/bin/perl

my $usage = "

isogroup_namer.pl:

assigns sequences to \"isogroups\" based on cd-hit-est results, 
outputs:
- a transcriptome with gene=isogroupNNNN identifiers added to headers
- a tab-delimited table of sequences - cluster designations

usage: 
isogroup_namer.pl [fasta file] [cd-hit-est result, .clstr file]

example:
isogroup_namer.pl transcritptome.fasta transcriptome.fasta.clstr 

NOTE: 
run cd-hit-est before this; for example, to look for 99% or better 
matches between contigs taking 30% of their lengths 
cd-hit-est -i transcriptome.fasta -o transcriptome.fasta -c 0.99 -G 0 -aL 0.3 -aS 0.3


";

if ($#ARGV<1) { die $usage;}
open fas, $ARGV[0] or die "cannot open fasta file $ARGV[0]\n\n$usage";
open clus, $ARGV[1] or die "cannot open cd-hit result $ARGV[1]\n\n$usage";

my %iso={};
my $seq;
my $cl;
my @seqs=();

while (<clus>) {
	if ($_=~/^>Cluster (\S+)/) {
		foreach $seq (@seqs) {
			$iso{$seq}=$cl;
		}
#print "isogroup $cl : @seqs\m";
		$cl=$1; 
		@seqs=();
	}
	elsif ($_=~/>(\S+)\.\.\./) {
		push @seqs, $1;
	}
}
foreach $seq (@seqs) {
	$iso{$seq}=$cl;
}

my $isotran=$ARGV[0];
$isotran=~s/\./_iso\./;
open TI, ">$isotran" or die "cannot create output transcriptome $isotran\n";
my $isotab=$isotran;
$isotab=~s/\..+/_seq2iso\.tab/;
open TB, ">$isotab" or die "cannot create seq2iso table $isotab\n";
		
while (<fas>){
	chomp;
	if ($_=~/^>(\S+)/ ) {
		print {TB} "$1\tisogroup$iso{$1}\n";
		print {TI} ">$1 gene=isogroup$iso{$1}\n";
	}
	else { print {TI} "$_\n"; }
}

