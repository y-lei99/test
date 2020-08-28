FROM ubuntu:18.04
# Master build file for pangeo images

# Run this section as root
# try to keep conda version in sync with repo2docker
# ========================
ENV CONDA_VERSION=4.8.3-4 \
    #CONDA_ENV=notebook \
    NB_USER=jovyan \
    NB_UID=1000 \
    SHELL=/bin/bash \
    LANG=C.UTF-8  \
    LC_ALL=C.UTF-8 \
    CONDA_DIR=/srv/conda

#ENV #NB_PYTHON_PREFIX=${CONDA_DIR}/envs/${CONDA_ENV} \
ENV DASK_ROOT_CONFIG=${CONDA_DIR}/etc \
    HOME=/home/${NB_USER} \
    PATH=${CONDA_DIR}/bin:${PATH}

# Create jovyan user, permissions, add conda init to startup script
RUN echo "Creating ${NB_USER} user..." \
    && groupadd --gid ${NB_UID} ${NB_USER}  \
    && useradd --create-home --gid ${NB_UID} --no-log-init --uid ${NB_UID} ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh" > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_USER} /srv

# COPY chown available docker>17.09
# but env sub only works for docker>19.03 (kubernetes>1.17)
# https://github.com/moby/moby/issues/35018
#COPY --chown=${NB_USER}:${NB_USER} . ${HOME}
#COPY --chown=jovyan:jovyan . /srv
COPY . /home/jovyan/
RUN chown -R jovyan:jovyan /home/jovyan/
# SEE: https://github.com/phusion/baseimage-docker/issues/58
# and https://github.com/phusion/baseimage-docker/issues/319
ARG DEBIAN_FRONTEND=noninteractive

RUN echo "Installing Apt-get packages..." \
    && apt-get update --fix-missing \
    && apt-get install -y apt-utils 2> /dev/null \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# ========================

USER ${NB_USER}
WORKDIR ${HOME}

RUN echo "Installing Miniforge..." \
    && URL="https://github.com/conda-forge/miniforge/releases/download/${CONDA_VERSION}/Miniforge3-${CONDA_VERSION}-Linux-x86_64.sh" \
    && wget --quiet ${URL} -O miniconda.sh \
    && /bin/bash miniconda.sh -u -b -p ${CONDA_DIR} \
    && rm miniconda.sh \
    && conda clean -afy \
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
    && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete

RUN echo "Copying configuration files..." \
    && mv /home/jovyan/condarc.yml ${CONDA_DIR}/.condarc \
    && mv /home/jovyan/dask_config.yml ${CONDA_DIR}/etc/dask.yml

EXPOSE 8888
ENTRYPOINT ["/srv/start"]
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

# Only run these if used as a base image

