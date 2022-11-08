# Causal Variant Analysis of Psychiatric Traits Using GWAS Summary Statistics

<h1>Abstract</h1>
Understanding polygenic overlap of diseases can provide insight into the shared causal mechanisms of related disorders. The two prevailing methods for quantifying polygenic overlap are genetic correlation, which measures the additive genetic effects for a pair of traits, and colocalization, which estimates if a GWAS signal shared by two traits at the same loci is due to chance or is driven by the same causal variant. Here, we provide a comparison of two different statistical tools for cross-trait analysis, MiXeR, which quantifies polygenic overlap without the use of genetic correlation, and UNITY (Unifying Non-Infinitesimal Trait analYsis), which utilizes both genetic correlation and colocalization in its estimation of polygenic overlap, using publicly-available GWAS data for bipolar disorder, major depressive disorder, and schizophrenia from the Psychiatric Genomics Consortium (PGC).
<br/>
<h1>Introduction</h1>
MiXeR and UNITY are two statistical tools that aim to quantify polygenic overlap for two traits using only their GWAS summary statistics. UNITY, rather than using an infinitesimal framework that makes the simplifying assumption that all SNPs have a small, but non-zero, effect on a trait, utilizes a non-infinitesimal genetic architecture that combines methods of genetic correlation and colocalization to identify the proportion of non-causal variants, shared causal variants, and trait-specific causal variants for a pair of traits. MiXeR estimates the total quantity of shared and trait-specific causal variants irrespective of genetic correlation through the use of a bivariate model, which assumes the majority of variants to have zero effect on the trait and follows a normal distribution. UNITY makes fewer assumptions about the distribution and contribution of single variants, and it follows a richly parameterized Bayesian model that allows manipulation of influencing factors like trait heritability.
<br/>
While UNITY was tested on simulated data and height and BMI data, we had concerns about its applicability to real cross-trait analysis for more complex traits. Therefore, we set out to compare the estimates of UNITY and MiXeR, which was more extensively tested on real GWAS data, using GWAS data for schizophrenia, bipolar disorder, and major depressive disorder.
<br/>
<h1>Materials and Methods</h1>
<ins>Genome-Wide Association Study</ins> <br/>
From the PGC, we chose papers for bipolar disorder, major depressive disorder, and schizophrenia that ensured LD pruning and downloaded their data files. The GWAS files were then reduced to the following columns: a unique identifier, allele 1, allele 2 (non-effect allele), sample size (usually static), p-value, and the signed z-score which was calculated using the provided odds ratios and p-values. Lastly, we extracted only matching SNPs between the three GWAS files and removed SNPs from the MHC (chr6:26-34M) region.  
<br/>
<br/>
<ins>Linkage Disequilibrium Score Regression</ins> <br/>
Using the prepared GWAS files, we performed cross-trait LD score regression to estimate the heritability and genetic correlation values for each combination of traits.
<br/>
<br/>
<ins>MiXeR</ins> <br/>
Using MiXeR v1.3 and the prepared GWAS files, we created three job arrays for studying overlap between each combination of the three disorders, each generating twenty univariate and bivariate runs from different reference panels which were then averaged to produce six different summarizing json files. The resulting json files are used to produce csv files that summarize the statistical power of the MiXeR runs and produce the desired Venn diagrams. 
<br/>
<br/>
<ins>UNITY</ins> <br/>
The necessary parameters for UNITY, heritability, genetic correlation, number of SNPs, and sample size, were drawn from the original papers and cross-trait LD score regression. Next, the prepared GWAS files were reduced to just their Z-scores as this is the only column used as an input for the GWAS files. From these inputs, UNITY averages the results from 100 Markov Chain Monte Carlo chains to produce the final causal variant estimates. 	

<h1>Results</h1>
<ins>MiXeR</ins> <br/>

![bip_vs_scz_MiXeR.svg](/results/bip_vs_scz_MiXeR.svg)

![BIP vs. MDD](/results/bip_vs_mdd_MiXeR.svg)

![MDD vs. SCZ](/results/mdd_vs_scz_MiXeR.svg)

MiXeR results are presented as a venn diagram showing the estimate of unique and shared causal variants in thousands with the standard error reported in parentheses. The proportions of causal variants were taken directly from csv files produced by MiXeR and reported here as percentages. For bipolar disorder and schizophrenia, MiXeR estimated 0 unique causal variants for bipolar disorder (~0%), 6.7 K shared causal variants (~0.0021%), and 11.2 K unique causal variants for schizophrenia (~0.0035%). For bipolar disorder and major depressive disorder, MiXeR estimated 2.6 K unique causal variants for bipolar disorder (~ 0.0008%), 4.1 K shared causal variants (~0.0013%), and 1.4 K unique causal variants for major depressive disorder (~0.0004%). For major depressive disorder and schizophrenia, MiXeR estimated 0.7 K unique causal variants for major depressive disorder (~0.0002%), 5.5 K shared causal variants (~0.0017%), and 12.3 K unique causal variants for schizophrenia (~0.0039%).  
<br/>
<br/>
<ins>UNITY</ins> <br/>

