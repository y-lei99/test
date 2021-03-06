FROM registry.cn-beijing.aliyuncs.com/k8s_test/test:base-v3
# ----------------------
USER root
# hardcode for now
COPY . /home/jovyan
RUN chown -R ${NB_USER}:${NB_GID} /home/jovyan

#RUN echo "Checking for 'binder' or '.binder' subfolder" \
#        ; if [ -d binder ] ; then \
#        echo "Using 'binder/' build context" \
#        ; elif [ -d .binder ] ; then \
#        echo "Using '.binder/' build context" \
#        ; else \
#        echo "Using './' build context" \
#        ; fi
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "Checking for 'apt.txt'..." \
        #; [ -d binder ] && cd binder \
        #; [ -d .binder ] && cd .binder \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing \
        && xargs -a apt.txt apt-get install -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        ; fi

USER ${NB_USER}

# Create "notebook" conda environment and dask labextensions
RUN conda install -c conda-forge --quiet --yes \
        python=3.7* \
        pangeo-notebook=2020.08.31 \
        pip=20 \
        awscli \
        bottleneck \
        boto3 \
        cartopy>=0.18 \
        cfgrib \
        ciso \
        dask-ml \
        datashader>=0.11 \
        descartes \
        eofs \
        esmpy \
        fastjmd95 \
        fsspec \
        gcsfs \
        geopandas \
        geoviews-core \
        gsw \
        h5netcdf \
        h5py \
        holoviews \
        hvplot \
        intake \
        intake-esm \
        intake-geopandas \
        intake-stac \
        intake-xarray \
        ipyleaflet \
        ipywidgets \
        jupyter-panel-proxy \
        lz4 \
        matplotlib-base \
        metpy \
        nb_conda_kernels \
        nbstripout \
        nc-time-axis \
        netcdf4 \
        nomkl \
        numcodecs \
        numpy \
        pandas \
        panel \
        prefect \
        pyarrow \
        pydap \
        pystac \
        python-blosc \
        python-gist \
        rasterio \
        rio-cogeo \
        rioxarray \
        s3fs \
        sat-search \
        sat-stac \
        satpy \
        scikit-image \
        scikit-learn \
        scipy \
        sparse \
        tiledb-py \
        xarray \
        xarray-spatial \
        xcape \
        xesmf \
        xgcm \
        xhistogram \
        xlayers \
        xmitgcm \
        xpublish \
        xrft \
        zarr \
        && conda clean -yaf 
        #&& find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
        #&& find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete \
        #&& find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete \
        #&& find ${CONDA_DIR}/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete

# Install pip packages
# remove cache https://github.com/pypa/pip/pull/6391 ?
RUN echo "Checking for pip 'requirements.txt'..." \
        #; [ -d binder ] && cd binder \
        #; [ -d .binder ] && cd .binder \
        ; if test -f "requirements.txt" ; then \
        ${CONDA_DIR}/bin/pip install --no-cache-dir -r requirements.txt \
        ; fi

# Run postBuild script within "pangeo" environment
RUN echo "Checking for 'postBuild'..." \
        #; [ -d binder ] && cd binder \
        #; [ -d .binder ] && cd .binder \
        ; if test -f "postBuild" ; then \
        export PATH=${CONDA_DIR}/bin:${PATH} \
        && chmod +x postBuild \
        && ./postBuild \
        && rm -rf /tmp/* \
        && rm -rf ${HOME}/.cache ${HOME}/.npm ${HOME}/.yarn \
        && rm -rf ${CONDA_DIR}/share/jupyter/lab/staging \
        #&& find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
        #&& find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete \
        #&& find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete \
        ; fi

# Overwrite start entrypoint script if present
#RUN echo "Checking for 'start'..." \
#        ; [ -d binder ] && cd binder \
#        ; [ -d .binder ] && cd .binder \
#        ; if test -f "start" ; then \
#        chmod +x start \
#        && cp start /srv/start \
#        ; fi
# ----------------------
