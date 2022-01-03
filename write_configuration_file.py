#!/usr/bin/env python3
# -*- coding: utf-8 -*-


####################
# Preliminary 
####################
#~~~~~~~~~~~~~~~~~~
# import packages 
#~~~~~~~~~~~~~~~~~~
import argparse
import os

def main():
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Inputs
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parser = argparse.ArgumentParser(   formatter_class = argparse.RawTextHelpFormatter, 
                                        description     = "")
    # parser.add_argument('--fastqs',  required = True,  nargs='+', help = "fastq File input, or a directory holding one or two.")
    parser.add_argument('--fastq1',  required = True,  help = "fastq File input")
    parser.add_argument('--fastq2',  required = True,  help = "fastq File input")
    parser.add_argument('--detect_integration', required = False, default = "yes", help = "if ‘no’ is provided, step (3), virus integration detection, will be skipped")
    parser.add_argument('--detect_mutation', required = False, default = "no", help = "if ‘no’ is provided, step (4), viral mutation detection, will be skipped")
    parser.add_argument('--mailto', required = False, default = "", help = "email")
    parser.add_argument('--thread_no', required = False, default = "8", help = "threads")
    
    # parser.add_argument('--blastn_bin', required = False, default = "/usr/local/src/ncbi-blast-2.2.26+/bin/blastn", help = "")
    # parser.add_argument('--bowtie_bin', required = False, default = "/usr/local/bin/bowtie2", help = "")
    # parser.add_argument('--bwa_bin', required = False, default = "/usr/local/bin/bwa", help = "")
    # parser.add_argument('--trinity_script', required = False, default = "/usr/local/bin/trinityrnaseq_r2012-06-08/Trinity.pl", help = "")
    # parser.add_argument('--SVDetect_dir', required = False, default = "/usr/local/scr/SVDetect_r0.8", help = "")

    parser.add_argument('--virus_database', required = False, default = "./virus_reference/virus.fa", help = "")
    parser.add_argument('--bowtie_index_human', required = False, default = "./human_reference/GRCh38.genome", help = "")
    parser.add_argument('--blastn_index_human', required = False, default = "./human_reference/GRCh38.genome", help = "")
    parser.add_argument('--blastn_index_virus', required = False, default = "./virus_reference/virus", help = "")

    parser.add_argument('--detection_mode', required = False, default = "normal", help = "Possible values: {normal, sensitive}; default value: normal.")
    parser.add_argument('--flank_region_size', required = False, default = "4000", help = "Suggested values: >2000; default: 4000; if detection_mode =")
    parser.add_argument('--sensitivity_level', required = False, default = "1", help = "Suggested values: 1~6; default value: 1; greater value means higher")

    parser.add_argument('--min_contig_length', required = False, default = "300", help = "")
    parser.add_argument('--blastn_evalue_thrd', required = False, default = "0.05", help = "")
    parser.add_argument('--similarity_thrd', required = False, default = "0.8", help = "")
    parser.add_argument('--chop_read_length', required = False, default = "25", help = "")
    parser.add_argument('--minIdentity', required = False, default = "80", help = "")

    args = parser.parse_args()


    fastq1 = args.fastq1
    fastq2 = args.fastq2
    detect_integration = args.detect_integration
    detect_mutation = args.detect_mutation
    mailto = args.mailto
    thread_no = args.thread_no

    # References 
    cwd = os.getcwd()

    virus_database = os.path.join(cwd, args.virus_database)
    blastn_index_virus = os.path.join(cwd, args.blastn_index_virus)


    virus_database = os.path.join(cwd, "virus_reference/virus.fa")
    blastn_index_virus = os.path.join(cwd, "virus_reference/virus")
    bowtie_index_human = os.path.join(cwd, "human_reference/GRCh38.genome")
    blastn_index_human = os.path.join(cwd, "human_reference/GRCh38.genome")

    # print(bowtie_index_human)
    # print(blastn_index_human)

    # virus_database = args.virus_database
    # blastn_index_virus = args.blastn_index_virus
    # bowtie_index_human = args.bowtie_index_human
    # blastn_index_human = args.blastn_index_human


    detection_mode = args.detection_mode
    flank_region_size = args.flank_region_size
    sensitivity_level = args.sensitivity_level
    min_contig_length = args.min_contig_length
    blastn_evalue_thrd = args.blastn_evalue_thrd
    similarity_thrd = args.similarity_thrd
    chop_read_length = args.chop_read_length
    minIdentity = args.minIdentity

    a = f"""##########################################
    ## Input data can be: (a) an alignment file (in BAM format); or (b) FASTQ file(s) (preferred) – for
    ## single end data, “fastq1” is required; for paired-end, both “fastq1” and “fastq2” are needed.
    ##########################################
    # alignment_file = /scratch/kingw/virusFinder/simulation/simulation..bam
    fastq1 = {fastq1}
    fastq2 = {fastq2}
    detect_integration = {detect_integration}
    detect_mutation = {detect_mutation}
    mailto = {mailto}
    thread_no = {thread_no}

    ##########################################
    ## The full paths to the following third-party tools are required by VirusFinder:
    ##########################################
    blastn_bin = /usr/local/src/ncbi-blast-2.2.26+/bin/blastn
    bowtie_bin = /usr/local/bin/bowtie2
    bwa_bin = /usr/local/bin/bwa
    trinity_script = /usr/local/src/trinityrnaseq_r2012-06-08/Trinity.pl
    SVDetect_dir = /usr/local/src/SVDetect_r0.8

    ##########################################
    ## Reference files (indexed for Bowtie2 and BLAST)
    ##########################################
    virus_database = {virus_database}
    bowtie_index_human = {bowtie_index_human}
    blastn_index_human = {blastn_index_human}
    blastn_index_virus = {blastn_index_virus}

    ##########################################
    ## Parameters of virus insertion detection (VERSE algorithm). They are ignored for single-end data
    ##########################################
    detection_mode = {detection_mode}
    #If not specified, VirusFinder runs in normal detection mode.
    flank_region_size = {flank_region_size}
    #normal, it (and ‘sensitivity_level’ below) will be ignored.
    sensitivity_level = {sensitivity_level}
    #sensitivity, and accordingly more computation time.

    ##########################################
    ## Parameters of virus detection. Smaller “min_contig_length”, higher sensitivity
    ##########################################
    min_contig_length = {min_contig_length}
    blastn_evalue_thrd = {blastn_evalue_thrd}
    similarity_thrd = {similarity_thrd}
    chop_read_length = {chop_read_length}
    minIdentity = {minIdentity}
    """

    print("#~~~~~~~~~~~~~~~~~~~~~~~~\nWriting Configuration file\n#~~~~~~~~~~~~~~~~~~~~~~~~")
    output_file = open("configuration.txt", "w")
    output_file.write(a)
    output_file.close()



if __name__ == '__main__':
    main()