version 1.0






#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Run VirusFinder2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task RunVirusFinder {
    input {
        File fastq1
        File? fastq2

        File Human_Reference
        File Virus_Reference

        Int cpus
        Int preemptible
        String docker
        String sample_id
    }

    command <<<
        set -e

        # Untar the references  
        tar -xvf ~{Human_Reference}
        tar -xvf ~{Virus_Reference}

        # special case for tar of fastq files
        if [[ "~{fastq1}" == *.tar.gz ]] ; then
            mkdir fastq
            tar -I pigz -xvf ~{fastq1} -C fastq
            fastqs=$(find fastq -type f)
            fastq1=$fastqs[0]
            fastq2=$fastqs[1]

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

        #~~~~~~~~~~~~~~~~~~~~~~~~
        # Run Virus Finder 2
        #~~~~~~~~~~~~~~~~~~~~~~~~
        # For running downloaded version 
        #/usr/local/src/VirusFinder2.0/VirusFinder.pl \
        # For running commented version
        
        #/usr/local/src/VirusFinder2_VERSE/VirusFinder2.0/VirusFinder.pl \
        /usr/local/src/VirusFinder2.0/VirusFinder.pl \
            -c configuration.txt > output.log

    >>>

    output {
        File configuration = "configuration.txt"
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(Virus_Reference, "GB") + size(Human_Reference, "GB") + size(fastq1, "GB")*4 + 50) + " HDD"
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
    call RunVirusFinder as RunVirusFinder{
        input:
            fastq1 = left,
            fastq2 = right,

            Human_Reference = Human_Reference,
            Virus_Reference = Virus_Reference,
            
            cpus            = cpus,
            preemptible     = preemptible,
            docker          = docker,
            sample_id       = sample_id
    }
}

