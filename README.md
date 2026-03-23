# UNITAS – Universal Tool for Annotation of Small RNAs

**UNITAS** is a comprehensive Perl-based pipeline for the annotation and quantification of small RNAs (sRNAs) from next-generation sequencing (NGS) data. It supports the analysis of miRNAs, piRNAs, siRNAs, tRNA fragments (tRFs), and other ncRNAs across hundreds of species.

## Features

- **Flexible input formats**: FASTQ, FASTA, SAM, and ELAND3 formats (plain or gzipped)
- **3' adapter trimming**: Automatic detection and removal of unknown 3' adapter sequences with configurable parameters
- **Comprehensive annotation** against multiple reference databases:
  - miRBase (mature and hairpin sequences)
  - Ensembl ncRNA collection
  - Ensembl cDNA sequences
  - Genomic tRNA database (gtRNAdb)
  - piRNA cluster database (www.pirnaclusterdb.org)
  - User-provided custom references
- **Advanced analysis features**:
  - Differential expression analysis across sample groups
  - Phased siRNA (phasiRNA/tasiRNA) detection
  - Ping-pong signature analysis for piRNA biogenesis
  - tRNA fragment classification (5' fragments, 3' fragments, tRNA halves, misc-tRFs)
  - Low-complexity sequence filtering (DUST algorithm)
- **Species support**: 300+ species/strains from Ensembl
- **Output formats**:
  - HTML visualizations with interactive charts
  - Tab-delimited annotation tables and matrices
  - Simplified count tables for downstream analysis
  - Fasta files with annotated sequences
- **Performance optimization**: Parallel processing with configurable threading and memory limits
- **Reference management**: Download and cache reference sequences for offline runs

## System Requirements

- **Perl** 5.10 or higher  
- **Internet connection** (for downloading reference sequences from Ensembl and miRBase)
- **C++ compiler** (e.g., g++, only needed if seqmap.exe is not present or needs recompilation)

### Required Perl Modules

The following modules are included in most Perl distributions (core modules):
- `Getopt::Long` – Command-line option parsing
- `File::Path` – Directory creation and manipulation
- `File::Copy` – File copying operations
- `File::Basename` – File path parsing
- `Scalar::Util` – Utility functions for scalar operations
- `Archive::Extract` – Archive extraction (tar.gz, zip, etc.)

Additionally required:
- `LWP::Simple` – HTTP requests
- `LWP::UserAgent` – User agent for HTTP requests
- `LWP::Protocol::https` – HTTPS support

Optional (for advanced features):
- `Statistics::Distributions` – Required for t-test in differential expression analysis

### Installing Missing Modules

If a module is missing, install via CPAN (may require `sudo` on macOS/Linux):

```bash
cpan install LWP::Simple LWP::UserAgent LWP::Protocol::https
```

Or using the Perl invocation directly:

```bash
perl -MCPAN -e 'install LWP::Simple'
```

### External Tools

**SeqMap** – Automatically downloaded and compiled on first use. If compilation fails on your system, you can:
1. Manually download from: https://jhui2014.github.io/seqmap/
2. Compile the executable: `g++ -O3 -m64 -o seqmap.exe match.cpp`
3. Place `seqmap.exe` in the unitas working directory

## Installation

1. **Clone the repository**:
```bash
git clone https://github.com/d-gebert/unitas.git
cd unitas
```

2. **Make the script executable** (optional):
```bash
chmod +x unitas_1.9.2.pl
```

3. **Run the script** (Perl will find it automatically):
```bash
perl unitas_1.9.2.pl -help
```

## Quick Start

### Basic Usage

The minimal command requires only input file and species:

```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens
```

### Trim 3' adapters and annotate

```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens -trim
```

### Process multiple input files in parallel

```bash
perl unitas_1.9.2.pl -i file1.fastq -i file2.fastq -i file3.fastq -s homo_sapiens -threads 4
```

Or process all files in a directory:

```bash
perl unitas_1.9.2.pl -i /path/to/fastq/files/ -s homo_sapiens -threads 4
```

