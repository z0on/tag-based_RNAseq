Tag-based RNA-seq reads processing pipeline, version December 29, 2017

NOTE: in many places throughout this walkthrough you will need to execute a long list of commands - in fact the exact same command for each reads file. On Texas Advanced Computing Center clusters this is done in parallel using LAUNCHER utility (https://www.tacc.utexas.edu/research-development/tacc-software/the-launcher), which should be possible to adopt on any cluster running SLURM scheduling. 

Make sure you have the following tools installed and 
available on your cluster:

cutadapt: https://cutadapt.readthedocs.io/en/stable/installation.html
bowtie2: http://bowtie-bio.sourceforge.net/index.shtml 

#-----------------------
# install tag-seq scripts

git clone https://github.com/z0on/tag-based_RNAseq.git

#add path to the directory tag-based_RNAseq to your $PATH

# If your samples are split across multiple files from different lanes, 
# concatenating the corresponding fastq files by sample:

ngs_concat.pl commonTextInFastqFilenames  "FilenameTextImmediatelyBeforeSampleID(.+)FilenameTextImmediatelyAfterSampleID"

#------------------------------
# (Assuming we have many files with extension fastq, and we have cutadapt installed and working)
# adaptor trimming, deduplicating, and quality filtering:

# creating cleaning process commands for all files:
>clean
for F in *.fq; do
echo "tagseq_clipper.pl $F | cutadapt - -a AAAAAAAA -a AGATCGG -q 15 -m 25 -o ${F/.fq/}.trim" >>clean;
done

# now execute all commands written to file 'clean', preferably in parallel (see Note in the beginning of this walkthrough)

#---------------------------------------
# download and format reference transcriptome:
# NOTE: this pipeline assumes that the reference is transcriptome - either made de novo, 
# or generated in silico based on annotated genome. We recommend this way of analysis 
# to save computing power.

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

# NOTE: Here, you must have a two-column tab-delimited table transcriptome_seq2gene.tab giving correspondence between entries in the transcriptome fasta file and genes. In de novo transcriptomes, several fasta contigs may correspond to the same gene (e.g., splice isoforms, or assembly uncertainties). 
# To create such table for a Trinity-derived de novo transcriptome:
grep ">" trinity.fasta | perl -pe 's/^>(\S+)\|(\S+)(_i\d+)\s.+/$1\|$2$3\t$1_$2/' >transcriptome_seq2iso.tab

# if you have no assembler-derived "genes" for your de-novo transcriptome, one possibility is to use cd-hit-est to cluster contigs. 
# To look for 99% or better matches between contigs taking 30% of length of either longer or shorter sequence:
cd-hit-est -i transcriptome.fasta -o transcriptome_clust.fasta -c 0.99 -G 0 -aL 0.3 -aS 0.3
# adding cluster designations to fasta headers:
isogroup_namer.pl transcriptome.fasta transcriptome_clust.fasta.clstr >transcriptome_seq2gene.tab

# if your transcriptome is made in silico from annotated genome data, just use a dummy table in the form:
# gene	gene


# counting hits per isogroup:
samcount_launch_bt2.pl '\.sam' /path/to/reference/data/transcriptome_seq2gene.tab > sc
# execute all commands in 'sc' file

# assembling all counts into a single table:
expression_compiler.pl *.sam.counts > allcounts.txt

# DONE! use your favorite R packaged (DESeq2, WGCNA) to make sense of the counts.







