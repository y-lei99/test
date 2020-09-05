FROM registry.cn-beijing.aliyuncs.com/k8s_test/geonotebook:geopangeo-v1
USER root
#RUN apt-get install rpm alien

RUN apt-get update
RUN apt-get install -y libaio1
RUN apt-get install unzip
RUN apt-get install fastjar
#RUN apt-get install -y vsftpd
#RUN apt-get install -y ftp
WORKDIR /tmp
RUN wget https://download.oracle.com/otn/linux/instantclient/11204/instantclient-basic-linux.x64-11.2.0.4.0.zip
#RUN curl ftp://139.196.50.15/instantclient.tar -u test:test 
#RUN wget https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
#RUN wget https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
#RUN wget https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
#RUN alien oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm
#RUN dpkg -i oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.deb
#RUN dpkg -i oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.deb
#RUN dpkg -i oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.deb
RUN jar xvf instantclient-basic-linux.x64-11.2.0.4.0.zip
RUN mv instantclient_11_2 /opt/instantclient
RUN rm -f /tmp/instantclient*.zip
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
