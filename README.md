Genome-wide gene expression profiling with tag-based RNA-seq
------------------------------------------------------------

Tag-based RNA-seq is a method of measuring expression of eukaryotic protein-coding genes on a whole-genome scale. Compared to standard RNA-seq it is very cost-efficient (on the order of $50/sample, all inclusive), allowing extensive experimental designs. The method, however, requires a reference (transcriptome or genome) to map reads to.  

the method has been described in Meyer, Aglyamova and Matz, Mol Ecol 2011 ( doi: 10.1111/j.1365-294X.2011.05205.x ). Since then it has been adapted for Illumina sequencing, lab procedures have been further simplified, and removal of PCR duplicates has been implemented.

This project provides the scripts and walkthoughs for initial sequence data processing (from reads to gene counts), including:
- concatenating raw sequence files according to the sampling design;
- adaptor trimming, quality filtering and removal of PCR duplicates;
- mapping against reference transcriptome;
- deriving gene counts.
