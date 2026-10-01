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
│   ├── 06_lja_assembly.sh
│   └── 07_run_jellyfish.sh
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

FastQC was used to assess the quality and characteristics of:

* PacBio HiFi whole-genome reads from Rab-R1
* Illumina RNA-seq reads from Sha

The FastQC module used is:

```text
FastQC/0.11.9-Java-11
```

The analysis was performed by:

```text
scripts/01_run_fastqc.sh
```

#### FastQC results

| Dataset                  | Total reads |  Read length |  GC |
| ------------------------ | ----------: | -----------: | --: |
| PacBio `ERR11437340`     |     556,708 | 56–39,423 bp | 37% |
| RNA-seq R1 `ERR754081_1` |  22,620,680 |       101 bp | 46% |
| RNA-seq R2 `ERR754081_2` |  22,620,680 |       101 bp | 46% |

The FastQC **Basic Statistics** module passed for all three datasets.

The PacBio reads have a broad read-length distribution, as expected for long-read sequencing, whereas the RNA-seq reads are uniformly 101 bp.

### 2. Read filtering and trimming

`fastp` was used to:

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

#### PacBio fastp results

The PacBio HiFi reads were processed with `fastp` without adapter trimming, quality filtering, or length filtering. The output reads were discarded to `/dev/null` because the purpose of this step was to obtain sequencing statistics rather than produce a filtered FASTQ file.

Results:

* **556,708 reads**
* **8,455,889,868 total bases (~8.46 Gb)**
* Q20 bases: **8,334,149,991 (98.56%)**
* Q30 bases: **8,170,018,339 (96.62%)**

### 3. Expected PacBio coverage

The expected sequencing coverage was estimated using:

```text
coverage = total sequenced bases / expected genome size
```

Using an approximate *Arabidopsis thaliana* genome size of 135 Mb:

```text
8,455,889,868 / 135,000,000 ≈ 62.6×
```

Therefore, the expected PacBio sequencing coverage is approximately **62.6×**.

### 4. K-mer counting

K-mers were counted from the PacBio HiFi reads using Jellyfish.

The Jellyfish version available on the cluster is:

```text
Jellyfish/2.3.0-GCC-10.3.0
```

The analysis was performed by:

```text
scripts/07_run_jellyfish.sh
```

The workflow:

1. Counted k-mers using a k-mer size of 21.
2. Used canonical k-mers with the `-C` option.
3. Generated a k-mer histogram.
4. Prepared the histogram for GenomeScope 2.0 analysis.

The Jellyfish output files are:

```text
read_QC/kmer_counting/ERR11437340.k21.jf
read_QC/kmer_counting/ERR11437340.k21.histo
```

The main k-mer histogram peak occurs at approximately **40× k-mer multiplicity**.

The weighted mean k-mer multiplicity calculated from the histogram is approximately **61.57×**.

The 40× value represents the main observed peak in the k-mer histogram and should not be confused with the GenomeScope mean k-mer coverage estimate.

## GenomeScope 2.0

The k-mer histogram was analyzed using GenomeScope 2.0 with:

* **k-mer size:** 21
* **Ploidy:** 2

GenomeScope estimated:

| Metric                  |    Result |
| ----------------------- | --------: |
| Estimated genome size   | ~144.6 Mb |
| Unique sequence content |     72.8% |
| Heterozygosity          |     0.11% |
| Mean k-mer coverage     |     20.4× |
| Sequencing error rate   |    0.174% |
| Duplication rate        |     0.176 |

The estimated genome size of approximately **144.6 Mb** is somewhat larger than the approximate **135 Mb** genome size expected for *Arabidopsis thaliana*.

The estimated heterozygosity of **0.11%** indicates a low level of heterozygosity. This is consistent with the small heterozygous shoulder observed around **20×** in the k-mer profile.

The main observed k-mer peak is around **40×**, while GenomeScope reports a mean k-mer coverage of **20.4×**. These values describe different aspects of the k-mer distribution and should not be treated as interchangeable.

The GenomeScope k-mer profile is shown below:

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

| Metric                            | Result                      |
| --------------------------------- | --------------------------- |
| PacBio read length                | 56–39,423 bp                |
| Illumina read length              | 101 bp                      |
| RNA-seq reads before filtering    | 22,620,680 per mate         |
| RNA-seq reads after filtering     | 20,352,421 per mate         |
| RNA-seq reads filtered            | 4,536,518 combined          |
| RNA-seq Q20 before filtering      | 88.25%                      |
| RNA-seq Q20 after filtering       | 94.60%                      |
| RNA-seq Q30 before filtering      | 76.19%                      |
| RNA-seq Q30 after filtering       | 86.32%                      |
| PacBio total bases                | 8,455,889,868 bp (~8.46 Gb) |
| PacBio Q20                        | 98.56%                      |
| PacBio Q30                        | 96.62%                      |
| Expected genome size              | ~135 Mb                     |
| Expected PacBio coverage          | ~62.6×                      |
| Main k-mer peak (k=21)            | ~40×                        |
| Weighted mean k-mer multiplicity  | 61.57×                      |
| GenomeScope estimated genome size | ~144.6 Mb                   |
| GenomeScope heterozygosity        | 0.11%                       |
| GenomeScope mean k-mer coverage   | 20.4×                       |

## Questions

### Read quality

* What are the read lengths of the different datasets?
* Are the datasets of good quality?
* How many RNA-seq reads were trimmed or filtered?
* Did the quality improve after filtering?

The FastQC Basic Statistics module passed for all three input datasets. For the RNA-seq data, Q20 increased from 88.25% to 94.60% and Q30 increased from 76.19% to 86.32% after filtering, indicating an improvement in the quality of the retained reads.

Across both RNA-seq mates, **4,536,518 reads failed filtering**, consisting of 4,536,276 reads failing due to low quality and 242 reads failing due to too many Ns.

Adapter trimming was reported separately by fastp: **2,131,136 reads** had adapter trimming and **24,329,968 adapter bases** were removed.

### PacBio coverage

The expected PacBio coverage was calculated from the total number of sequenced bases and the expected *Arabidopsis thaliana* genome size.

The estimated coverage is approximately **62.6×**.

### GenomeScope

The k-mer histogram was analyzed with GenomeScope 2.0 using a k-mer size of 21 and a diploid model.

GenomeScope estimated a genome size of approximately **144.6 Mb**, compared with the approximate expected *Arabidopsis thaliana* genome size of **135 Mb**.

The estimated heterozygosity was **0.11%**, and the mean k-mer coverage estimated by GenomeScope was **20.4×**.

The main observed k-mer histogram peak was approximately **40×**.

### Canonical k-mers

Canonical k-mers treat a k-mer and its reverse complement as the same k-mer. This reduces redundant counting of the two possible orientations of the same sequence.

The Jellyfish k-mer counting step used the `-C` option to count canonical k-mers.

## References

Lian, Q. et al. (2024). A pan-genome of 69 *Arabidopsis thaliana* accessions reveals a conserved genome structure throughout the global species range. *Nature Genetics*, 56, 982–991.

Jiao, W. B. & Schneeberger, K. (2020). Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics. *Nature Communications*, 11.

GenomeScope 2.0.


GenomeScope 2.0.

