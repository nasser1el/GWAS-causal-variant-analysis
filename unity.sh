#!/bin/bash

# Job name: UNITY ANALYSIS
#SBATCH --job-name=unity_analysis
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

# Download necessary files from GitHub
git clone https://github.com/bogdanlab/UNITY

# Data preparation
python
import pandas as pd

# Read in summary statistics files
bip = pd.read_csv('bip.sumstats', sep = '\t')
mdd = pd.read_csv('mdd.sumstats', sep = '\t')
scz = pd.read_csv('scz.sumstats', sep = '\t')

# Rename Z-score columns to prepare data
bip = bip.rename(columns={'Z': 'bip_Z'})
mdd = mdd.rename(columns={'Z': 'mdd_Z'})
scz = scz.rename(columns={'Z': 'scz_Z'})

# Merge into one large file based on matching alleles
bip_mdd = pd.merge(bip, mdd, on='SNP')
bms = pd.merge(bip_mdd, scz, on='SNP')

# Separate Z-scores
bip = bms['bip_Z']
mdd = bms['mdd_Z']
scz = bms['scz_Z']

# Export only the Z-scores for each GWAS file to use as an input for UNITY
bip.to_csv('z_bip.sumstats', index=False, header=False, sep='\t')
mdd.to_csv('z_mdd.sumstats', index=False, header=False, sep='\t')
scz.to_csv('z_scz.sumstats', index=False, header=False, sep='\t')

# Run UNITY using python version 2
module load python/2.7.18

# Run UNITY on bip vs. scz using known parameters
python main.py \
--H1 0.4054 \
--H2 0.309 \
--rho 0.9111 \
--M  1048575 \
--N1 46582 \
--N2 59318 \
--file1 z_bip.sumstats \
--file2 z_scz.sumstats 

# Run UNITY on bip vs. mdd using known parameters 
python main.py \
--H1 0.3762 \
--H2 0.1199 \
--rho 0.3279 \
--M  1048575 \
--N1 46582 \
--N2 173005 \
--file1 z_bip.sumstats \
--file2 z_mdd.sumstats 

# Run UNITY on mdd vs. scz using known parameters 
python main.py \
--H1 0.0951 \
--H2 0.4335 \
--rho 0.2583 \
--M  1048575 \
--N1 173005 \
--N2 59318 \
--file1 z_mdd.sumstats \
--file2 z_scz.sumstats 

