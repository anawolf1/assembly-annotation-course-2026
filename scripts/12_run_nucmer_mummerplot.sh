#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=nucmer
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_nucmer_%j.o
#SBATCH --error=/data/users/awolfruiz/error_nucmer_%j.e
#SBATCH --partition=pibu_el8

set -uo pipefail

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
OUTDIR=${WORKDIR}/genome_comparison/nucmer
CONTAINER=/containers/apptainer/mummer4_gnuplot.sif

REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

declare -A ASM=(
    [flye]=${WORKDIR}/assemblies/flye/assembly.fasta
    [hifiasm]=${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.fa
    [lja]=${WORKDIR}/assemblies/lja/assembly.fasta
)

mkdir -p ${OUTDIR}
cd ${OUTDIR}

# Usage: compare <ref_name> <ref_fasta> <query_name> <query_fasta>
compare() {
    local PREFIX=${OUTDIR}/${3}_vs_${1}
    apptainer exec --bind /data ${CONTAINER} \
        nucmer \
        --prefix=${PREFIX} \
        --breaklen 1000 \
        --mincluster 1000 \
        --threads ${SLURM_CPUS_PER_TASK} \
        ${2} ${4}
    apptainer exec --bind /data ${CONTAINER} \
        mummerplot \
        -R ${2} -Q ${4} \
        --filter -t png --large --layout --fat \
        -p ${PREFIX} \
        ${PREFIX}.delta
}

# Each assembly vs reference
for NAME in flye hifiasm lja; do
    compare reference ${REF} ${NAME} ${ASM[$NAME]}
done

# Assemblies vs each other
compare flye    ${ASM[flye]}    hifiasm ${ASM[hifiasm]}
compare flye    ${ASM[flye]}    lja     ${ASM[lja]}
compare hifiasm ${ASM[hifiasm]} lja     ${ASM[lja]}
