#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=hifiasm_Rab-R1
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_hifiasm_%j.o
#SBATCH --error=/data/users/awolfruiz/error_hifiasm_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

mkdir -p ${WORKDIR}/assemblies/hifiasm

apptainer exec \
    /containers/apptainer/hifiasm_0.25.0.sif \
    hifiasm \
    -o ${WORKDIR}/assemblies/hifiasm/Rab-R1 \
    -t ${SLURM_CPUS_PER_TASK} \
    ${WORKDIR}/Rab-R1/ERR11437340.fastq.gz
