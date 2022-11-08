#!/bin/bash

# Job name: LDSC ANALYSIS
#SBATCH --job-name=ldsc_analysis
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

# pulling from github source by cloning 
git clone https://github.com/bulik/ldsc.git

# download supplementary programs for Anaconda 
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh

# Once Anaconda has been downloaded and prepared, we can use LDSC
conda env create --file environment.yml
source activate ldsc

# Download allele reference files for munge_stats next
wget --no-check-certificate https://data.broadinstitute.org/alkesgroup/LDSCORE/eur_w_ld_chr.tar.bz2
wget  --no-check-certificate https://data.broadinstitute.org/alkesgroup/LDSCORE/w_hm3.snplist.bz2

# Loading environments and programs 
module load singularity
module load python/3.9.6 
conda env create --file environment.yml
source activate ldsc

# Convert sumstats files to TXT format
bip = pd.read_csv('bip.sumstats', sep = '\t')
mdd = pd.read_csv('mdd.sumstats', sep = '\t')
scz = pd.read_csv('scz.sumstats', sep = '\t')

bip.to_csv('bip.txt', header=True, sep='\t')
mdd.to_csv('mdd.txt', header=True, sep='\t')
scz.to_csv('scz.txt', header=True, sep='\t')

# Munge Data
python munge_sumstats.py \
--sumstats bip.txt \
--N 46582 \
--out bip_munged \
--chunksize 500000 \
--merge-alleles w_hm3.snplist

python munge_sumstats.py \
--sumstats mdd.txt \
--N 173005 \
--out mdd_munged \
--chunksize 500000 \
--merge-alleles w_hm3.snplist

python munge_sumstats.py \
--sumstats scz.txt \
--N 59318 \
--out scz_munged \
--chunksize 500000 \
--merge-alleles w_hm3.snplist

# Run LD Score Regression
python ldsc.py \
--rg bip_munged.sumstats.gz,mdd_munged.sumstats.gz \
--ref-ld-chr eur_w_ld_chr/ \
--w-ld-chr eur_w_ld_chr/ \
--out bip_mdd
less bip_mdd.log

python ldsc.py \
--rg bip_munged.sumstats.gz,scz_munged.sumstats.gz \
--ref-ld-chr eur_w_ld_chr/ \
--w-ld-chr eur_w_ld_chr/ \
--out bip_scz
less bip_scz.log

python ldsc.py \
--rg mdd_munged.sumstats.gz,scz_munged.sumstats.gz \
--ref-ld-chr eur_w_ld_chr/ \
--w-ld-chr eur_w_ld_chr/ \
--out mdd_scz
less mdd_scz.log

