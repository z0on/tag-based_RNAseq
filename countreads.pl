#!/usr/bin/perl

print "

countreads.pl : counts the number of Illumina reads in a bunch of fastq files
argument - glob to fastq files, default \.fastq

";

my $glob="\.fastq";
if ($ARGV[0]) { $glob=$ARGV[0];}

opendir THIS, ".";
my @fqs=grep /$glob/,readdir THIS;
my $f;
my $nrd;
foreach $f(@fqs){
	$nrd=`cat $f | wc -l`;
	$nrd=$nrd/4;
	print "$f\t$nrd\n";
}
