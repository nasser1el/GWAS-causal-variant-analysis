#!/bin/bash

# Job name: MiXeR Analysis
#SBATCH --job-name=mixer_analysis
#SBATCH --account=INSERT
#SBATCH --time=2:00:00

#SBATCH --partition=shared
#SBATCH --cpus-per-task=20
#SBATCH --mem-per-cpu=5000M
#SBATCH --nodes=1
#SBATCH --array=1-20

#
## Set up job environment:
source /cluster/bin/jobsetup
module purge   # clear any inherited modules
module load plink
set -o errexit # exit on errors

# Script content 
cd /u/scratch/n/nasser1e/UNITY
module load singularity
module load python/3.9.6

# This code was used for all three traits (just switch out GWAS1 and GWAS2)
GWAS1="bip"
GWAS2="scz"
MIXER_COMMON_ARGS="--ld-file containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.run4.ld --bim-file containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.bim"
REP="rep${SGE_TASK_ID}"
EXTRACT="--extract containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.prune_maf0p05_rand2M_r2p8.$REP.snps"
PYTHON="singularity exec --home $PWD:/home containers/singularity/python3.sif python"

$PYTHON /tools/mixer/precimed/mixer.py fit1 $MIXER_COMMON_ARGS $EXTRACT --trait1-file $GWAS1.sumstats.gz --out $GWAS1.fit.$REP
$PYTHON /tools/mixer/precimed/mixer.py fit1 $MIXER_COMMON_ARGS $EXTRACT --trait1-file $GWAS2.sumstats.gz --out $GWAS2.fit.$REP
$PYTHON /tools/mixer/precimed/mixer.py fit2 $MIXER_COMMON_ARGS $EXTRACT --trait1-file $GWAS1.sumstats.gz --trait2-file $GWAS2.sumstats.gz --trait1-params $GWAS1.fit.$REP.json --trait2-params $GWAS2.fit.$REP.json --out $GWAS1.vs.$GWAS2.fit.$REP

$PYTHON /tools/mixer/precimed/mixer.py test1 $MIXER_COMMON_ARGS --trait1-file $GWAS1.sumstats.gz --load-params $GWAS1.fit.$REP.json --out $GWAS1.test.$REP
$PYTHON /tools/mixer/precimed/mixer.py test1 $MIXER_COMMON_ARGS --trait1-file $GWAS2.sumstats.gz --load-params $GWAS2.fit.$REP.json --out $GWAS2.test.$REP
$PYTHON /tools/mixer/precimed/mixer.py test2 $MIXER_COMMON_ARGS --trait1-file $GWAS1.sumstats.gz --trait2-file $GWAS2.sumstats.gz --load-params $GWAS1.vs.$GWAS2.fit.$REP.json --out $GWAS1.vs.$GWAS2.test.$REP	

