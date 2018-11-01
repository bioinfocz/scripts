#!/usr/bin/env nextflow

/*
Download FASTQ from SRA.

How to download sample sheet:
01. From experiment GEO page (e.g. https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE92332),
    navigate to SRA.
02. In SRA, navigate to RunSelector.
03. In RunSelector, download one of:
    a. RunInfo Table - TSV format.
       Change 'params.input_format' to 'tsv'.
    b. Accession List - one line, one run ID.
       Change 'params.input_format' to 'txt'.

Note: for custom CSV format, use params.input_format = 'tsv' and
change 'params.field_sep' to used field separator. You can also change name
of column in which are SRR IDs, using 'params.sra_col'.

How to print help for fastq-dump and parallel-fastq-dump:
$ nextflow run download_sra.nf --print_help=true

How to add options to fastq-dump and parallel-fastq-dump:
$ nextflow run download_sra.nf --options="--threads 8 --gzip"
*/

p = params

p.sample_file = file('data/SraRunTable_single.tsv')
p.data_out_dir = file('data/SRA', type: 'dir')
p.input_format = 'tsv'
p.field_sep = '\t'
p.sra_col = 'Run'
p.options = '--split-files --gzip'
p.print_help = false

if (!p.print_help) {
    assert p.input_format in ['tsv', 'txt'] : "invalid p.input_format"

    if (p.input_format == 'txt') {
        samples = Channel
                    .fromPath(p.sample_file)
                    .splitText()
                    .map({it.trim()})
    } else {
    samples = Channel
                .fromPath(p.sample_file)
                .splitCsv(sep: p.field_sep, header: true)
                .map({it[p.sra_col]})
    }

    assert samples.length() > 0 : "zero samples to be downloaded"
} else {
    samples = 1
}

process download_data {
    conda 'bioconda::parallel-fastq-dump'
    publishDir p.data_out_dir, mode: 'copy'

    input:
        each srx from samples
        val data_out_dir from p.data_out_dir
        val options from p.options

    output:
        val srx into download_info
        file '*.fastq.gz'
        stdout into fastq_dump_echo

    when:
        !p.print_help

    """
    parallel-fastq-dump -s $srx $options
    """
}

process print_help {
    conda 'bioconda::parallel-fastq-dump'

    input:
        val app from Channel.from('parallel-fastq-dump', 'fastq-dump')

    output:
        stdout into print_help_stdout

    when:
        p.print_help

    """
    echo "$app info:"
    $app --help
    """
}

download_info.subscribe({println "Downloaded: $it"})
fastq_dump_echo.subscribe({println "fastq-dump:\n$it"})
print_help_stdout.subscribe({println it})
