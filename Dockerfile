# Define ARGS (Defaults, overridden in GitLab CI)
ARG SUPERSET_REPO=apache/superset
ARG SUPERSET_VERSION=4.1.1
ARG REPO_OWNER=GouvernementFR
ARG REPO_NAME=dsfr
ARG TAG_DSFR=v1.13.0
ARG TAG_DSFR_CHART=v1.0.0

# Making ENV vars
ENV REPO_OWNER=$REPO_OWNER
ENV REPO_NAME=$REPO_NAME
ENV TAG_DSFR=$TAG_DSFR
ENV TAG_DSFR_CHART=$TAG_DSFR_CHART

# ------------------------------------------
# Stage 1: Download DSFR
# ------------------------------------------
FROM ubuntu:20.04 AS dsfr_image

USER root

# Install dependencies
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Debugging: Check if wget/unzip are installed
RUN command -v unzip && command -v wget

# Set the working directory
WORKDIR /app

# Define DSFR Download URL
# Download DSFR
RUN echo "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TAG_DSFR}/${REPO_NAME}-${TAG_DSFR}.zip"
RUN wget -O dsfr-base.zip "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${TAG_DSFR}/${REPO_NAME}-${TAG_DSFR}.zip"
RUN unzip dsfr-base.zip -d dsfr-base && rm dsfr-base.zip

# Download DSFR Chart dynamically
RUN wget -O dsfr-chart.zip "https://github.com/${REPO_OWNER}/dsfr-chart/releases/download/${TAG_DSFR_CHART}/dsfr-chart-${TAG_DSFR_CHART}.zip"
RUN unzip dsfr-chart.zip -d dsfr-chart && rm dsfr-chart.zip

# Import custom Superset templates
COPY superset-custom ./superset-custom/
COPY superset_config.py ./superset_config.py

RUN ls -la /app

# ------------------------------------------
# Stage 2: Build chartsgouv Image
# ------------------------------------------
# First static FROM to ensure Docker doesn't fail
FROM apache/superset:4.1.1 AS base_image

# Declare ARG again since it's lost across stages
ARG SUPERSET_VERSION
FROM apache/superset:${SUPERSET_VERSION} AS chartsgouv_img

USER root
WORKDIR /app

# Copy DSFR assets from dsfr_image stage
COPY --from=dsfr_image /app/dsfr-base/dist /app/superset/static/assets/dsfr
COPY --from=dsfr_image /app/dsfr-chart/Charts /app/superset/static/assets/dsfr-chart
COPY --from=dsfr_image /app/superset-custom/assets  /app/superset/static/assets/local

# Override Superset templates
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/base.html      /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/basic.html     /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/superset/public_welcome.html    /app/superset/templates/superset/
COPY --from=dsfr_image /app/superset-custom/templates_overrides/tail_js_custom_extra.html   /app/superset/templates/tail_js_custom_extra.html
COPY --from=dsfr_image /app/superset-custom/assets/404.html     /app/superset/static/assets/404.html
COPY --from=dsfr_image /app/superset-custom/assets/500.html     /app/superset/static/assets/500.html

# Update CSS Colors
RUN find /app/superset/static/assets -name "theme*.css" -exec sed -i \
        -e "s/#20a7c9/#000091/g" \
        -e "s/#45bed6/#000091/g" \
        -e "s/#1985a0/#000091/g" {} \;

# Copy Superset config override
COPY --from=dsfr_image --chown=superset /app/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH /app/superset_config.py
