version 1.0

task aggregate {
    input {
        Array[String] SID
        Array[File] counts
        File bed

        Int disk_space
    }

    command <<<
        FILES=~{sep=" " counts}
        SIDs=~{sep=" " SID}
        python3 ../utils/aggregate_counts.py -c ${FILES} -s ${SIDs} -b ~{bed}
    >>>

    output {
        File counts_matrix = "counts_table.tsv"        
    }

    runtime {
        docker: "quay.io/biocontainers/pandas:0.23.4--py36hf8a1672_0"
        memory: "100GB"
        disks: "local-disk ~{disk_space} HDD"
        cpus: "1"
    }

    meta {
        author: "Alexander Miller"
    }
}
