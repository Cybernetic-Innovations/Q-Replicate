FROM centos:8

RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum -y install systemd; yum clean all;

RUN yum -y install openssl
RUN yum -y install unixODBC

ADD areplicate-2023.11.0-720.x86_64.rpm /tmp
ADD msodbcsql18-18.2.2.1-1.x86_64.rpm /tmp
ADD mssql-tools18-18.2.1.1-1.x86_64.rpm /tmp

RUN systemd=no rpm -i /tmp/areplicate-2023.11.0-720.x86_64.rpm

#RUN systemd=no yum -y install /tmp/areplicate-2023.11.0-547.x86_64.rpm
RUN ACCEPT_EULA=Y yum -y install /tmp/msodbcsql18-18.2.2.1-1.x86_64.rpm
RUN ACCEPT_EULA=Y yum -y install /tmp/mssql-tools18-18.2.1.1-1.x86_64.rpm 

###
#RUN rpm -i http://10.117.2.29:8080/replicate/2023.5.0-322-baseline/areplicate-2023.5.0-322.x86_64.rpm
#RUN ACCEPT_EULA=Y rpm -i https://packages.microsoft.com/rhel/8/prod/Packages/m/msodbcsql18-18.2.2.1-1.x86_64.rpm
#RUN ACCEPT_EULA=y rpm -i https://packages.microsoft.com/rhel/8/prod/Packages/m/mssql-tools18-18.2.1.1-1.x86_64.rpm
#RUN ACCEPT_EULA=Y rpm -i http://10.117.2.29:8080/dbdrivers/msodbcsql18-18.2.2.1-1.x86_64.rpm
###

ENV PATH=/home/stefani/.local/bin:/home/stefani/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/opt/mssql-tools/bin
ENV LD_LIBRARY_PATH=:/opt/microsoft/msodbcsql18/lib64

#ADD areplicate-*.rpm /tmp/
#RUN yum -y install /tmp/areplicate-*.rpm
#RUN yum clean all
#RUN rm -f /tmp/areplicate-*.rpm

ENV ReplicateDataFolder=/opt/attunity/replicate/data
ENV ReplicateAdminPassword=AB1gL0ngPa33w0rd
ENV ReplicateRestPort=3552
ADD start_replicate.sh /opt/attunity/replicate/bin/start_replicate.sh
RUN chmod 775 /opt/attunity/replicate/bin/start_replicate.sh
ENTRYPOINT /opt/attunity/replicate/bin/start_replicate.sh ${ReplicateDataFolder} ${ReplicateAdminPassword} ${ReplicateRestPort}  ; tail -f /dev/null
