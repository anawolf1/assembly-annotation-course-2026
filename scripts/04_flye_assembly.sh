#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=flye_Rab-R1
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_flye_%j.o
#SBATCH --error=/data/users/awolfruiz/error_flye_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
INPUT=/data/courses/assembly-annotation-course/raw_data/Rab-R1/ERR11437340.fastq.gz

mkdir -p ${WORKDIR}/assemblies/flye

apptainer exec \
    /containers/apptainer/flye_2.9.5.sif \
    flye \
    --pacbio-hifi ${INPUT} \
    --out-dir ${WORKDIR}/assemblies/flye \
    --genome-size 135m \
    --threads ${SLURM_CPUS_PER_TASK}
