Tag-based RNA-seq reads processing pipeline, version October 13, 2014

NOTE: this walkthrough has been written for lonestar cluster of the Texas
Advanced Computer Center, which has 12 cores per node and uses Sun Grid Engine 
(SGE) batch processing system. To adopt the walkthough to your cluster you 
would need to edit the launcher_creator.py script to make its default settings
compatible with your cluster. 

Firstly: make sure you have the following tools installed and 
available on your cluster:

python: http://www.python.org/getit/
fastx_toolkit: http://hannonlab.cshl.edu/fastx_toolkit/download.html
cd-hit: https://cdhit.googlecode.com/files/cd-hit-v4.6.1-2012-08-27.tgz
bowtie2: http://bowtie-bio.sourceforge.net/index.shtml 

(On TACC lonestar cluster, simply say
module load python
module load bowtie
module load fastx_toolkit
)

#-----------------------
# installing RNA-seq scripts and setting up the workspace

# switch to root directory
cd 

# unless you have done it in the past, make directory called bin, 
# all your script should go in there:
mkdir bin 

# switch to bin:
cd bin 

# get the compressed scripts using wget:
wget https://sourceforge.net/projects/tag-based-rnaseq/files/latest/download/tag-seq.tgz --no-check-certificate

# unzip it:
tar vxf tag-seq.tgz
	
#------------------------------
# downloading sequence data: 

cd /where/you/want/readFilesToBe/

# download sequence files from a web link, if you were given one
wget http://blah/blah/*

# or you may need to use secure-copy:
scp yourUserName@computer.that.has.read.files:/path/to/read/files/* .

#-------------------------------
# unzipping and concatenating sequence files

# creating and launching a cluster job to unzip all files:
ls *.gz | perl -pe 's/(\S+)/gunzip $1/' >gunz
launcher_creator.py -t 1:00:00 -j gunz -n gunz -l gunz.job
qsub gunz.job

# check status of your job (qw : in queue; r : running; nothing printed on the screen - complete) 
qstat 

# If your samples are split across multiple files from different lanes, 
# concatenating the corresponding fastq files by sample:
ngs_concat.pl commonTextInFastqFilenames  "FilenameTextImmediatelyBeforeSampleID(.+)FilenameTextImmediatelyAfterSampleID"

# make a directory to put away your raw files:
mkdir Raw

# move them all there:
mv commonTextInRawFastqFilenames Raw/

# look at the reads:
head -50 SampleName.fq 

# this little one-liner will show sequence-only:
head -100 SampleName.fq | grep -E '^[NACGT]+$'

#------------------------------
# adaptor and quality trimming:

# creating and launching the cleaning process for all files in the same time:
	# NOTE: if you get an error saying something about invalid quality values,
	# replace the first of the three lines below with this one: 
	# iRNAseq_trim_launch.pl '\.fq$' > clean 
iRNAseq_trim_launch.pl '\.fq$' > clean
launcher_creator.py -t 1:00:00 -j clean -n clean -l clean.job
qsub clean.job

# how the job is doing?
qstat

# It is complete! I got a bunch of .trim files that are non-empty! 
# but did the trimming really work? 
# Use the same one-liner as before on the trimmed file to see if it is different
# from the raw one that you looked at before:
head -100 SampleName.fq.trim | grep -E '^[NACGT]+$'

#--------------------------------------
# download and format reference transcriptome:

cd /where/you/want/your/genomes/toLive/
mkdir db
cd db
# download the transcriptome data using wget or scp, for example, for A.millepora
wget https://dl.dropboxusercontent.com/u/37523721/amillepora_apr2014_reannotated.tgz
tar vxf amillepora_apr2014_reannotated.tgz
pwd
# copy pwd result: /path/to/reference/    

# go back to /where/reads/are/
cd /where/reads/are/

#--------------------------------------

# mapping reads to the transcriptome with bowtie2 
module load bowtie

# creating bowtie2 index for your transcriptome:
cd /path/to/reference/
bowtie2-build transcriptome.fasta transcriptome.fasta 

iRNAseq_bowtie2map.pl "trim$" /path/to/reference/transcriptome.fasta  > maps
launcher_creator.py -t 1:00:00 -j maps -n maps -l mapsjob 
qsub mapsjob

# how is the job?
qstat

# complete! I got a bunch of large .sam files.
# what is the mapping efficiency? This will find relevant lines in the "job output" file
# that was created while the mapping was running
grep "overall alignment rate" maps.e*

#---------------------------------------
# almost done! Just two small things left:
# generating read-counts-per gene: (again, creating a job file to do it simultaneously for all)

# NOTE: Must have a tab-delimited file giving correspondence between contigs in the transcriptome fasta file
# and genes. Typically, each gene is represented by several contigs in the transcriptome. 
# For Newbler-assembled (454-based) transcriptomes, this would be a table of contigs correspondence
# to isogroups. 

# For Trinity transcriptomes, it would be contigs to components table. To create such a table:
grep ">" transcriptome.fasta | perl -pe 's/>comp(\d+)(\S+)\s.+/comp$1$2\tc$1/' >transcriptome_seq2iso.tab

# if you have no assembler-derived isogroups, use cd-hit-est to cluster contigs.
# to look for 99% or better matches between contigs taking 30% of length of either longer or shorter sequence:
cd-hit-est -i transcriptome.fasta -o transcriptome_clust.fasta -c 0.99 -G 0 -aL 0.3 -aS 0.3
# adding cluster designations to fasta headers:
isogroup_namer.pl transcriptome.fasta transcriptome_clust.fasta.clstr >transcriptome_seq2iso.tab

# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' /path/to/reference/transcriptome_seq2iso.tab > sc
launcher_creator.py -t 1:00:00 -j sc -n sc -l sc.job
qsub sc.job

# check on the job
qstat

# done! a bunch of .counts files were produced.
# assembling them all into a single table:
expression_compiler.pl *.sam.counts > allcounts.txt

# make sure allcounts.txt actually contains counts:
head allcounts.txt

# display full path to where you were doing all this:
pwd
# copy the path!

#---------------------------------------
# whew. Now just need to copy the result to your laptop!

# open new terminal window on Mac, or WinSCP on Windows
# navigate to the directory you want the file to be. 

# copy the file from lonestar using scp (in WinSCP, just paste the path you just copied
# into an appropriate slot (should be self-evident) and drag the allcounts.txt file
# to your local directory):

scp yourUserName@your.cluster:/path/you/just/copied/allcounts.txt .

# DONE! use DESeq package in R to make sense of the counts.







