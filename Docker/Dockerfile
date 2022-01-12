FROM ubuntu:14.04
MAINTAINER mbrown@broadinstitute.org
ENV DEBIAN_FRONTEND=noninteractive

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Environmental Variables 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ENV WD /usr/local/src 
ENV PATH="/usr/local/src/VirusFinder2.0:/usr/local/src/trinityrnaseq-v2.11.0:/usr/local/src/SVDetect_r0.8/bin:/usr/local/src/bowtie2-2.4.2-linux-x86_64:/usr/local/src/ncbi-blast-2.11.0+/bin:/usr/local/src/jdk1.6.0_45/bin:${PATH}:/usr/local/src/samtools-0.1.18"

ENV SRC /usr/local/src
ENV BIN /usr/local/bin
ENV LANG C.UTF-8

WORKDIR $SRC
# Updating ubuntu and installing other necessary software
RUN apt-get -qq update && apt-get -qq -y install --no-install-recommends \
    automake \
    build-essential \
    bzip2 \
    cmake \
    curl \
    default-jre \
    g++ \
    gcc \
    git \
    libbz2-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libdb-dev \
    libjpeg-dev \
    liblzma-dev \
    libpng-dev \
    libreadline-dev \
    libssl-dev \
    libtbb-dev \
    libx11-dev \
    libxml2-dev \
    libxt-dev \
    make \
    pbzip2 \
    pigz \
    python \
    python-pip \
    python-setuptools \
    python3-pip \
    r-base \
    unzip \
    wget \
    x11-common \
    zlib1g \
    zlib1g-dev \
    zlibc \
    libbz2-dev \
    cpanminus \
    libexpat1-dev \
    libncurses5-dev \
    autoconf \
    --yes \
    && apt-get clean all

#RUN apt update && apt install -y python3.9

#~~~~~~~~~~~~~~~~~~
# Install Java 1.6
#~~~~~~~~~~~~~~~~~~
# Pre-downloaded from https://www.oracle.com/java/technologies/javase-java-archive-javase6-downloads.html
ADD jdk-6u45-linux-x64.bin /usr/local/src
RUN ./jdk-6u45-linux-x64.bin && \
    rm jdk-6u45-linux-x64.bin


#~~~~~~~~~~~~~~~~~~
# Install BLAST+
#~~~~~~~~~~~~~~~~~~
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.26/ncbi-blast-2.2.26+-x64-linux.tar.gz && \
    tar xf ncbi-blast-2.2.26+-x64-linux.tar.gz && \
    rm ncbi-blast-2.2.26+-x64-linux.tar.gz


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Virus Data 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RUN wget https://s3.amazonaws.com/changseq/kqu/rins/rins.tar.gz \


#~~~~~~~~~~~~~~
# BowTie2
#~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget --no-check-certificate https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.4/bowtie2-2.4.4-source.zip && \
    unzip bowtie2-2.4.4-source.zip && \
    cd bowtie2-2.4.4 && \
    make && \
    cp -r * $BIN
    #rm $SRC/bowtie2-2.4.2-linux-x86_64.zip

#~~~~~~~~~~~~~~~~~~
# Install BWA
#~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
#RUN wget --no-check-certificate https://sourceforge.net/projects/bio-bwa/files/bwa-0.7.17.tar.bz2 && \
#    tar xf bwa-0.7.17.tar.bz2 && \
#    cd bwa-0.7.17 && \
#    make bwa && \
#    mv bwa /usr/local/bin/ && \
#    cd .. && \
#    rm -rf bwa-0.7.17 bwa-0.7.17.tar.bz2

RUN wget --no-check-certificate https://sourceforge.net/projects/bio-bwa/files/bwa-0.6.1.tar.bz2 && \
    tar xf bwa-0.6.1.tar.bz2 && \
    cd bwa-0.6.1 && \
    make bwa && \
    mv bwa /usr/local/bin/ && \
    cd .. && \
    rm -rf bwa-0.6.1 bwa-0.6.1.tar.bz2

#~~~~~~~~~~~~~~~~~~
# Samtools
#~~~~~~~~~~~~~~~~~~
# Added -fPIC as a compiler option to allow for dynamic linking
ADD samtoolsMakefile /usr/local/src
ADD bcftoolsMakefile /usr/local/src

WORKDIR $SRC
RUN wget --no-check-certificate http://sourceforge.net/projects/samtools/files/samtools/0.1.18/samtools-0.1.18.tar.bz2 && \
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
# SVDetect
#~~~~~~~~~~~~~~~~~~
RUN wget --no-check-certificate https://sourceforge.net/projects/svdetect/files/SVDetect/0.80/SVDetect_r0.8.tar.gz && \
    tar xf SVDetect_r0.8.tar.gz && \
    rm SVDetect_r0.8.tar.gz

#~~~~~~~~~~~~~~~~~~
# Install Trinity
#~~~~~~~~~~~~~~~~~~
WORKDIR $SRC

RUN wget --no-check-certificate https://sourceforge.net/projects/trinityrnaseq/files/PREV_CONTENTS/previous_releases/trinityrnaseq_r2012-06-08.tgz && \
    tar xf trinityrnaseq_r2012-06-08.tgz && \
    rm trinityrnaseq_r2012-06-08.tgz && \
    cd trinityrnaseq_r2012-06-08 && \
    sed -i -e 's/-Wall -Werror//' trinity-plugins/jellyfish/Makefile.in && \
    make && \
    cd ..

#~~~~~~~~~~~~~~~~~~~~~~~~
# Python 3.6 install 
#~~~~~~~~~~~~~~~~~~~~~~~~
RUN wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tgz && \
    tar -xvf Python-3.6.3.tgz && \
    cd Python-3.6.3 && \
    ./configure --enable-optimizations && \
    make -j8 && \
    make install



#~~~~~~~~~~~~~~~~~~
# VirusFinder
#~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget https://bioinfo.uth.edu/VirusFinder/VirusFinder-2.0.tgz && \
    tar xf VirusFinder-2.0.tgz && \
    rm VirusFinder-2.0.tgz

# Clone the git repo
ARG CACHEBUST=1
RUN git clone https://github.com/brownmp/VirusFinder2_VERSE.git

# Set command to bash
CMD ["/bin/bash"]