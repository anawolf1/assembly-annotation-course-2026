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
INPUT=/data/courses/assembly-annotation-course/raw_data/Rab-R1/ERR11437340.fastq.gz

mkdir -p ${WORKDIR}/assemblies/hifiasm

apptainer exec \
    --bind /data \
    /containers/apptainer/hifiasm_0.25.0.sif \
    hifiasm \
    -o ${WORKDIR}/assemblies/hifiasm/Rab-R1 \
    -t ${SLURM_CPUS_PER_TASK} \
    ${INPUT}

# Convert primary contigs from GFA to FASTA
awk '/^S/{print ">"$2;print $3}' \
    ${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.gfa \
    > ${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.fa