| BIP vs. SCZ                               | BIP vs. MDD                                | MDD vs. SCZ                               |
|:-----------------------------------------:|:------------------------------------------:|:-----------------------------------------:|
|![bip_vs_scz.png](/results/bip_vs_scz.png) | ![bip_vs_mdd.png](/results/bip_vs_mdd.png) | ![mdd_vs_scz.png](/results/mdd_vs_scz.png)|

UNITY results are reported as proportions of causal variants which were then used to form the figures seen above. For bipolar disorder and schizophrenia, UNITY estimated 0.0003% non-causal variants, 0.93% unique causal variants for bipolar disorder, 0.068% unique causal variants for schizophrenia, and 0.0006% shared causal variants. For bipolar disorder and major depressive disorder, UNITY estimated 0.50% non-causal variants, 0% unique causal variants for bipolar disorder, 0.50% unique causal variants for major depressive disorder, and 0% shared causal variants. For major depressive disorder and schizophrenia, UNITY estimated 0.50% non-causal variants, 0% unique causal variants for major depressive disorder, 0.50% unique causal variants for schizophrenia, and 0% shared causal variants. 

<h1>Discussion</h1>
UNITY’s estimates were unpredictable and much less consistent when compared to MiXeR. For all three cross-trait analyses, MiXeR estimated over 99% non-causal variants and a small percentage of shared and trait-specific causal variants which more closely resembles the expected results from GWAS data. UNITY, however, estimated at least 50% trait-specific causal variants in each cross-trait analysis among other concerning results. Therefore, despite the lack of incorporation of genetic correlation into its measurements, the MiXeR software appears to be a more reliable and accurate tool for estimating causal variants for cross-trait analysis as the results more closely align with the reported genetic overlap of bipolar disorder, major depressive disorder, and schizophrenia from other scientific literature (Schulze, Thomas G et al., 2014; Cross-Disorder Group of the Psychiatric Genomics Consortium et al., 2013).
<br/>
<br/>
While UNITY was tested using several different simulations, most of these simulations used a low amount of SNPs (~500), low heritability values (~0.001 to 0.05), and often made the assumption that the heritabilities of each trait were equal. During our analysis, we found these parameters to not be representative of real GWAS summary statistics which often have much a much higher amount of SNPs, varying heritabilities, and higher heritability values. As such, in adjusting the UNITY software for future use, we recommend the SNP and heritability parameters be further researched and altered to make the model more robust for real GWAS analysis. 

<h1>Appendix</h1>
<ins>References</ins>

Ruth Johnson, Huwenbo Shi, Bogdan Pasaniuc, Sriram Sankararaman, A unifying framework for joint trait analysis under a non-infinitesimal model, Bioinformatics, Volume 34, Issue 13, 01 July 2018, Pages i195–i201, https://doi.org/10.1093/bioinformatics/bty254

Frei, O., Holland, D., Smeland, O.B. et al. Bivariate causal mixture model quantifies polygenic overlap between complex traits beyond genetic correlation. Nat Commun 10, 2417 (2019). https://doi.org/10.1038/s41467-019-10310-0

Bulik-Sullivan, B., Loh, PR., Finucane, H. et al. LD Score regression distinguishes confounding 
from polygenicity in genome-wide association studies. Nat Genet 47, 291–295 (2015). 
https://doi.org/10.1038/ng.3211

Schulze, Thomas G et al. “Molecular genetic overlap in bipolar disorder, schizophrenia, and 
major depressive disorder.” The world journal of biological psychiatry : the official journal of the World Federation of Societies of Biological Psychiatry vol. 15,3 (2014): 200-8. https://doi.org/10.3109/15622975.2012.662282

Cross-Disorder Group of the Psychiatric Genomics Consortium et al. “Genetic relationship 
between five psychiatric disorders estimated from genome-wide SNPs.” Nature genetics vol. 45,9 (2013): 984-94. https://doi.org/10.1038/ng.2711

Stahl, E.A., Breen, G., Forstner, A.J. et al. Genome-wide association study identifies 30 loci associated with bipolar disorder. Nat Genet 51, 793–803 (2019). https://doi.org/10.1038/s41588-019-0397-8

Ripke, S., O'Dushlaine, C., Chambert, K. et al. Genome-wide association analysis identifies 13 new risk loci for schizophrenia. Nat Genet 45, 1150–1159 (2013). https://doi.org/10.1038/ng.2742

Wray, N.R., Ripke, S., Mattheisen, M. et al. Genome-wide association analyses identify 44 risk variants and refine the genetic architecture of major depression. Nat Genet 50, 668–681 (2018). https://doi.org/10.1038/s41588-018-0090-3

Analysis and research was completed alongside Lisa Wang, Nikita Patra, and Riley Xin
