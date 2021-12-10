version 1.0




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# create the task Viral Database 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task MakeVirusDataBase {
    input {
        File Virus_Reference

        Int cpus
        Int preemptible
        String docker
        String sample_id

    }
    command <<<
        set -e

        # Untar the references  
        tar -xvf ~{Virus_Reference}

        # Make blast DB
        makeblastdb -in virus.fa -dbtype nucl -out virus
    >>>

    output {
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(Virus_Reference, "GB")*3 ) + " HDD"
        docker: docker
        cpu: cpus
        memory: "10GB"
    }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Index human reference 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Make the BLAST inex for the human genome 
task MakeHumanIndex {
    input {
        File Human_Reference

        Int cpus
        Int preemptible
        String docker
        String sample_id
    }

    command <<<

        set -e
        
        # make directory for the human reference 
        mkdir human_reference

        # Untar the references  
        tar -xvf ~{Human_Reference} --directory human_reference/

        cd human_reference
        # Make Blast DB
        makeblastdb -in GRCh38.genome.fa -dbtype nucl -out GRCh38.genome

        cd ..

        tar -czvf human_reference.tar.gz human_reference
    >>>

    output {
        File human_reference = "human_reference.tar.gz"
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(Human_Reference, "GB") ) + " HDD"
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

        Int cpus
        Int preemptible
        String docker
        String sample_id
    }

    command <<<
        set -e

        # special case for tar of fastq files
        if [[ "~{fastq1}" == *.tar.gz ]] ; then
            mkdir fastq
            tar -I pigz -xvf ~{fastq1} -C fastq
            fastqs=$(find fastq -type f)
            fastq1=$fastqs[0]
            fastq2=$fastqs[1]
        fi
        
        
        # Untar the references  
        tar -xvf ~{Human_Reference}
        tar -xvf ~{Virus_Reference}
    >>>

    output {
    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(Virus_Reference, "GB")*4 ) + " HDD"
        docker: docker
        cpu: cpus
        memory: "10GB"
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
        File GTF_Reference

        #~~~~~~~~~~~~
        # Configuration File 
        #~~~~~~~~~~~~
        File Configuration

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


    #call MakeVirusDataBase{
    #    input:
    #        Virus_Reference = Virus_Reference, 
    #        
    #        cpus            = cpus,
    #        preemptible     = preemptible,
    #        docker          = docker,
    #        sample_id       = sample_id
    #}

    call MakeHumanIndex{
        input:
            Human_Reference = Human_Reference, 
            
            cpus            = cpus,
            preemptible     = preemptible,
            docker          = docker,
            sample_id       = sample_id
    }

    
}

