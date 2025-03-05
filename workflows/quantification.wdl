version 1.0

import "../modules/rnaseqc.wdl" as rnaseqc
import "../modules/aggregate_counts.wdl" as aggregate
import "../modules/intersect_gtf.wdl" as intersect_gtf

workflow quantification {
    meta {
        task_labels: {
            rnaseqc: {
                task_name: "RNASeQC",
                description: "Quantifications gene expression with RNASeQC-2"
            },
            aggregate: {
                task_name: "aggregate",
                description: "Aggregate RNASeQC-2 counts into a table"
            }
        }
    }

    input {
        #All
        Array[String] SID
        Array[File] GTF
        
        #RNASeQC input
        Array[File] BAM
        Int rnaseqc_disk

        #aggregate
        Int aggregate_disk

        #intersect_gtf
        Int intersect_disk
    }

    call intersect_gtf {
        input:
            gtf_files=GTF
            disk_space=intersect_disk
    }

    scatter (i in range(length(BAM))) {
        call rnaseqc {
            input:
                SID=SID[i],
                input_bam=BAM[i],
                gtf_file=GTF[i],
                disk_space=rnaseqc_disk
        }
    }

    call aggregate {
        input:
            SID=SID,
            counts=rnaseqc.gene_counts,
            disk_space=aggregate_disk
    }

    output {
        counts_matrix = aggregate.counts_matrix
        intersected_bed = intersect_gtf.intersected_bed
    }
}
