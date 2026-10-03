#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=merqury
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_merqury_%j.o
#SBATCH --error=/data/users/awolfruiz/error_merqury_%j.e
#SBATCH --partition=pibu_el8

set -uo pipefail

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
OUTDIR=${WORKDIR}/assembly_evaluation/merqury
CONTAINER=/containers/apptainer/merqury_1.3.sif
READS=/data/courses/assembly-annotation-course/raw_data/Rab-R1/ERR11437340.fastq.gz

# k=19: merqury best_k for a ~135 Mb genome
K=19
MERYL_DB=${OUTDIR}/Rab-R1.k${K}.meryl

export MERQURY="/usr/local/share/merqury"

declare -A ASM=(
    [flye]=${WORKDIR}/assemblies/flye/assembly.fasta
    [hifiasm]=${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.fa
    [lja]=${WORKDIR}/assemblies/lja/assembly.fasta
)

mkdir -p ${OUTDIR}

# 1. Build meryl k-mer database from HiFi reads (skipped if it already exists)
if [ ! -d "${MERYL_DB}" ]; then
    apptainer exec --bind /data ${CONTAINER} \
        meryl count k=${K} threads=${SLURM_CPUS_PER_TASK} memory=60 \
        output ${MERYL_DB} ${READS}
fi

# 2. Run merqury per assembly (merqury writes to the current directory)
for NAME in flye hifiasm lja; do
    if [ ! -s "${ASM[$NAME]}" ]; then
        echo "WARNING: ${ASM[$NAME]} missing, skipping ${NAME}" >&2
        continue
    fi
    mkdir -p ${OUTDIR}/${NAME}
    cd ${OUTDIR}/${NAME}
    apptainer exec --bind /data ${CONTAINER} \
        ${MERQURY}/merqury.sh ${MERYL_DB} ${ASM[$NAME]} ${NAME}
done
