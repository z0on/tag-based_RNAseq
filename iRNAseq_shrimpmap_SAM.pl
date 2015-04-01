#!/usr/bin/perl

my $usage= "

iRNAseq_shrimpmap_SAM.pl :

Prints out a list of gmapper calls to map Illumina RNA-seq reads, one for each reads file.

prints to STDOUT

Arguments:
1: glob to fastq files
2: database to map to, such as '~/db/transcriptome.fasta'
3: optional, the position of name-deriving string in the file name
	if it is by underscores or dots 
	
Example: 
iRNAseq_shrimpmap_SAM.pl \"trim$\" ~/db/transcriptome.fasta  > maps

NOTE: if you plan to use bowtie2 (recommended) for mampping, use iRNAseq_bowtie2map.pl instead.

";

if (!$ARGV[0]) { die $usage;}
my $glob=$ARGV[0];
if (!$ARGV[1]) { die $usage;}
my $db=$ARGV[1];


opendir THIS, ".";
my @fqs=grep /$glob/,readdir THIS;
my $outname="";

foreach $fqf (@fqs) {
	if ($ARGV[2]) {
		my @parts=split(/[_\.]/,$fqf);
		$outname=$parts[$ARGV[2]-1].".sam";
	}
	else { $outname=$fqf.".sam";}
	print "gmapper $fqf $db -N 3 --fastq --strata --local --qv-offset 33 >$outname\n";
}

