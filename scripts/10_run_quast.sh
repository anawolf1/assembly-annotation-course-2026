#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=quast
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_quast_%j.o
#SBATCH --error=/data/users/awolfruiz/error_quast_%j.e
#SBATCH --partition=pibu_el8

set -euo pipefail

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
OUTDIR=${WORKDIR}/assembly_evaluation/quast
CONTAINER=/containers/apptainer/quast_5.2.0.sif

REF=/data/courses/assembly-annotation-course/references/YOUR_GENOME.fa
GFF=/data/courses/assembly-annotation-course/references/YOUR_ANNOTATION.gff

FLYE=${WORKDIR}/assemblies/flye/assembly.fasta
HIFIASM=${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.fa
LJA=${WORKDIR}/assemblies/lja/assembly.fasta

for f in ${FLYE} ${HIFIASM} ${LJA} ${REF} ${GFF}; do
    [ -s "$f" ] || { echo "ERROR: $f missing or empty" >&2; exit 1; }
done

mkdir -p ${OUTDIR}

# Without reference
apptainer exec --bind /data ${CONTAINER} \
    quast.py ${FLYE} ${HIFIASM} ${LJA} \
    --labels flye,hifiasm,lja \
    --eukaryote \
    --est-ref-size 135000000 \
    --threads ${SLURM_CPUS_PER_TASK} \
    -o ${OUTDIR}/no_reference

# With reference
apptainer exec --bind /data ${CONTAINER} \
    quast.py ${FLYE} ${HIFIASM} ${LJA} \
    --labels flye,hifiasm,lja \
    --eukaryote \
    -r ${REF} \
    --features gene:${GFF} \
    --no-sv \
    --threads ${SLURM_CPUS_PER_TASK} \
    -o ${OUTDIR}/with_reference
