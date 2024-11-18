# Image to get DSFR
FROM ubuntu:20.04 AS DSFR_IMAGE

USER root

# Check unzip and wget
RUN bash -c "if command -v unzip &>/dev/null; then echo 'UNZIP is installed'; else echo 'UNZIP is missing'; fi"
RUN bash -c "if command -v wget &>/dev/null; then echo 'WGET is installed'; else echo 'WGET is missing'; fi"

# Install wget and unzip
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# installation de unzip et wget dans l'image
#COPY unzip /usr/local/bin/
#COPY wget /usr/local/bin/

#RUN chmod +x /usr/local/bin/unzip
#RUN chmod +x /usr/local/bin/wget



# Image to build charstgouv
