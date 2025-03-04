version 1.0

task intersect_gtf {
    input {
        Array[String] gtf_files

        Int disk_space
    }

    command <<<
        set -euo pipefail

        gtf_iterable=(~{sep=" " gtf_files})
        
        for gtf in $gtf_iterable; do
            gtf2bed ${gtf} | awk '{print $2"\t"$3-1"\t"$4"\t"$1"\t"$5}' > ${gtf}.bed
        done

        #initialize intersected bed
        bedtools intersect -a ${gtf_iterable}[0].bed -b ${gtf_iterable}[1].bed -u -f 0.8 > intersected.bed

        #Iterate through remaining bed files
        for ((i=2; i<${#gtf_iterable[@]}; i++)); do
            bedtools intersect -a $gtf_iterable[i] -b intersected.bed -u -f 0.8 > temp.bed
            mv temp.bed intersected.bed
        done

        #Calculate gene lengths based on this bed file
        awk '{print$1"\t"$2"\t"$3"\t"$4"\t"$3-$2"\t"$5}' intersected.bed > final.bed
    >>>

    output {
        File intersected_bed = "final.bed"
    }

    runtime {
        docker: "atex91/gffutils-bedtools" 
        memory: "80GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "1"
    }
}
