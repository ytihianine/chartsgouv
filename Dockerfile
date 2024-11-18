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

# Define the repository and tag
ENV REPO_NAME=dsfr
ENV REPO_OWNER=GouvernementFR
ENV TAG=v1.12.1

RUN wget -O dsfr-base.zip "https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/tags/${TAG}.zip"
RUN unzip dsfr-base.zip && rm dsfr-base.zip

RUN wget -O dsfr-chart.zip "https://github.com/GouvernementFR/dsfr-chart/archive/refs/tags/v1.0.0.zip"
RUN unzip dsfr-chart.zip && rm dsfr-chart.zip

# Import des templates custom supersets
COPY superset .superset-custom/

RUN bash -c "ls"

# Image to build charstgouv
#FROM apache/superset:4.0.2 AS chartsgouv_img

#WORKDIR /app

#RUN bash -c "ls"

# Ajout de la config d'override
#COPY --chown=superset superset_config.py /app/
#ENV SUPERSET_CONFIG_PATH /app/superset_config.py
