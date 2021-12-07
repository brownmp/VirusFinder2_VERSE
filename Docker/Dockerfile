FROM ubuntu:18.04
MAINTAINER mbrown@broadinstitute.org
ENV DEBIAN_FRONTEND=noninteractive

#~~~~~~~~~~~~~~
# Install Preliminaries
#~~~~~~~~~~~~~~
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
    cpanminus



#~~~~~~~~~~~
# Environmental Variables 
#~~~~~~~~~~~
ENV SRC /usr/local/src
ENV BIN /usr/local/bin



#~~~~~~~~~~~
## Samtools
#~~~~~~~~~~~
WORKDIR $SRC
ENV SAMTOOLS_VERSION=1.12
RUN SAMTOOLS_URL="https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2" && \
    cd $SRC && \
    wget $SAMTOOLS_URL && \
    tar xf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    cd samtools-${SAMTOOLS_VERSION}/htslib-${SAMTOOLS_VERSION} && ./configure && make && make install && \
    cd ../ && ./configure --without-curses && make && make install && \
    rm $SRC/samtools-${SAMTOOLS_VERSION}.tar.bz2 && rm -r $SRC/samtools-${SAMTOOLS_VERSION}


#~~~~~~~~~~~
## Bedtools
#~~~~~~~~~~~
RUN wget -q https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools-2.30.0.tar.gz && \
   tar xf bedtools-2.30.0.tar.gz && \
   cd bedtools2 && \
   make && \
   cp bin/* $BIN/ && \
   rm $SRC/bedtools-2.30.0.tar.gz && rm -r $SRC/bedtools2

#~~~~~~~~~~~~~~
# BWA
#~~~~~~~~~~~~~~
RUN git clone https://github.com/lh3/bwa.git && \
    cd bwa && \
    make && \
    cp -r * $BIN/ && \
    cd .. && \
    rm -r bwa


#~~~~~~~~~~~~~~
# BowTie2
#~~~~~~~~~~~~~~
WORKDIR $SRC
ENV Bowtie2_VERSION=2.4.4

RUN wget https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.4.4/bowtie2-2.4.4-source.zip && \
    unzip bowtie2-2.4.4-source.zip && \
    cd bowtie2-2.4.4 && \
    make && \
    cp -r * $BIN



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## BLAST
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.11.0/ncbi-blast-2.11.0+-x64-linux.tar.gz && \
    tar xf ncbi-blast-2.11.0+-x64-linux.tar.gz && \
    rm ncbi-blast-2.11.0+-x64-linux.tar.gz


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## SVdetect
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
WORKDIR $SRC
RUN wget https://sourceforge.net/projects/svdetect/files/SVDetect/0.80/SVDetect_r0.8b.tar.gz && \
    tar xf SVDetect_r0.8b.tar.gz && \
    rm SVDetect_r0.8b.tar.gz


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Perl
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#WORKDIR $SRC
#RUN cpanm --notest Config::General Tie::IxHash Parallel::ForkManager Bio::SeqIO Bio::DB::Sam


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Trinity
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.11.0/trinityrnaseq-v2.11.0.FULL.tar.gz && \ 
    tar xf trinityrnaseq-v2.11.0.FULL.tar.gz && \
    rm trinityrnaseq-v2.11.0.FULL.tar.gz && \
    cd trinityrnaseq-v2.11.0 && \
    make && \
    cd ..


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## JellyFish
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WORKDIR $SRC
RUN wget https://github.com/gmarcais/Jellyfish/releases/download/v2.3.0/jellyfish-linux && \
    chmod 755 jellyfish-linux && \
    mv jellyfish-linux trinityrnaseq-v2.11.0/jellyfish



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Virus Data 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# RUN wget https://s3.amazonaws.com/changseq/kqu/rins/rins.tar.gz \



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## VirusFinder2
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WORKDIR $SRC
RUN wget https://bioinfo.uth.edu/VirusFinder/VirusFinder-2.0.tgz && \
    tar xf VirusFinder-2.0.tgz && \
    rm VirusFinder-2.0.tgz






# RUN wget -q https://raw.githubusercontent.com/klarman-cell-observatory/cumulus/master/docker/monitor_script.sh -O $SRC/CTAT-VirusIntegrationFinder/WDL/monitor_script.sh
# RUN chmod a+rx $SRC/CTAT-VirusIntegrationFinder/WDL/monitor_script.sh

RUN apt-get -qq -y remove automake build-essential cmake curl git gcc g++ wget && \
    apt-get -qq -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/dpkg.log


