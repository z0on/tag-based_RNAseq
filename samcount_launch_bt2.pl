#!/usr/bin/perl

my $usage= "

Prints out list of commands for launcher_creator.py 
to derive counts from SAM files made with bowtie2

Arguments:
1: glob to sam files
2: path-filename of clusters2isogroups table
			
";

if (!$ARGV[0]) { die $usage;}
my $glob=shift @ARGV or die $usage;
my $tab=shift @ARGV or die $usage;

opendir THIS, ".";
my @fqs=grep /$glob/,readdir THIS;
my $outname="";

foreach $fqf (@fqs) {
	$outname=$fqf.".counts";
	print "samcount.pl $fqf $tab aligner=bowtie2 >$outname\n";
}
