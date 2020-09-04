FROM ubuntu:18.04
# Master build file for pangeo images

# Run this section as root
# try to keep conda version in sync with repo2docker
# ========================
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    run-one \
    && apt-get clean && rm -rf /var/lib/apt/lists/* 
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV CONDA_DIR=/srv/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8
    #CONDA_VERSION=4.8.3-4
    #CONDA_ENV=notebook 
    #NB_USER=jovyan \
    #NB_UID=1000 \
    #SHELL=/bin/bash \
    #LANG=C.UTF-8  \
    #LC_ALL=C.UTF-8 \
    
#NB_PYTHON_PREFIX=${CONDA_DIR}/envs/${CONDA_ENV} \
ENV DASK_ROOT_CONFIG=${CONDA_DIR}/etc \
    HOME=/home/${NB_USER} \
    PATH=${CONDA_DIR}/bin:${PATH}

COPY fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions
# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \ 
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR
# Create jovyan user, permissions, add conda init to startup script
RUN echo "Creating ${NB_USER} user..." \
    #&& groupadd --gid ${NB_UID} ${NB_USER}  \
    #&& useradd --create-home --gid ${NB_UID} --no-log-init --uid ${NB_UID} ${NB_USER} \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh " > /etc/profile.d/init_conda.sh \
    && chown -R ${NB_USER}:${NB_GID} /srv
    #fix-permissions $HOME && \
    #fix-permissions $CONDA_DIR
#; conda activate ${CONDA_ENV}

# ========================
#RUN fix-permissions /home/$NB_USER
# COPY chown available docker>17.09
# but env sub only works for docker>19.03 (kubernetes>1.17)
# https://github.com/moby/moby/issues/35018
#COPY --chown=${NB_USER}:${NB_USER} . ${HOME}
COPY  . /srv
RUN chown -R ${NB_USER}:${NB_GID} /srv

# SEE: https://github.com/phusion/baseimage-docker/issues/58
# and https://github.com/phusion/baseimage-docker/issues/319






USER $NB_USER
WORKDIR ${HOME}
ARG PYTHON_VERSION=default
# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER
    
ENV MINICONDA_VERSION=4.8.3 \
    MINICONDA_MD5=d63adf39f2c220950a063e0529d4ff74 \
    CONDA_VERSION=4.8.3
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -u -b -p $CONDA_DIR && \
    rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority strict && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
#RUN echo "Installing Miniforge..." \
#    && URL="https://github.com/conda-forge/miniforge/releases/download/${CONDA_VERSION}/Miniforge3-${CONDA_VERSION}-Linux-x86_64.sh" \
#    && wget --quiet ${URL} -O miniconda.sh \
#    && /bin/bash miniconda.sh -u -b -p ${CONDA_DIR} \
#    && rm miniconda.sh \
#    && conda clean -afy \
#    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
#    && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete

RUN echo "Copying configuration files..." \
    && mv /srv/condarc.yml ${CONDA_DIR}/.condarc \
    && mv /srv/dask_config.yml ${CONDA_DIR}/etc/dask.yml
    
# Install Tini
RUN conda install --quiet --yes 'tini=0.18.0' && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean -afy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
    
# Install Jupyter Notebook, Lab, and Hub
# Generate a notebook server config
# Cleanup temporary files
# Correct permissions
# Do all this in a single RUN command to avoid duplicating all of the
# files across image layers when the permissions change
RUN conda install --quiet --yes \
    'notebook' \
    'jupyterhub' \
    'jupyterlab' && \
    #conda clean -afy && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Copy local files as late as possible to avoid cache busting
COPY start.sh start-notebook.sh start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_USER

WORKDIR $HOME
#ENTRYPOINT ["/srv/start"]
#CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]

# Only run these if used as a base image
# ----------------------
