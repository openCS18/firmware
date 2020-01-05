FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y make mc git g++ wget python2.7 python3 u-boot-tools libncurses5-dev subversion libssl-dev gawk libxml-parser-perl unzip \
sed binutils build-essential gcc patch gzip bzip2 perl tar cpio rsync file bc
#RUN apt-get clean

RUN mkdir /build
WORKDIR /build/buildroot

VOLUME ["/root"]