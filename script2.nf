// Download parameters
params.linkfile="/home/biouser/genome_assembly/links.txt"
params.fastqdir="/home/biouser/genome_assembly/fastq"

// Location of reads
params.read1="/home/biouser/genome_assembly/fastq/ERR3335404_1.fastq.gz"
params.read2="/home/biouser/genome_assembly/fastq/ERR3335404_2.fastq.gz"

// Spades output directory
params.SPADES_OUTPUT="/home/biouser/genome_assembly/SPADES_OUTPUT"

process download {

// Define the publishing directory which the files will be copied to
publishDir("${params.fastqdir}", mode: "copy")

// Define input with placeholder
input:
 path linkfile

// Emits everything to the placeholder output file
output:
 path "*" , emit: outputfile

// Get contents of the linkfile, pipe to wget and download with two processes running in parallel
script:
"""
cat $linkfile | xargs -i -P 2 wget '{}'
"""

}


process assemble {

publishDir("${params.SPADES_OUTPUT}" , mode: 'copy')

input:
 path read1
 path read2

output:
 path "*" , emit: spades_output

// Remove read1 suffix, cut it by _ and keep first half. Pipe this as the output directory to the spades command
script:
"""
echo ${read1.simpleName} | cut -d'_' -f1 | xargs -i spades.py --careful -1 $read1 -2 $read2 -o '{}'
"""

}

workflow {

// Define a channel with the linkfile input
link_ch=Channel.fromPath(params.linkfile)

// Call the download process with the links channel
download(link_ch)
// View the location of the output generated under outputfile
download.out.outputfile.view()

read1_ch=Channel.fromPath(params.read1)
read2_ch=Channel.fromPath(params.read2)

assemble(read1_ch, read2_ch)
assemble.out.spades_output.view()

}
