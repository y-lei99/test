FROM registry.cn-beijing.aliyuncs.com/k8s_test/geonotebook:geopangeo-v1
#apt-get install rpm alien
RUN apt-get install -y libaio1 unzip
USER root
WORKDIR /tmp
RUN wget https://download.oracle.com/otn/linux/instantclient/11204/instantclient-basic-linux.x64-11.2.0.4.0.zip
#RUN wget https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
#RUN wget https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
#RUN dpkg -i oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.deb
#RUN dpkg -i oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.deb
#RUN dpkg -i oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.deb
RUN unzip instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    mv instantclient_11_2 /opt/instantclient
RUN rm -f /tmp/oracle-instantclient*.zip
RUN mkdir -p /opt/instantclient/instantclient_11_2/NETWORK/ADMIN
ADD tnsnames.ora /opt/instantclient/instantclient_11_2/NETWORK/ADMIN
ENV ORACLE_HOME=/opt/instantclient/instantclient_11_2 \
    LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH \
    TNS_ADMIN=$ORACLE_HOME/NETWORK/ADMIN \
    PATH=$ORACLE_HOME:$PATH \
    LANG=C.UTF-8
    #NLS_LANGE "SIMPLIFIED CHINESE_CHINA.ZHS16GBK"
RUN fix-permissions /opt/instantclient
RUN fix-permissions $ORACLE_HOME
USER $NB_USER
WORKDIR $HOME
#RUN echo /usr/lib/oracle/11.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient11.2.conf && \
#     ldconfig
#ENV PATH=$PATH:/usr/lib/oracle/11.2/client64/bin
