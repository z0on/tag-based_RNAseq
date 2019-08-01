Genome-wide gene expression profiling with tag-based RNA-seq (TagSeq)
------------------------------------------------------------

Mikhail Matz, matz@utexas.edu

NOW TESTED WITH NOVASEQ!

Current library preparation protocols (feel free to comment!):

"micro" version (1-10 ng total RNA): https://docs.google.com/document/d/1ySHaW-m53q13H7mIfBl8Rpye_Ji2zBZ0zlWq_PTYmEg/edit?usp=sharing

simplified version (100 ng of total RNA): https://docs.google.com/document/d/1wg-MGPTRjDu0KJ_6hJcT8FUZ3650nzfOpwBK8bzxL2w/edit?usp=sharing

Tag-based RNA-seq is a method of measuring expression of eukaryotic protein-coding genes on a whole-genome scale. Compared to standard RNA-seq it is very cost-efficient (on the order of $50/sample, all inclusive), allowing extensive experimental designs. The method, however, requires a reference (transcriptome or genome) to map reads to.  

The method has been described in Meyer, Aglyamova and Matz, Mol Ecol 2011 ( http://bit.ly/1Zy8Ki7 ). Since then it has been adapted for Illumina sequencing, lab procedures have been further simplified, and removal of PCR duplicates has been implemented.

Lohman et al extensively benchmarked TagSeq against standard RNA-seq (NEBNext) and found that tag-seq quantifies transcript abndances more accurately, for about 10% of the cost: http://onlinelibrary.wiley.com/doi/10.1111/1755-0998.12529/abstract

This project provides the up-to-date wet lab protocol, scripts and walkthoughs for initial sequence data processing (from reads to gene counts), including:
- concatenating raw sequence files according to the sampling design;
- adaptor trimming, quality filtering and removal of PCR duplicates;
- mapping against reference transcriptome;
- deriving gene counts.
