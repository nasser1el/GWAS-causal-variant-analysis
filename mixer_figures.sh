#!/bin/bash

# Job name: MiXeR Figures
#SBATCH --job-name=mixer_figures
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

GWAS1="bip"
GWAS2="scz"
MIXER_COMMON_ARGS="--ld-file containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.run4.ld --bim-file containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.@.bim"
REP="rep@"
EXTRACT="--extract containers/reference/ldsc/1000G_EUR_Phase3_plink/1000G.EUR.QC.prune_maf0p05_rand2M_r2p8.$REP.snps"
PYTHON="singularity exec --home $PWD:/home containers/singularity/python3.sif python"

$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS1.fit.$REP.json  --out $GWAS1.fit
$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS1.test.$REP.json  --out $GWAS1.test
$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS2.fit.$REP.json  --out $GWAS2.fit
$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS2.test.$REP.json  --out $GWAS2.test
$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS1.vs.$GWAS2.fit.$REP.json  --out $GWAS1.vs.$GWAS2.fit
$PYTHON /tools/mixer/precimed/mixer_figures.py combine --json $GWAS1.vs.$GWAS2.test.$REP.json  --out $GWAS1.vs.$GWAS2.test

$PYTHON /tools/mixer/precimed/mixer_figures.py one --json $GWAS1.fit.json $GW2.fit.json --out $GWAS1.and.$GWAS2.fit --trait1 $GWAS1 $GWAS2 --statistic mean std --ext svg
$PYTHON /tools/mixer/precimed/mixer_figures.py one --json $GWAS1.test.json $GWAS2.test.json --out $GWAS1.and.$GWAS2.$REP.test --trait1 $GWAS1 $GWAS2 --statistic mean std --ext svg
$PYTHON /tools/mixer/precimed/mixer_figures.py two --json-fit $GWAS1.vs.$GWAS2.fit.json --json-test $GWAS1.vs.$GWAS2.test.json --out $GWAS1.vs.$GWAS2.$REP --trait1 $GWAS1 --trait2 $GWAS2 --statistic mean std --ext svg

