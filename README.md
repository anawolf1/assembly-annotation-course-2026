# Assembly and Annotation Course 2026

## Overview

This repository contains my work for the Assembly and Annotation course, including analysis scripts, quality control, genome assembly, and annotation steps.

The analyses are performed on the IBU cluster using SLURM. Scripts are numbered according to their order of execution to make the workflow reproducible.

## Dataset

### Assigned accession

**Rab-R1**

The whole-genome sequencing data for Rab-R1 consist of PacBio HiFi reads:

```text
ERR11437340.fastq.gz
```

### RNA-seq dataset

I also was provided with an Illumina RNA-seq dataset from the Arabidopsis thaliana accession Sha:

```text
ERR754081_1.fastq.gz
ERR754081_2.fastq.gz
```

The raw sequencing data are provided by the course and are **not stored in this Git repository**. Symbolic links are used to access the course data from the project directory.

## Project structure

```text
assembly-annotation-course-2026/
├── README.md
├── .gitignore
├── scripts/
│   ├── 01_run_fastqc.sh
│   ├── 02_run_fastp.sh
│   ├── 03_run_fastp_pacbio.sh
│   ├── 04_flye_assembly.sh
│   ├── 05_hifiasm_assembly.sh
│   └── 06_lja_assembly.sh
├── read_QC/
│   ├── fastqc/
│   ├── fastp/
│   └── kmer_counting/
├── assemblies/
├── Rab-R1      # course raw data
└── RNAseq_Sha  # course raw data
```

## Reproducibility

Analysis steps are implemented as separate shell scripts and submitted as SLURM jobs on the IBU cluster.

The scripts specify:

* input and output directories
* software modules and versions
* CPU and memory requirements
* SLURM partition
* job names
* output and error files

The cluster partition used for the analyses is:

```text
pibu_el8
```

## Week 1 — Reads and QC

The first week focuses on sequencing reads, quality control, and k-mer analysis.

### 1. Basic read statistics

FastQC is used to assess the quality and characteristics of:

* PacBio HiFi whole-genome reads from Rab-R1
* Illumina RNA-seq reads from Sha

The FastQC module used is:

```text
FastQC/0.11.9-Java-11
```

The analysis is performed by:

```text
scripts/01_run_fastqc.sh
```

### 2. Read filtering and trimming

`fastp` is used to:

* filter and trim the Illumina RNA-seq reads
* assess changes in read quality
* obtain the total number of bases in the PacBio HiFi dataset without filtering

The Illumina RNA-seq analysis is performed by:

```text
scripts/02_run_fastp.sh
```

The PacBio analysis is performed by:

```text
scripts/03_run_fastp_pacbio.sh
```

#### RNA-seq fastp results

Before filtering, each RNA-seq mate contained:

* **22,620,680 reads**
* **2,284,688,680 bases**
* Q20 bases: **88.25%**
* Q30 bases: **76.19%**

After filtering, each mate contained:

* **20,352,421 reads**
* **2,043,758,461 bases**
* Q20 bases: **94.60%**
* Q30 bases: **86.32%**

Across both mates, fastp reported:

* **40,704,842 reads passed the filters**
* **4,536,276 reads failed due to low quality**
* **242 reads failed due to too many Ns**
* **0 reads failed due to being too short**
* **2,131,136 reads had adapter trimming**
* **24,329,968 bases were trimmed due to adapters**
* Duplication rate: **6.61%**
* Insert size peak: **136 bp**

The filtered RNA-seq reads are written to:

```text
read_QC/fastp/
```

The fastp HTML and JSON reports are also stored in this directory.

### 3. Expected PacBio coverage

The expected sequencing coverage will be estimated using:

```text
coverage = total sequenced bases / expected genome size
```

The Arabidopsis thaliana genome is approximately 135 Mb.

The total number of PacBio bases will be obtained from the fastp analysis without filtering.

### 4. K-mer counting

K-mers will be counted from the PacBio HiFi reads using Jellyfish.

The workflow will:

1. Count k-mers.
2. Use canonical k-mers.
3. Generate a k-mer histogram.
4. Analyze the histogram using GenomeScope 2.0.

The Jellyfish analysis will be documented in a separate script once the k-mer counting step is completed.

## Genome assembly

Genome assemblies will be generated using several assemblers and compared as part of the course analysis.

The planned assembly tools are:

* Flye
* hifiasm
* LJA

The corresponding scripts are:

```text
scripts/04_flye_assembly.sh
scripts/05_hifiasm_assembly.sh
scripts/06_lja_assembly.sh
```

Assembly results will be evaluated using assembly statistics and other quality measures as required by the course.

## Week 1 results

| Metric                            | Result              |
| --------------------------------- | ------------------- |
| PacBio read length                | TBD                 |
| Illumina read length              | TBD                 |
| RNA-seq reads before filtering    | 22,620,680 per mate |
| RNA-seq reads after filtering     | 20,352,421 per mate |
| RNA-seq reads filtered            | 4,536,518 combined  |
| RNA-seq Q20 before filtering      | 88.25%              |
| RNA-seq Q20 after filtering       | 94.60%              |
| RNA-seq Q30 before filtering      | 76.19%              |
| RNA-seq Q30 after filtering       | 86.32%              |
| PacBio total bases                | TBD                 |
| Expected genome size              | ~135 Mb             |
| Expected PacBio coverage          | TBD                 |
| GenomeScope estimated genome size | TBD                 |
| GenomeScope heterozygosity        | TBD                 |
| GenomeScope coverage              | TBD                 |

## Questions

### Read quality

* What are the read lengths of the different datasets?
* Are the datasets of good quality?
* How many RNA-seq reads were trimmed or filtered?
* Did the quality improve after filtering?

### PacBio coverage

The expected PacBio coverage will be calculated from the total number of sequenced bases and the expected Arabidopsis thaliana genome size.

### GenomeScope

The k-mer histogram will be analyzed with GenomeScope 2.0 to estimate:

* genome size
* heterozygosity
* sequencing coverage
* repeat content

The estimates will be compared with the expected properties of the Arabidopsis thaliana genome and the observed sequencing data.

### Canonical k-mers

Canonical k-mers treat a k-mer and its reverse complement as the same k-mer. This reduces redundant counting of the two possible orientations of the same sequence.

## References

Lian, Q. et al. (2024). A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range. *Nature Genetics*, 56, 982–991.

Jiao, W. B. & Schneeberger, K. (2020). Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics. *Nature Communications*, 11.

GenomeScope 2.0: http://genomescope.org/genomescope2.0/

