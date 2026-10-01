#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastp
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_fastp_%j.o
#SBATCH --error=/data/users/awolfruiz/error_fastp_%j.e
#SBATCH --partition=pibu_el8

module load fastp/0.23.4-GCC-10.3.0

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

mkdir -p ${WORKDIR}/read_QC/fastp

# Input RNA-seq reads
R1=${WORKDIR}/RNAseq_Sha/ERR754081_1.fastq.gz
R2=${WORKDIR}/RNAseq_Sha/ERR754081_2.fastq.gz

# Output files
OUT_R1=${WORKDIR}/read_QC/fastp/ERR754081_1.trimmed.fastq.gz
OUT_R2=${WORKDIR}/read_QC/fastp/ERR754081_2.trimmed.fastq.gz

fastp \
    --in1 ${R1} \
    --in2 ${R2} \
    --out1 ${OUT_R1} \
    --out2 ${OUT_R2} \
    --html ${WORKDIR}/read_QC/fastp/ERR754081_fastp.html \
    --json ${WORKDIR}/read_QC/fastp/ERR754081_fastp.json \
    --thread 4
