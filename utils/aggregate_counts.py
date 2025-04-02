import argparse
import pandas as pd
import os

def main(command_args: argparse.Namespace):
    bed = pd.read_csv(command_args.bed, sep="\t", names=["Chromosome", "Start", "End", "Gene", "Length", "Strand"])
    df = pd.DataFrame()
    for file, sid in zip(command_args.counts, command_args.samples):
        new_df = pd.read_csv(file, sep="\t", skiprows=3, names=['ENSG', 'HGNC', sid])
        new_df = new_df[new_df['HGNC'].isin(bed['Gene'])]
        new_df.index = new_df['ENSG']
        new_df.drop(columns=['ENSG', 'HGNC'], inplace=True)
        df[sid] = new_df[sid]
    print("Writing output to:", os.path.abspath("counts_table.tsv"))
    df.to_csv("counts_table.tsv", sep="\t")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="converts counts files from multiple BAM files into a table of counts with rows representing genes and columns representing samples"
    )

    parser.add_argument(
        "-c",
        "--counts",
        nargs="*",
        type=str,
        help="list of paths to individual counts files",
    )

    parser.add_argument(
        "-s",
        "--samples",
        nargs="*",
        type=str,
        help="list of sample IDs corresponding to the counts files being passed"
    )

    parser.add_argument(
        "-b",
        "--bed",
        type=str,
        help="bed file with the overlapping gene set between all annotations used for quantification"
    )
