# Define ARGS
# Superset version
ARG SUPERSET_VERSION=4.1.1
# DSFR versions
ARG REPO_OWNER=GouvernementFR
ARG REPO_NAME=dsfr
# Default value, they are overridden in gitlab CI
ARG TAG_DSFR=v1.13.0
ARG TAG_DSFR_CHART=v1.0.0

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

RUN wget -O dsfr-base.zip "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TAG_DSFR}/${REPO_NAME}-${TAG_DSFR}.zip"
RUN unzip dsfr-base.zip -d dsfr-base && rm dsfr-base.zip

RUN wget -O dsfr-chart.zip "https://github.com/GouvernementFR/dsfr-chart/releases/download/v1.0.0/dsfr-chart-1.0.0.zip"
RUN unzip dsfr-chart.zip -d dsfr-chart && rm dsfr-chart.zip

# Import des templates custom supersets
COPY superset-custom ./superset-custom/
COPY superset_config.py ./superset_config.py

RUN bash -c "ls"

# Image to build charstgouv
# Default value, they are overridden in gitlab CI
FROM apache/superset:${SUPERSET_VERSION} AS chartsgouv_img

USER root

WORKDIR /app

# Copier tous les éléments du DSFR dans l'image superset
COPY --from=dsfr_image /app/dsfr-base/dist /app/superset/static/assets/dsfr
COPY --from=dsfr_image /app/dsfr-chart/Charts /app/superset/static/assets/dsfr-chart
COPY --from=dsfr_image /app/superset-custom/assets  /app/superset/static/assets/local

# Override des templates
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/base.html      /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/basic.html     /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/public_welcome.html    /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/tail_js_custom_extra.html   /app/superset/templates/tail_js_custom_extra.html
COPY --from=dsfr_image /app/superset-custom/assets/404.html     /app/superset/static/assets/404.html
COPY --from=dsfr_image /app/superset-custom/assets/500.html     /app/superset/static/assets/500.html


# Update de certaines valeurs css 
RUN for theme_filename in $(find /app/superset/static/assets -name "theme*.css"); do \
        sed \
        -e "s/#20a7c9/#000091/g" \
        -e "s/#45bed6/#000091/g" \
        -e "s/#1985a0/#000091/g" \
        "$theme_filename" > temp.css && mv temp.css "$theme_filename"; done;

# Ajout de la config d'override
COPY --from=dsfr_image --chown=superset /app/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH /app/superset_config.py