## Options Reference

### Mandatory Options

| Option | Description | Example |
|--------|-------------|---------|
| `-i, -input` | Input file(s) or directory containing input files | `-i sample.fastq` |
| `-s, -species` | Species name (binomial nomenclature with underscore) | `-s homo_sapiens` |

### Input/Output Options

| Option | Description | Default |
|--------|-------------|---------|
| `-trim` | Enable 3' adapter trimming (auto-detect adapter) | OFF |
| `-refseq` | Provide custom reference sequence files (FASTA format) | None |
| `-refdump` | Download reference sequences and quit (for offline mode) | OFF |
| `-latest_ref` | Force download of latest reference sequences | OFF |
| `-dump_prefix` | Prefix for temporary dump folders | `UNITAS` |
| `-output_prefix` | Prefix for output files | `unitas` |
| `-no_html` | Skip HTML output generation | OFF |

### Trimming Options

| Option | Description | Default |
|--------|-------------|---------|
| `-trim_minlength` | Minimum read length after adapter removal (nt) | 10 |
| `-trim_maxlength` | Maximum read length after adapter removal (nt) | 50 |
| `-trim_ignore_5p` | Ignore first n bases when searching for adapter (nt) | 22 |
| `-trim_skip_reads` | Skip first n reads when searching for adapter patterns | 10000 |
| `-trim_check_reads` | Check only n reads for adapter detection | 500000 |
| `-trim_polyA` | Allow polyA tails to be recognized as 3' adapter | OFF |
| `-trim_maxfinalbias` | Maximum allowed 3' nucleotide bias after trimming (0.0-1.0) | 0.8 |

### Annotation Sensitivity Options

| Option | Description | Effect |
|--------|-------------|--------|
| `-quick` | Fast mode (less sensitive) | `-tail 1 -intmod 0 -mismatch 0 -insdel 0` |
| `-slow` | Slow mode (more sensitive) | `-tail 3 -intmod 2 -mismatch 2 -insdel 1` |
| `-tail` | Max 3' non-template nucleotides for miRNA mapping | 2 |
| `-intmod` | Max internal mismatches for miRNA mapping | 1 |
| `-mismatch` | Max mismatches for ncRNA mapping (non-miRNA) | 1 |
| `-insdel` | Max insertions/deletions for ncRNA mapping | 0 |

### Feature-Specific Options

#### tRNA Fragment Classification

| Option | Description | Default |
|--------|-------------|---------|
| `-min_tRNA_half_size` | Minimum length for tRNA-half annotation (nt) | 30 |
| `-max_tRNA_end_dist` | Max distance from tRNA ends for 5'/3' fragment annotation (nt) | 0 |
| `-CC_is_CCA` | Treat CC-3' tRFs as CCA-3' (useful for poly-A tailing libs) | OFF |
| `-noCCAcheck` | Skip CCA-3' addition to mature tRNAs | OFF |

#### Low-Complexity Filtering

| Option | Description | Default |
|--------|-------------|---------|
| `-skip_dust` | Skip low-complexity sequence filtering | OFF |
| `-dust_limit` | Threshold for simple repeat fraction (0.25-1.0) | 0.75 |
| `-dust_max` | Maximum motif size for repeat detection | 5 |
| `-dust_maxN` | Maximum allowed N fraction in sequence (0.0-1.0) | 0.5 |

#### Phased siRNA Detection

| Option | Description | Default |
|--------|-------------|---------|
| `-phasi` | Search for phasiRNAs of specified length; use multiple times | None |
| `-phasi_sw_size` | Sliding window size for phasiRNA detection (must be even) | 1000 |
| `-phasi_p` | Critical p-value for phasiRNA significance | 0.05 |
| `-min_phasi_fraction` | Minimum fraction of phased reads in a window | 0.25 |
| `-min_phasi_loci` | Minimum number of phased loci within a window | 5 |
| `-na_for_phasi` | Only consider unannotated sequences for phasiRNA prediction | OFF |

