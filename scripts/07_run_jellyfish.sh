#!/usr/bin/env bash

#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --time=04:00:00
#SBATCH --job-name=jellyfish_Rab
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_jellyfish_%j.o
#SBATCH --error=/data/users/awolfruiz/error_jellyfish_%j.e
#SBATCH --partition=pibu_el8

module load Jellyfish/2.3.0-GCC-10.3.0

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

INPUT=${WORKDIR}/Rab-R1/ERR11437340.fastq.gz
OUTDIR=${WORKDIR}/read_QC/kmer_counting

mkdir -p ${OUTDIR}

jellyfish count \
    -C \
    -m 21 \
    -s 5G \
    -t 4 \
    -o ${OUTDIR}/ERR11437340.k21.jf \
    <(zcat ${INPUT})

jellyfish histo \
    -t 4 \
    ${OUTDIR}/ERR11437340.k21.jf \
    > ${OUTDIR}/ERR11437340.k21.histo
