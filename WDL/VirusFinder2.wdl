version 1.0


task writeConfigurationFile {
    input{
        File fastq1
        File? fastq2

        Int cpus
        Int preemptible
        String docker
        String sample_id
    }

    command <<<
        set -e
        # special case for tar of fastq files
        if [[ "~{fastq1}" == *.tar.gz ]]
        then
            mkdir fastq
            tar -xvf ~{fastq1} -C fastq
            rm ~{fastq1}
            #fastqs=$(find fastq -type f)
            fastqs=($(pwd)/fastq/*)
            fastq1="${fastqs[0]}"
            fastq2="${fastqs[1]}"

            #~~~~~~~~~~~~~~~~~~~~~~~
            # Write the configuration file
            #~~~~~~~~~~~~~~~~~~~~~~~
            python3 /usr/local/src/VirusFinder2_VERSE/write_configuration_file.py \
                --fastq1 $fastq1 \
                --fastq2 $fastq2
        else 
        
            #~~~~~~~~~~~~~~~~~~~~~~~
            # Write the configuration file
            #~~~~~~~~~~~~~~~~~~~~~~~
            python3 /usr/local/src/VirusFinder2_VERSE/write_configuration_file.py \
                --fastq1 ~{fastq1} \
                --fastq2 ~{fastq2}
        fi
    >>>
    
    output {
        File configuration = "configuration.txt"
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(fastq1, "GB")*2 + 100) + " HDD"
        docker: docker
        cpu: cpus
        memory: "10GB"
    }
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run VirusFinder2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task RunVirusFinder {
    input {
        File fastq1
        File? fastq2

        File Human_Reference
        File Virus_Reference

        File configuration

        Int cpus
        Int preemptible
        String docker
        String sample_id
    }

    command <<<
        set -e


        #~~~~~~~~~~~~~~~~~~~~~~~~
        # Run Virus Finder 2
        #~~~~~~~~~~~~~~~~~~~~~~~~


        perl /usr/local/src/VirusFinder2.0/preprocess.pl \
            -c ~{configuration}

        perl /usr/local/src/VirusFinder2.0/preprocess.pl \
            -c ~{configuration}
            -v HPV16


    >>>

    output {
        File configuration = "configuration.txt"
        File output_log = "output.log"
        File virus_txt = "virus.txt"
        File virus_list_txt = "virus-list.txt"
        File contig_txt = "contig.txt"
        File integration_sites_txt = "integration-sites.txt"
        File? novel_contig_fa = "novel-contig.fa"
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(Virus_Reference, "GB") + size(Human_Reference, "GB") + size(fastq1, "GB")*6 + 100) + " HDD"
        docker: docker
        cpu: cpus
        memory: "100GB"
    }
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Workflow
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

workflow VirusFinder2 {
    input {

        #~~~~~~~~~~~~
        # Sample ID
        #~~~~~~~~~~~~
        String sample_id
      
        #~~~~~~~~~~~~
        # FASTQ Files
        #~~~~~~~~~~~~
        File left
        File? right

        #~~~~~~~~~~~~
        # CPU count 
        #~~~~~~~~~~~~
        Int cpus = 10

        #~~~~~~~~~~~~
        # Directories 
        #~~~~~~~~~~~~
        File Virus_Reference
        File Human_Reference

        #~~~~~~~~~~~~
        # general runtime settings
        #~~~~~~~~~~~~
        Int preemptible = 2
        String docker = "brownmp/virusfinder2:devel"

        

    }

    parameter_meta {
        left:{help:"One of the two paired RNAseq samples"}
        right:{help:"One of the two paired RNAseq samples"}
        cpus:{help:"CPU count"}
        docker:{help:"Docker image"}
    }


    #########################
    # run using given references 
    #########################

    call writeConfigurationFile{
        input:
            fastq1 = left,
            fastq2 = right,
            
            cpus            = cpus,
            preemptible     = preemptible,
            docker          = docker,
            sample_id       = sample_id

    }


    call RunVirusFinder as RunVirusFinder{
        input:
            fastq1 = left,
            fastq2 = right,

            Human_Reference = Human_Reference,
            Virus_Reference = Virus_Reference,

            configuration   = writeConfigurationFile.configuration,
            
            cpus            = cpus,
            preemptible     = preemptible,
            docker          = docker,
            sample_id       = sample_id
    }
}