#### Ping-Pong Signature Analysis

| Option | Description | Effect |
|--------|-------------|---------|
| `-pp` | Analyze 5' overlaps for ping-pong signatures (piRNA biogenesis) | Generates .pp and .ppmatrix files |

#### Species-Specific Mapping

| Option | Description | Default |
|--------|-------------|---------|
| `-species_miR_only` | Only use miRNA sequences from the target species | OFF |

### Skip/Filter Options

| Option | Description | Effect |
|--------|-------------|---------|
| `-skip_mapping` | Skip all mapping (combine with `-trim` for trimming only) | Skips miR, cDNA, ncRNA, piR mapping |
| `-skip_miR` | Skip miRNA annotation | OFF |
| `-skip_cDNA` | Skip cDNA annotation | OFF |
| `-skip_ncRNA` | Skip ncRNA annotation | OFF |
| `-skip_piR` | Skip piRNA annotation | OFF |

### Performance Options

| Option | Description | Default |
|--------|-------------|---------|
| `-threads` | Maximum number of parallel threads (for multiple input files) | 1 |
| `-memory` | Memory limit for SeqMap (GB) – 0 = unlimited | 99999 |
| `-less_memory` | Reduce SeqMap memory usage (slower) | OFF |
| `-even_less_memory` | Further reduce memory usage (slower) | OFF |
| `-keep_temp` | Keep temporary files in dump folder | OFF |

### Differential Expression Analysis

| Option | Description | Default |
|--------|-------------|---------|
| `-diffexpr` | Perform differential expression analysis and quit | OFF |
| `-diffexpr_t` | Use standard t-test instead of SAND test | OFF |
| `-diffexpr_p` | Critical p-value for significance | 0.05 |
| `-diffexpr_acorrection` | Multiple testing correction: 0=none, 1=Bonferroni-Holm, 2=Bonferroni | 1 |
| `-diffexpr_estdev` | Estimated deviation when using single replicate | 0.05 |
| `-diffexpr_nostrays` | Only consider sequences present in all replicates | OFF |
| `-g1` | Assign sample folder to group 1 (use multiple times) | None |
| `-g2` | Assign sample folder to group 2 (use multiple times) | None |
| `-diffexpr_out` | Output file prefix for differential expression results | `unitas.diff-expr` |

### Utility/Informational Options

| Option | Description |
|--------|-------------|
| `-supp_spec` | Print all supported species and quit |
| `-show_options` | Print this options reference and quit |
| `-h, -help` | Print usage information and quit |
| `-silent` | Reduce console output during processing |

## Output Files

UNITAS generates a folder (`UNITAS_YYYYMMDD_HHmmss_input.file_#1`) containing:

### Main Results
- **`unitas.annotation-summary.txt`** – Comprehensive annotation report
- **`unitas.full_annotation_matrix.txt`** – All sequences with annotations
- **`miR-table_[species].txt`** & **`.simplified.txt`** – miRNA count tables
- **`unitas.tRF-table.txt`** & **`.simplified.txt`** – tRNA fragment count tables
- **`unitas.piR-table.txt`** – piRNA count tables
- **`unitas.ncRNA-table.txt`** – Other ncRNA count tables

### Analysis Results (if enabled)
- **`unitas.*.pp`** – Ping-pong signature analysis
- **`unitas.*.ppmatrix`** – Ping-pong overlap matrix
- **`unitas.ping-pong.fas`** – Sequences with ping-pong signatures

### Sequence Files
- **`fasta/`** – FASTA files for each ncRNA class
- **`info/`** – Detailed sequence information files

### Visualizations
- **`unitas.*.html`** – Interactive HTML reports with charts (if not skipped with `-no_html`)

## Supported Species

UNITAS supports **300+ species and strains** from Ensembl, including:

