#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --job-name=fastp_pacbio
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_fastp_pacbio_%j.o
#SBATCH --error=/data/users/awolfruiz/error_fastp_pacbio_%j.e
#SBATCH --partition=pibu_el8

module load fastp/0.23.4-GCC-10.3.0

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

mkdir -p ${WORKDIR}/read_QC/fastp

INPUT=${WORKDIR}/Rab-R1/ERR11437340.fastq.gz

fastp \
    --in1 ${INPUT} \
    --out1 /dev/null \
    --disable_adapter_trimming \
    --disable_quality_filtering \
    --disable_length_filtering \
    --html ${WORKDIR}/read_QC/fastp/ERR11437340_fastp.html \
    --json ${WORKDIR}/read_QC/fastp/ERR11437340_fastp.json \
    --thread 4
