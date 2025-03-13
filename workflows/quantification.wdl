version 1.0

import "../modules/rnaseqc.wdl" as rnaseqc
import "../modules/aggregate_counts.wdl" as aggregate
import "../modules/intersect_gtf.wdl" as intersect_gtf
import "../modules/cram_to_bam.wdl" as cram_to_bam

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
            },
            intersect_gtf: {
                task_name: "intersect_gtf",
                description: "Uses bedtools intersect to return a bed file with the common gene set between all the gtfs used for quantification"
            }
        }
    }

    input {
        #All
        Array[String] SID
        Array[File] GTF
        Array[File] BAM
        Array[String] suffix #to delineate between CRAM and BAM
        
        #RNASeQC input
        Int rnaseqc_disk

        #cram_to_bam
        File reference_fa
        Int cram_to_bam_disk

        #aggregate
        Int aggregate_disk

        #intersect_gtf
        Int intersect_disk
    }

    call intersect_gtf.intersect_gtf {
        input:
            gtf_files=GTF,
            disk_space=intersect_disk
    }

    scatter (i in range(length(BAM))) {
        if (suffix[i]=="CRAM") {
            call cram_to_bam.cram_to_bam {
                input:
                    SID=SID[i],
                    input_cram=BAM[i],
                    reference_fa=reference_fa,
                    disk_space=cram_to_bam_disk
            } 

            call rnaseqc.RNASeQC as rnaseqc_cram {
                input:
                    SID=SID[i],
                    input_bam=cram_to_bam.bam,
                    gtf_file=GTF[i],
                    disk_space=rnaseqc_disk
            }
        }

        if (suffix[i]=="BAM") {
            call rnaseqc.RNASeQC as rnaseqc_bam {
                input:
                    SID=SID[i],
                    input_bam=BAM[i],
                    gtf_file=GTF[i],
                    disk_space=rnaseqc_disk
            }
        }
    }

    Array[File] gene_counts = flatten([rnaseqc_cram.gene_counts, rnaseqc_bam.gene_counts]) 

    call aggregate.aggregate {
        input:
            SID=SID,
            counts=gene_counts,
            bed=intersect_gtf.intersected_bed,
            disk_space=aggregate_disk
    }

    output {
        File counts_matrix = aggregate.counts_matrix
        File intersected_bed = intersect_gtf.intersected_bed
    }
}