**Common model organisms:**
- Humans (`homo_sapiens`)
- Mouse (`mus_musculus`)
- Rat (`rattus_norvegicus`)
- Zebrafish (`danio_rerio`)
- Fruit fly (*Drosophila* `drosophila_melanogaster`)
- Nematode (*C. elegans* `caenorhabditis_elegans`)
- Yeast (`saccharomyces_cerevisiae`)
- Arabidopsis (`arabidopsis_thaliana`)

**Plant species, fungi, protists, and many more**

To list all supported species:

```bash
perl unitas_1.9.2.pl -supp_spec
```

To use a species not in the database, provide custom reference sequences:

```bash
perl unitas_1.9.2.pl -i sample.fastq -s my_species -refseq custom_refs.fasta
```

## Advanced Examples

### 1. Strict annotation with slow mode
```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens -slow
```

### 2. Trim adapters with custom length constraints
```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens \
  -trim -trim_minlength 18 -trim_maxlength 28
```

### 3. Detect phasiRNAs (21 and 24 nt) from mapped reads
```bash
perl unitas_1.9.2.pl -i sample.sam -s arabidopsis_thaliana \
  -phasi 21 -phasi 24
```

### 4. Differential expression between two conditions
```bash
perl unitas_1.9.2.pl -diffexpr \
  -g1 UNITAS_results_ctrl_1 -g1 UNITAS_results_ctrl_2 \
  -g2 UNITAS_results_treat_1 -g2 UNITAS_results_treat_2 \
  -diffexpr_out condition_comparison
```

### 5. Process fastq with reduced memory footprint
```bash
perl unitas_1.9.2.pl -i large_sample.fastq -s homo_sapiens \
  -even_less_memory -threads 4
```

### 6. Use custom reference sequences alongside Ensembl references
```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens \
  -refseq custom_known_miRs.fasta -refseq viral_sequences.fasta
```

### 7. Offline mode (with pre-downloaded references)
```bash
# Step 1: Download and cache references (one time)
perl unitas_1.9.2.pl -refdump -s homo_sapiens

# Step 2: Run offline (no internet needed)
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens
```

## Input File Formats

UNITAS accepts:
- **FASTA** – Standard sequence format (`.fa`, `.fas`, `.fasta`)
- **FASTQ** – Quality-annotated format (`.fq`, `.fastq`) 
- **SAM** – Sequence alignment format (mapped reads with positions)
- **ELAND3** – Illumina export format
- **Gzipped** versions of any above (`.gz`)

## Troubleshooting

### "Perl module X is not installed"
Install the missing module via CPAN (may require `sudo`):
```bash
perl -MCPAN -e 'install Module::Name'
```

### SeqMap compilation fails
1. Ensure you have a C++ compiler installed (e.g., Xcode command line tools on macOS)
2. On macOS: `xcode-select --install`
3. Pre-compiled SeqMap binaries may be available; check the SeqMap repository

### High memory usage
Use memory-saving options:
```bash
perl unitas_1.9.2.pl -i sample.fastq -s homo_sapiens \
  -even_less_memory -memory 4
```

### Analysis is slow
Enable parallel processing:
```bash
perl unitas_1.9.2.pl -i /path/to/files/ -s homo_sapiens -threads 8
```

## Citation

If you use UNITAS in your research, please cite:

**Gebert D, Hewel C, Rosenkranz D.** UNITAS: the universal tool for annotation of small RNAs. *BMC Genomics*. 2017;18:644.  
DOI: [https://doi.org/10.1186/s12864-017-4031-9](https://doi.org/10.1186/s12864-017-4031-9)

## License

MIT License.

## Contact & Support

- **Author**: Daniel Gebert (University of Cambridge, Department of Genetics)
- **Author**: David Rosenkranz (MVZ Humangenetik der Universitätsmedizin Mainz)
- **Twitter**: [@smallRNA_Mainz](https://twitter.com/smallRNA_Mainz) – Follow for software updates
- **Issues**: Report bugs and feature requests via GitHub Issues

## Version History

- **v1.9.2** (Current) – Latest features and database updates
- **v1.9.1** – Previous stable release
- **See `archived_versions/`** – Older releases for compatibility
