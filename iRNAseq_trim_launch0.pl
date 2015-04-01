#!/usr/bin/perl

my $usage= "

this one os for reads starting with ATGGG

Prints out list of commands for launcher_creator.py 
to trim Illumina RNA-seq reads

Arguments:
1: glob to fastq files
2: optional, the position of name-deriving string in the file name
	if separated by underscores, 
	such as: input file Sample_RNA_2DVH_L002_R1.cat.fastq
	specifying arg2 as \'3\' would create output file with a name \'2DVH.fastq'	
			
";

if (!$ARGV[0]) { die $usage;}
my $glob=$ARGV[0];

opendir THIS, ".";
my @fqs=grep /$glob/,readdir THIS;
my $outname="";

foreach $fqf (@fqs) {
	if ($ARGV[1]) {
		my @parts=split('_',$fqf);
		$outname=$parts[$ARGV[1]-1].".trim";
	}
	else { $outname=$fqf.".trim";}
	print "perl rnaseq_clipper0.pl $fqf | fastx_clipper -a AAAAAAAA -l 20 -Q33 | fastq_quality_filter -Q33 -q 20 -p 90 >$outname\n";
}

