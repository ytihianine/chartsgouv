# Image to get DSFR
FROM ubuntu:20.04 AS DSFR_IMAGE

USER root

# installation de unzip et wget dans l'image
COPY unzip /usr/local/bin/
COPY wget /usr/local/bin/

RUN chmod +x /usr/local/bin/unzip
RUN chmod +x /usr/local/bin/wget



# Image to build charstgouv
