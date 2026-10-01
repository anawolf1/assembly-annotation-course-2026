#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=lja_Rab-R1
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_lja_%j.o
#SBATCH --error=/data/users/awolfruiz/error_lja_%j.e
#SBATCH --partition=pibu_el8

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026

mkdir -p ${WORKDIR}/assemblies/lja

apptainer exec \
    /containers/apptainer/lja-0.2.sif \
    lja \
    --reads ${WORKDIR}/Rab-R1/ERR11437340.fastq.gz \
    --output-dir ${WORKDIR}/assemblies/lja \
    --threads ${SLURM_CPUS_PER_TASK}
