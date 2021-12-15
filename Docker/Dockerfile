FROM ubuntu:18.04
MAINTAINER mbrown@broadinstitute.org
ENV DEBIAN_FRONTEND=noninteractive

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Environmental Variables 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ENV WD /usr/local/src 
ENV PATH="/usr/local/src/VirusFinder2.0:/usr/local/src/trinityrnaseq-v2.11.0:/usr/local/src/SVDetect_r0.8b/bin:/usr/local/src/bowtie2-2.4.2-linux-x86_64:/usr/local/src/ncbi-blast-2.11.0+/bin:/usr/local/src/jdk1.6.0_45/bin:${PATH}:/usr/local/src/samtools-0.1.18"

ENV SRC /usr/local/src
ENV BIN /usr/local/bin
ENV LANG C.UTF-8

WORKDIR $SRC
# Updating ubuntu and installing other necessary software
RUN apt-get update --yes && apt-get install \
    wget \
    build-essential \
    zlib1g-dev \
    libbz2-dev \
    unzip \
    cpanminus \
    make \
    libexpat1-dev \
    python \
    python3-pip \
    libncurses5-dev \
    liblzma-dev \
    cmake \
    git \
    --yes \
    && apt-get clean all



#~~~~~~~~~~~~~~~~~~
# Python 
#~~~~~~~~~~~~~~~~~~
RUN pip3 install numpy pandas

#~~~~~~~~~~~~~~~~~~
# Install Java 1.6
#~~~~~~~~~~~~~~~~~~
# Pre-downloaded from https://www.oracle.com/java/technologies/javase-java-archive-javase6-downloads.html
ADD jdk-6u45-linux-x64.bin /usr/local/src
RUN ./jdk-6u45-linux-x64.bin && \
    rm jdk-6u45-linux-x64.bin

#~~~~~~~~~~~~~~~~~~
# Samtools
#~~~~~~~~~~~~~~~~~~
# Added -fPIC as a compiler option to allow for dynamic linking
ADD samtoolsMakefile /usr/local/src
ADD bcftoolsMakefile /usr/local/src

WORKDIR $SRC
RUN wget http://sourceforge.net/projects/samtools/files/samtools/0.1.18/samtools-0.1.18.tar.bz2 && \
    tar xf samtools-0.1.18.tar.bz2 && \
    rm samtools-0.1.18.tar.bz2 && \
    cd samtools-0.1.18 && \
    mv ../samtoolsMakefile Makefile && \
    mv ../bcftoolsMakefile bcftools/Makefile && \
    make && \
    cd .. && \
    env SAMTOOLS=/usr/local/src/samtools-0.1.18
ENV SAMTOOLS=/usr/local/src/samtools-0.1.18

# Install required perl packages
RUN cpanm --notest Config::General Tie::IxHash Parallel::ForkManager Bio::SeqIO Bio::DB::Sam


#~~~~~~~~~~~~~~~~~~
# Install BLAST+
#~~~~~~~~~~~~~~~~~~
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.11.0/ncbi-blast-2.11.0+-x64-linux.tar.gz && \
    tar xf ncbi-blast-2.11.0+-x64-linux.tar.gz && \
    rm ncbi-blast-2.11.0+-x64-linux.tar.gz


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Virus Data 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RUN wget https://s3.amazonaws.com/changseq/kqu/rins/rins.tar.gz \

#~~~~~~~~~~~
## Bedtools
#~~~~~~~~~~~
WORKDIR $SRC
RUN wget -q https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz && \
   tar -xvf bedtools-2.30.0.tar.gz && \
   cd bedtools2 && \
   make && \
   cp bin/* $BIN/ 
   #rm $SRC/bedtools-2.30.0.tar.gz
   #rm -r $SRC/bedtools2

#~~~~~~~~~~~~~~
# BowTie2
#~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.4/bowtie2-2.4.4-source.zip && \
    unzip bowtie2-2.4.4-source.zip && \
    cd bowtie2-2.4.4 && \
    make && \
    cp -r * $BIN
    #rm $SRC/bowtie2-2.4.2-linux-x86_64.zip

#~~~~~~~~~~~~~~~~~~
# Install BWA
#~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2 && \
    tar xf bwa-0.7.17.tar.bz2 && \
    cd bwa-0.7.17 && \
    make bwa && \
    mv bwa /usr/local/bin/ && \
    cd .. && \
    rm -rf bwa-0.7.17 bwa-0.7.17.tar.bz2

#~~~~~~~~~~~~~~~~~~
# SVDetect
#~~~~~~~~~~~~~~~~~~
RUN wget https://sourceforge.net/projects/svdetect/files/SVDetect/0.80/SVDetect_r0.8b.tar.gz && \
    tar xf SVDetect_r0.8b.tar.gz && \
    rm SVDetect_r0.8b.tar.gz

#~~~~~~~~~~~~~~~~~~
# Install Trinity
#~~~~~~~~~~~~~~~~~~
RUN wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.11.0/trinityrnaseq-v2.11.0.FULL.tar.gz && \
    tar xf trinityrnaseq-v2.11.0.FULL.tar.gz && \
    rm trinityrnaseq-v2.11.0.FULL.tar.gz && \
    cd trinityrnaseq-v2.11.0 && \
    make && \
    cd ..

#~~~~~~~~~~~~~~~~~~
#jellyfish
#~~~~~~~~~~~~~~~~~~
RUN wget https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-linux && \
    chmod 755 jellyfish-linux && \
    mv jellyfish-linux trinityrnaseq-v2.11.0/jellyfish
# ./configure CXXFLAGS="-Wno-error=terminate -Wno-error=maybe-uninitialized -Wno-error=unused-result"
# make

#~~~~~~~~~~~~~~~~~~
# VirusFinder
#~~~~~~~~~~~~~~~~~~
RUN wget https://bioinfo.uth.edu/VirusFinder/VirusFinder-2.0.tgz && \
    tar xf VirusFinder-2.0.tgz && \
    rm VirusFinder-2.0.tgz
    # mv detect_virus.pl VirusFinder2.0

RUN git clone https://github.com/brownmp/VirusFinder2_VERSE.git

# Set command to bash
CMD ["/bin/bash"]