#!/usr/bin/env bash

#SBATCH --cpus-per-task=1
#SBATCH --mem=40G
#SBATCH --time=01:00:00
#SBATCH --job-name=fastqc
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_fastqc_%j.o
#SBATCH --error=/data/users/awolfruiz/error_fastqc_%j.e
#SBATCH --partition=pibu_el8

module load FastQC/0.11.9-Java-11

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

mkdir -p ${WORKDIR}/read_QC/fastqc

fastqc \
    ${WORKDIR}/Rab-R1/ERR11437340.fastq.gz \
    ${WORKDIR}/RNAseq_Sha/ERR754081_1.fastq.gz \
    ${WORKDIR}/RNAseq_Sha/ERR754081_2.fastq.gz \
    --outdir ${WORKDIR}/read_QC/fastqc
