# scripts
Some of our scripts which could be useful.

## [nextflow](https://www.nextflow.io/)
### [download_data_sra.nf](nextflow/download_data_sra.nf)
- Downloads FASTQ from [SRA](https://www.ncbi.nlm.nih.gov/sra).
- Input: TSV (or any matrix-like file) or TXT (one line, one accession ID).
- See file header for more info and options.
- Uses [parallel-fastq-dump](https://github.com/rvalieris/parallel-fastq-dump) (parallel wrapper for [fastq-dump](https://ncbi.github.io/sra-tools/fastq-dump.html), a part of [NCBI SRA Toolkit](https://github.com/ncbi/sra-tools)).
- Possible enhancement: [fasterq-dump](https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump)
