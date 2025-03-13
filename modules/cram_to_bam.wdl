version 1.0

task cram_to_bam {
    input {
        String SID
        File input_cram
        File reference_fa

        Int disk_space
    }
    
    command <<<
        set -euo pipefail
        samtools view -b -@ 6 -T ~{reference_fa} -o ~{SID}.bam ~{input_cram}
    >>>

    output {
        File bam = "~{SID}.bam"
    }

    runtime {
        docker: "us.gcr.io/broad-dsde-methods/samtoolscloud"
        memory: "32GB"
        disks: "local-disk ~{disk_space} HDD"
        cpu: "7"
    }

    parameter_meta {
        SID: {
            type: "id"
        }
        input_cram: {
            label: "CRAM file to be converted to BAM"
        }
        reference_fa: {
            label: "Reference fasta that original genomic data was aligned to"
        }
    }

    meta {
        author: "Alexander Miller"
    }
}
