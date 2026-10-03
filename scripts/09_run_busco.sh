#!/usr/bin/env bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --array=0-3
#SBATCH --job-name=busco
#SBATCH --mail-user=ana.wolfruiz@students.unibe.ch
#SBATCH --mail-type=END,FAIL
#SBATCH --output=/data/users/awolfruiz/output_busco_%A_%a.o
#SBATCH --error=/data/users/awolfruiz/error_busco_%A_%a.e
#SBATCH --partition=pibu_el8

set -euo pipefail

WORKDIR=/data/users/awolfruiz/assembly-annotation-course-2026
OUTDIR=${WORKDIR}/assembly_evaluation/busco
CONTAINER=/containers/apptainer/busco_5.7.1.sif
LINEAGE=brassicales_odb10

# Trinity 2.15 writes the final FASTA next to the output directory
TRINITY_FA=${WORKDIR}/assemblies/trinity.Trinity.fasta
[ -f "${TRINITY_FA}" ] || TRINITY_FA=${WORKDIR}/assemblies/trinity/Trinity.fasta

NAMES=(flye hifiasm lja trinity)
FILES=(
    ${WORKDIR}/assemblies/flye/assembly.fasta
    ${WORKDIR}/assemblies/hifiasm/Rab-R1.bp.p_ctg.fa
    ${WORKDIR}/assemblies/lja/assembly.fasta
    ${TRINITY_FA}
)
MODES=(genome genome genome transcriptome)

NAME=${NAMES[$SLURM_ARRAY_TASK_ID]}
INPUT=${FILES[$SLURM_ARRAY_TASK_ID]}
MODE=${MODES[$SLURM_ARRAY_TASK_ID]}

if [ ! -s "${INPUT}" ]; then
    echo "ERROR: ${INPUT} missing or empty" >&2
    exit 1
fi

mkdir -p ${OUTDIR}
cd ${OUTDIR}

apptainer exec --bind /data ${CONTAINER} \
    busco \
    -i ${INPUT} \
    -m ${MODE} \
    -l ${LINEAGE} \
    -c ${SLURM_CPUS_PER_TASK} \
    -o ${NAME} \
    --out_path ${OUTDIR} \
    --download_path ${OUTDIR}/busco_downloads_${NAME} \
    -f
