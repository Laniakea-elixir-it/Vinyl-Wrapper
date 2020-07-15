# VINYL on Galaxy
[VINYL](https://www.biorxiv.org/content/10.1101/2020.01.23.917229v1.full), Variant prIoritizatioN bY survivaL analysis, is a highly accurate and fully automated system for the functional annotation and prioritization of genetic variants in large scale clinical studies. By building on guidelines and recommendations derived from clinical practice, VINYL derives a pathogenicity score by aggregating different sources of evidence and annotations obtained from publicly available resources for the functional annotation of human genetic variants.   

Annotation of VCF files is performed by the Annovar software, using a collection of “standard” resources maintained by the Annovar developers along with a selection of custom annotation tracks. The VINYL application itself is implemented as a collection of Perl and R scripts and is composed of 3 main modules:
- *the optimizer*, which computes the optimal weights for the components of the pathogenicity score by performing a grid search over the parameter space;
- *the threshold optimizer*, that derives the optimal score threshold for the identification of likely pathogenic variants
- and *the score calculator*, the main tool which computes the pathogenicity scores.

These tools can be executed independently, or via an automated workflow which is available in the VINYL Galaxy instance

-------------------
``Vinyl``
-------------------

| Description: | This wrapper provides the module of VINYL that perform score calculation. The program computes an aggregate score, which is based on an extensive collection of publicly available annoations, in order to identify/prioritize variants that are likely to be pathogenic or have a clinical significance. In order to derive an optimal cut off score for the variants, VINYL uses a strategy based on "survival analysis", where the pathogenicity score distribution of the affected individuals is compared with a matched cohort of unaffected individuals |
|--------------|-----------------------------------------------------------------|
| Galaxy Wrapper: | [Wrapper VINYL](https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl/da94ac699bfa) |

-------------------
``Vinyl-Annovar``
-------------------

:Description: 
        This tool will annotate variants using specified gene annotations, regions, and filtering databases. Input is a VCF dataset, and output is a table of annotations for each variant in the VCF dataset or a VCF dataset with the annotations in INFO fields

:Galaxy Wrapper: `Wrapper VINYL-annovar <https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl_annovar/121eb1c88ec2>`

-------------------
``Vinyl-Survival``
-------------------

:Description:
        This wrapper provides the module of VINYL that perform survival analysis for the identification of a pathogenicity score cut-off. Two input tabular files need to be provided, one containing VINIL scores and annotations on a cohort of affected individual, and one from a population of unaffected controls

:Galaxy Wrapper: `Wrapper VINYL-survival <https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl_survival/978e043603f7>`

------------------
`Vinyl-Optimizer`
------------------

:Description:
        This wrapper provides the module of VINYL that perform score optimization. Two input VCF files need to be provided, one containing genetic variants from a cohort of affected individuals, and one from a population of unaffected controls

:Galaxy Wrapper: `Wrapper VINYL-Optimizer <https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl_optimizer/4c6529d120c3>`

-----------------
`Vinyl-Boxplot`
-----------------

:Description:
        This wrapper provides the module of VINYL that compares score distributions of single genes. Two input files need to be provided, both in tabular format. The first file must contain VINYL scores for affected individuals, the second, equivalent score for unaffected controls. Both files can be obtained by running VINYL on annovar-annotated vcf-files

:Galaxy Wrapper: `Wrapper VINYL-Boxplot <https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl_boxplot/a68a11ce2abd>` 

-----------------
`Vinyl-PCA`
-----------------

:Description: 
        This wrapper provides the module of VINYL that performs PCA analysis of score distribution to identify groups/subgroups of patients and/or samples. Two input files need to be provided, both in vcf format. The first file must contain VINYL scores for affected individuals, the second, equivalent score for unaffected controls
:Galaxy Wrapper: `Wrapper VINYL-PCA <https://testtoolshed.g2.bx.psu.edu/view/elixir-it/vinyl_pca/460883beb10c>`

---------------------

VINYL workflows
================

