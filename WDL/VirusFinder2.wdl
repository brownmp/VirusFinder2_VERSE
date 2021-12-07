version 1.0




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# create the task Viral Database 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~
task MakeDataBase {
    input {
        File virus_fa

        Int cpus
        Int preemptible
        String docker
        String sample_id

    }

    command <<<
        set -e

        makeblastdb -in ~{virus_fa} -dbtype nucl -out virus

    >>>

    output {

    }

    runtime {
        preemptible: preemptible
        disks: "local-disk " + ceil(size(virus_fa, "GB") ) + " HDD"
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
        File? rights

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
        # References
        #~~~~~~~~~~~~
        #File ref_fasta

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


    call MakeDataBase{
        input:
            virus_fa = Virus_Reference, 
            

            cpus            = cpus,
            preemptible     = preemptible,
            docker          = docker,
            sample_id       = sample_id
    }

    
}

