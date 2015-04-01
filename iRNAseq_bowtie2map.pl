#!/usr/bin/perl

my $usage= "

iRNAseq_bowtie2map.pl :

Prints out a list of bowtie2 calls to map Illumina RNA-seq reads,  one for each reads file.
Make sure to run bowtie2-build on your transcriptome before running this.

prints to STDOUT

Arguments:
1: glob to fastq files
2: database to map to, such as '~/db/transcriptome.fasta'
3: optional, the position of name-deriving string in the file name
	if it is by underscores or dots 
	
Example: 
iRNAseq_bowtie2map.pl \"trim$\" ~/db/transcriptome.fasta  > maps

NOTE: if you plan to use gmapper (SHRiMP) for mampping, use iRNAseq_shrimpmap_SAM.pl instead.
	
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
	print "bowtie2 --local -x $db -U $fqf -S $outname --no-hd --no-sq --no-unal -k 5\n";
}
