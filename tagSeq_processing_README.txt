Tag-based RNA-seq reads processing pipeline, version December 29, 2017

NOTE: in many places throughout this walkthrough you will need to execute a long list of commands - in fact the exact same command for each reads file. On Texas Advanced Computing Center clusters this is done in parallel using LAUNCHER utility (https://www.tacc.utexas.edu/research-development/tacc-software/the-launcher), which should be possible to adopt on any cluster running SLURM scheduling. 

Make sure you have the following tools installed and 
available on your cluster:

fastx_toolkit: http://hannonlab.cshl.edu/fastx_toolkit/download.html
bowtie2: http://bowtie-bio.sourceforge.net/index.shtml 

#-----------------------
# install tag-seq scripts

git clone https://github.com/z0on/tag-based_RNAseq.git

#add path to the directory tag-based_RNAseq to your $PATH

# If your samples are split across multiple files from different lanes, 
# concatenating the corresponding fastq files by sample:

ngs_concat.pl commonTextInFastqFilenames  "FilenameTextImmediatelyBeforeSampleID(.+)FilenameTextImmediatelyAfterSampleID"

#------------------------------
# (Assuming we have many files with extension fastq, and we have fastx_toolkit installed and working)
# adaptor trimming, deduplicating, and quality filtering:

# creating and launching the cleaning process for all files in the same time:
tagseq_trim_launch.pl '\.fastq$' > clean

# now execute all commands written to file 'clean', preferably in parallel (see Note in the beginning of this walkthrough)

#---------------------------------------
# download and format reference transcriptome:

cd /path/to/reference/data/
# download the transcriptome data using wget or scp, unpack it (tar vxf , unzip, etc)
# creating bowtie2 index for your transcriptome:
bowtie2-build transcriptome.fasta transcriptome.fasta 
cd /where/reads/are/

#---------------------------------------
# mapping reads to transcriptome

# cd where the trimmed read files are (extension "trim")
tagseq_bowtie2map.pl "trim$" /path/to/reference/transcriptome.fasta  > maps
# execute all the commands in 'maps', record screen output in some file

# alignment rates:
grep "overall alignment rate"  screenOutputFile

#---------------------------------------
# generating read-counts-per gene 

# NOTE: Must have a tab-delimited file giving correspondence between contigs in the transcriptome fasta file and genes. Typically, each gene is represented by several contigs in the transcriptome. 
# To create such table for a Trinity-derived de novo transcriptome:
grep ">" trinity.fasta | perl -pe 's/^>(\S+)\|(\S+)(_i\d+)\s.+/$1\|$2$3\t$1_$2/' >transcriptome_seq2iso.tab

# if you have no assembler-derived isogroups, use cd-hit-est to cluster contigs.
# to look for 99% or better matches between contigs taking 30% of length of either longer or shorter sequence:
cd-hit-est -i transcriptome.fasta -o transcriptome_clust.fasta -c 0.99 -G 0 -aL 0.3 -aS 0.3
# adding cluster designations to fasta headers:
isogroup_namer.pl transcriptome.fasta transcriptome_clust.fasta.clstr >transcriptome_seq2iso.tab

# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' /path/to/reference/data/transcriptome_seq2iso.tab > sc
# execute all commands in 'sc' file

# assembling all counts into a single table:
expression_compiler.pl *.sam.counts > allcounts.txt

# DONE! use your favorite R packaged (DESeq2, WGCNA) to make sense of the counts.







