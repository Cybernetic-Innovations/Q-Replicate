#!/bin/bash

# Expect no parameters, but needs a drivers file.

dockerfile=temp_dockerfile
write_header()
{
echo "Writing the installation for replicate"
cat > $dockerfile << EOF
FROM centos

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

ENV PATH=$PATH:/opt/mssql-tools/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/microsoft/msodbcsql18/lib64

#ADD areplicate-*.rpm /tmp/
#RUN yum -y install /tmp/areplicate-*.rpm
#RUN yum clean all
#RUN rm -f /tmp/areplicate-*.rpm

ENV ReplicateDataFolder /opt/attunity/replicate/data
ENV ReplicateAdminPassword ""
ENV ReplicateRestPort 3552
ADD start_replicate.sh /opt/attunity/replicate/bin/start_replicate.sh
RUN chmod 775 /opt/attunity/replicate/bin/start_replicate.sh
EOF

license=""
if [ -f license.json ]; then
license="license.json"
echo "Adding license file to Dockerfile"
echo "ADD $license /" >> $dockerfile
fi

cat >> $dockerfile << EOF
ENTRYPOINT /opt/attunity/replicate/bin/start_replicate.sh \${ReplicateDataFolder} \${ReplicateAdminPassword} \${ReplicateRestPort} $license ; tail -f /dev/null
EOF
}

check_driver_file_exists()
{
  filename=$1
  driver=$2
  if [ -z $filename ]; then
    echo "No file is specified in the drivers file for driver '$driver'."
    rm -f $dockerfile
    return 1
  fi
  if [ ! -f $filename ]; then
    echo "File '$filename', that is specified in the drivers file for '$driver', doesn't exist."
    rm -f $dockerfile
    return 1
  fi
}

check_necessary_file_exists()
{
  filename=$1
  driver=$2
  if [ ! -f $filename ]; then
    echo "File '$filename', that is necessary for the installation of '$driver', doesn't exist."
    rm -f $dockerfile
    return 1
  fi
}

install_sql_server()
{
filename=$1
version=$2
cat >> $dockerfile << EOF
ADD $filename /
RUN ACCEPT_EULA=Y yum -y --nogpgcheck install $filename
RUN ln -s /opt/microsoft/msodbcsql/lib64/libmsodbcsql-$version.so.* /opt/microsoft/msodbcsql/lib64/libmsodbcsql-$version.so.0.0
ENV LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/microsoft/msodbcsql/lib64
RUN sed -i "/libmsodbcsql-$version.so.*/c\Driver=/opt/microsoft/msodbcsql/lib64/libmsodbcsql-$version.so.0.0" /etc/odbcinst.ini
RUN rm -f $filename
EOF
}

install_oracle()
{
check_necessary_file_exists "oracleclient.rsp" "oracle$version" || return $?
filename=$1
version=$2
cat >> $dockerfile << EOF
ADD oracleclient.rsp /oracleclient.rsp
RUN yum install -y libaio
ADD $filename /
RUN unzip $filename
RUN usermod -G attunity attunity
RUN mkdir /opt/oracle && chown -R attunity:attunity /opt/oracle
USER attunity
RUN /client/runInstaller -silent -ignorePrereq -waitforcompletion -responseFile /oracleclient.rsp
USER root
RUN /opt/oracle/oraInventory/orainstRoot.sh
ENV ORACLE_HOME=/opt/oracle/$version/client
ENV LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/oracle/$version/client
RUN rm -rf $filename client oracleclient.rsp
EOF
}

install_mysql()
{
filename=$1
version=$2
cat >> $dockerfile << EOF
ADD $filename /
RUN yum install -y $filename
RUN rm -f $filename
RUN echo "[MySQL]" >> /etc/odbcinst.ini
RUN echo "Description     = ODBC for MySQL" >> /etc/odbcinst.ini
RUN echo "Driver          = /usr/lib/libmyodbc5.so" >> /etc/odbcinst.ini
RUN echo "Setup           = /usr/lib/libodbcmyS.so" >> /etc/odbcinst.ini
RUN echo "Driver64        = /usr/lib64/libmyodbc5.so" >> /etc/odbcinst.ini
RUN echo "Setup64         = /usr/lib64/libodbcmyS.so" >> /etc/odbcinst.ini
RUN echo "FileUsage       = 1" >> /etc/odbcinst.ini
EOF
}

rm -f Dockerfile
write_header 

mv $dockerfile Dockerfile
