# Image to get DSFR
FROM ubuntu:20.04 AS dsfr_image

USER root

# Install wget and unzip
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Check unzip and wget
RUN bash -c "if command -v unzip &>/dev/null; then echo 'UNZIP is installed'; else echo 'UNZIP is missing'; fi"
RUN bash -c "if command -v wget &>/dev/null; then echo 'WGET is installed'; else echo 'WGET is missing'; fi"

# Set the working directory
WORKDIR /app

RUN curl -L -o repo.zip "https://github.com/GouvernementFR/dsfr/tree/v1.12.1"


# installation de unzip et wget dans l'image
#COPY unzip /usr/local/bin/
#COPY wget /usr/local/bin/

#RUN chmod +x /usr/local/bin/unzip
#RUN chmod +x /usr/local/bin/wget



# Image to build charstgouv
