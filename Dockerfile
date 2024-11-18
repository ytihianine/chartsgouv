# Image to get DSFR
FROM ubuntu:20.04 AS DSFR_IMAGE

USER root

# Check unzip and wget
RUN bash -c "if command -v unzip &>/dev/null && command -v wget &>/dev/null; then echo 'Tools are installed'; else echo 'Tools are missing'; fi"

# installation de unzip et wget dans l'image
#COPY unzip /usr/local/bin/
#COPY wget /usr/local/bin/

#RUN chmod +x /usr/local/bin/unzip
#RUN chmod +x /usr/local/bin/wget



# Image to build charstgouv
