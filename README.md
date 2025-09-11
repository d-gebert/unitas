# UNITAS

**UNITAS** (the universal tool for annotation of small RNAs)  
A Perl-based pipeline for the annotation and quantification of small RNAs, such as miRNAs, piRNAs, siRNAs, and tRNA fragments, from next-generation sequencing (NGS) data.

## Features

- Automatic preprocessing of input FASTQ/FASTA files
- Adapter trimming and quality filtering
- Annotation of reads against multiple reference databases:
  - miRBase (miRNAs)
  - tRNA and rRNA databases
  - piRNA cluster databases
  - Other ncRNA sources
- Output of comprehensive annotation reports
- Generation of summary statistics and plots
- Configurable reference databases (human and non-human)

## Requirements

- Perl 5.10 or higher  
- Standard Perl modules (already included in most systems)  
  - `Archive::Extract`
  - `Getopt::Long`
  - `File::Copy`
  - `File::Basename`
  - `File::Path`
  - `LWP::Simple`
  - `LWP::UserAgent`
  - `Scalar::Util`
- External tools:
  - `SeqMap` (for sequence alignment)

Install missing Perl modules via CPAN:

```bash
cpan install Archive::Extract Getopt::Long File::Path LWP::Simple
````

## Installation

Clone the repository:

```bash
git clone https://github.com/d-gebert/UNITAS.git
cd UNITAS
```

Make the script executable:

```bash
chmod +x unitas_1.9.1.pl
```

## Usage

Basic command:

```bash
perl unitas_1.9.1.pl -i input.fastq -s species -o output_dir
```

### Common options

* `-i` : Input file (FASTA/FASTQ, plain or gzipped)
* `-s` : Species identifier (e.g., `homo_sapiens` for human, `mus_musculus` for mouse)
* `-trim ?` : Enable adapter trimming (unknown adapter sequence)

For a full list of options, run:

```bash
perl unitas_1.9.1.pl -h
```

## Example

```bash
perl unitas_1.9.1.pl \
  -i sample.fastq \
  -s homo_sapiens \
  -trim ?
```

This will process `sample.fastq`, annotate reads against human reference databases.

## Citation

If you use UNITAS in your research, please cite:

**Gebert D, et al.** UNITAS: a universal tool for annotation of small RNAs. *BMC Bioinformatics*. 2017;18:401.
[https://doi.org/10.1186/s12864-017-4031-9](https://doi.org/10.1186/s12864-017-4031-9)

## License

MIT License.

```

Do you want me to also add a **"Quick Start" example with typical pipeline output files** (e.g. `*_summary.txt`, `*_annotation.txt`, plots), so that new users immediately see what to expect?
```
