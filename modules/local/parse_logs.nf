// Import generic module functions
process PARSE_LOGS {
    tag "logs"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::pandas=1.1.5" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:1.1.5' :
        'quay.io/biocontainers/pandas:1.1.5' }"

    input:
    path('filter_by_sequence_quality/*') //PRESTO_FILTERSEQ logs
    path('mask_primers/*') //PRESTO_MASKPRIMERS logs
    path('pair_sequences/*') //PRESTO_PAIRSEQ logs
    path('cluster_sets/*') //PRESTO_CLUTSERSETS logs
    path('build_consensus/*') //PRESTO_BUILDCONSENSUS logs
    path('repair_mates/*') //PRESTO_POSTCONSESUS_PAIRSEQ logs
    path('assemble_pairs/*') //PRESTO_ASSEMBLEPAIRS logs
    path('deduplicates/*') //PRESTO_COLLAPSESEQ logs
    path('filter_representative_2/*') //PRESTO_SPLITSEQ logs
    path('igblast/*') //CHANGEO_PARSEDB_SELECT logs
    path('define_clones/*') //CHANGEO_DEFINECLONES logs
    path('create_germlines/*') //CHANGEO_CREATEGERMLINES logs
    path('metadata.tsv') //METADATA

    output:
    path "Table_sequences_process.tsv", emit: logs

    script:
    if (params.umi_length == 0) {
        """
        log_parsing_no-umi.py
        """
    } else {
        def clustersets = params.cluster_sets? "--cluster_sets":""
        """
        log_parsing.py $clustersets
        """
    }
}
