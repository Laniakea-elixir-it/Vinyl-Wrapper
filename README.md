# VINYL
[VINYL](https://www.biorxiv.org/content/10.1101/2020.01.23.917229v1.full), Variant prIoritizatioN bY survivaL analysis, is a highly accurate and fully automated system for the functional annotation and prioritization of genetic variants in large scale clinical studies. By building on guidelines and recommendations derived from clinical practice, VINYL derives a pathogenicity score by aggregating different sources of evidence and annotations obtained from publicly available resources for the functional annotation of human genetic variants.   

Annotation of VCF files is performed by the Annovar software, using a collection of “standard” resources maintained by the Annovar developers along with a selection of custom annotation tracks. The VINYL application itself is implemented as a collection of Perl and R scripts and is composed of 3 main modules:
- *the optimizer*, which computes the optimal weights for the components of the pathogenicity score by performing a grid search over the parameter space;
- *the threshold optimizer*, that derives the optimal score threshold for the identification of likely pathogenic variants
- and *the score calculator*, the main tool which computes the pathogenicity scores.
These tools can be executed independently, or via an automated workflow which is available in the VINYL Galaxy instance

All the software is currently available from <http://beaconlab.it/VINYL>.    
A detailed manual for the usage of VINYL is available at <http://90.147.75.93/galaxy/static/manual/>.    
VINYL is available as a standalone command line-tool from <https://github.com/matteo14c/VINYL>.
