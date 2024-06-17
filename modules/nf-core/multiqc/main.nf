process MULTIQC {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container mod_container

    input:
    path  multiqc_files, stageAs: "?/*"
    path(multiqc_config)
    path(extra_multiqc_config)
    path(multiqc_logo)

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data
    path "*_plots"             , optional:true, emit: plots
    path "versions.yml"        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def config = multiqc_config ? "--config $multiqc_config" : ''
    def extra_config = extra_multiqc_config ? "--config $extra_multiqc_config" : ''
    def logo = multiqc_logo ? /--cl-config 'custom_logo: "${multiqc_logo}"'/ : ''
    """
    multiqc \\
        --force \\
        $args \\
        $config \\
        $extra_config \\
        $logo \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """

    stub:
    """
    mkdir multiqc_data
    touch multiqc_plots
    touch multiqc_report.html

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}

def mod_container = switch([workflow.containerEngine, task.arch]) {
    case {it[0] == 'singularity' && it[1] == 'linux/arm64'} -> 'oras://community.wave.seqera.io/library/multiqc:1.22.1--af20ae77441fdc43'
    case {it[0] == 'singularity'} -> 'oras://community.wave.seqera.io/library/multiqc:1.22.1--ac0a91c1ae1c160c'
    case {it[1] == 'linux/arm64'} -> 'community.wave.seqera.io/library/multiqc:1.22.1--22ddc3b95632778f'
    case default -> 'community.wave.seqera.io/library/multiqc:1.22.1--4886de6095538010'
}
