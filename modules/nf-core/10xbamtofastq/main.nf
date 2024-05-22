process 10XBAMTOFASTQ {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/10x_bamtofastq:1.4.1--hdbdd923_2':
        'biocontainers/10x_bamtofastq:1.4.1--hdbdd923_2' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: fastq
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def test = args ==~ /-format (bed|fasta|fastq|json|pileup|sam|yaml)/
    if ( test == false ) error "-format option must be provided in args. Possible values: bed fasta fastq json pileup sam yaml"
    m = args =~ /-format ([a-z]+)/
    ext = m[0][1]

    """

    bamtofastq \\
        $args \\
        $bam
        $path

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        10xbamtofastq: \$(bamtofastq --version |& sed '1!d ; s/bamtofastq //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        10xbamtofastq: \$(bamtofastq --version |& sed '1!d ; s/bamtofastq //')
    END_VERSIONS

    """
}



