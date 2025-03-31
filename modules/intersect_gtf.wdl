version 1.0

task intersect_gtf {
    input {
        Array[File] gtf_files

        Int disk_space
    }

    command <<<
        set -euo pipefail
        echo ~{sep=" " gtf_files} | tr ' ' '\n' | sort | uniq | tr '\n' ' ' > unique_gtf.txt
        cat unique_gtf.txt
        gtf_iterable=()
        while VAL= read -r line; do
            gtf_iterable+=("$line")
        done < unique_gtf.txt
        
        for gtf in "${gtf_iterable[@]}"; do
            echo "Processing file: $gtf"
            gtf2bed "${gtf}" | awk '{print $2"\t"$3-1"\t"$4"\t"$1"\t"$5}' > "${gtf}.bed"
        done

        #initialize intersected bed
        bedtools intersect -a "${gtf_iterable[0]}.bed" -b "${gtf_iterable[1]}.bed" -u -f 0.8 > intersected.bed

        #Iterate through remaining bed files
        for ((i=2; i<${#gtf_iterable[@]}; i++)); do
            bedtools intersect -a "${gtf_iterable[i]}.bed" -b intersected.bed -u -f 0.8 > temp.bed
            mv temp.bed intersected.bed
        done

        #Calculate gene lengths based on this bed file
        awk '{print$1"\t"$2"\t"$3"\t"$4"\t"$3-$2"\t"$5}' intersected.bed > final.bed
    >>>

    output {
        File intersected_bed = "final.bed"
    }

    runtime {
        docker: "atex91/gffutils-bedtools:v1.0" 
        memory: "80GB"
        disks: "local-disk ~{disk_space} HDD"
        cpu: "1"
    }

    parameter_meta {
        gtf_files: {
            label: "Array of paths to GTF-Format Annotation Files used for each alignment."
        }
    }

    meta {
        author: "Alexander Miller"
    }
}
