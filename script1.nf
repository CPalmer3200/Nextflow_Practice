params.ref="/home/biouser/nextflow/ref/Agy99.fasta"
params.index_dir="/home/biouser/nextflow/index_dir"

process index {

publishDir("${params.index_dir}", mode: 'copy')

input:
 path genome

output:
 path "${genome}.bwt", emit: ref_genome

script:
"""
bwa index ${genome}


"""

}

// Link the input file to the defined process
workflow {

ref_ch=Channel.fromPath(params.ref)

index(ref_ch)
index.out.ref_genome.view()

}