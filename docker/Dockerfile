# build image
FROM facchin/devbase-base:ubuntu-16.04

RUN true

# bootstrap
RUN apt-get clean -y \
    && apt-get update -y 

# utils
RUN apt-get install --no-install-recommends -yq \ 
    axel \
    grub2 \
    gdisk \
    dosfstools \
    pv

# cleanup
RUN apt-get autoremove -y \
    && apt-get clean -y   
