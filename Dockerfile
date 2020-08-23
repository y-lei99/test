FROM pangeo/base-notebook:2019.12.04
Run conda install --yes 'git'
RUN git clone -b python3 https://github.com/y-lei99/geonotebook.git
RUN cd python3
RUN conda install --quiet --yes \
                       'curl' \
                       'pyproj' \
                       'pkg-config' \
                       'ipywidgets' \
                       'setuptools' \
                       'wheel' \
                       'pip' \
                       'cffi' \
                       'lxml' \
                       'numpy' \
                       'scipy' \
                       'pandas' \
                       'matplotlib' \
                       'seaborn' \
                       'cython' \
                       'statsmodels' \
                       'pyOpenSSL' \
                       'scikit-image' \
                       'jupyterhub=1.1.0' \
                       && \
                       conda clean --all -f -y && \
                       jupyter nbextension enable --py widgetsnbextension --sys-prefix
                      
RUN pip install -U -r prerequirements.txt && \
    pip install -U -r requirements.txt . && \
    jupyter serverextension enable --py geonotebook --sys-prefix && \
    jupyter nbextension enable --py geonotebook --sys-prefix
