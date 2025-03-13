version 1.0

task RNASeQC { 
    input {
        String SID
        File input_bam
        File gtf_file

        Int disk_space
    }

    command <<<
        set -euo pipefail
        
        mkdir -p counts_output

        rnaseqc ~{gtf_file} ~{input_bam} counts_output --sample=~{SID} --mapping-quality=30
    >>>

    output {
        File gene_counts = "counts_output/~{SID}.gene_reads.gct"
    }

    runtime {
        docker: "gcr.io/broad-cga-aarong-gtex/rnaseqc:latest"
        memory: "40GB"
        disks: "local-disk ~{disk_space} HDD"
        cpu: "1"
    }

    parameter_meta {
        SID: {
            type: "id"
        }
        input_bam: {
            label: "Input BAM File"
        }
        gtf_file: {
            label: "GTF-Format Annotation File"
        }
    }

    meta {
        author: "Alexander Miller"
    }
}
