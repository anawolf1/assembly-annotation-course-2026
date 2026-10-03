#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=trinity_Sha
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_trinity_%j.o
#SBATCH --error=/data/users/awolfruiz/error_trinity_%j.e
#SBATCH --partition=pibu_el8

module load Trinity/2.15.1-foss-2021a

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
R1=${WORKDIR}/read_QC/fastp/ERR754081_1.trimmed.fastq.gz
R2=${WORKDIR}/read_QC/fastp/ERR754081_2.trimmed.fastq.gz

mkdir -p ${WORKDIR}/assemblies

Trinity \
    --seqType fq \
    --left ${R1} \
    --right ${R2} \
    --CPU ${SLURM_CPUS_PER_TASK} \
    --max_memory 60G \
    --output ${WORKDIR}/assemblies/trinity
