#!/bin/bash

# Job name: GWAS ANALYSIS
#SBATCH --job-name=gwas_analysis
#SBATCH --account=INSERT
#SBATCH --time=2:00:00

#SBATCH --partition=shared
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4G
#SBATCH --nodes=1

#
## Set up job environment:
source /cluster/bin/jobsetup
module purge   # clear any inherited modules
module load plink
set -o errexit # exit on errors

# import necessary libraries
import pandas as pd
import numpy as np
from scipy import stats
import os
 
# read in GWAS files from original csv files
trait1 = pd.read_csv("TRAIT1.csv", sep='\t')
 
# calculating Z-score from P-value and Odds Ratio
trait1['Z'] = -stats.norm.ppf(trait1['P'].values*0.5)*np.sign(trait1['OR'].values - 1).astype(np.float64)
 
# upper-case all of the alleles and update the file
trait1['A1']=trait1['A1'].str.upper()
trait1['A2']=trait1['A2'].str.upper()
 
# removing MHC region
mhc=(trait1['CHR']==6) & (trait1['BP']>26e6) & (trait1['BP'] < 34e6)
trait1.loc[~mhc, ['SNP', 'CHR', 'BP', 'A1', 'A2', 'N', 'Z', 'P']].to_csv('TRAIT1.sumstats', index=False, sep='\t')
 
# zip file and export
os.system('gzip -f TRAIT1.sumstats')
print("read")

