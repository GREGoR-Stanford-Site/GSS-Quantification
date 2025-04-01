version 1.0

task aggregate {
    input {
        Array[String] SID
        Array[File] counts
        File bed

        Int disk_space
    }

    command <<<
        python3 /usr/local/bin/aggregate_counts.py -c ~{sep=" " counts} -s ~{sep=" " SID} -b ~{bed}
    >>>

    output {
        File counts_matrix = "counts_table.tsv"        
    }

    runtime {
        docker: "atex91/aggregate_counts:v2.0"
        memory: "100GB"
        disks: "local-disk ~{disk_space} HDD"
        cpus: "1"
    }

    meta {
        author: "Alexander Miller"
    }
}
