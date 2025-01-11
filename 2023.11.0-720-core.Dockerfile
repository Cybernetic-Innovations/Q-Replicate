FROM docker.artifacts/qlikr:8-core

# Update the repository configuration to use the vault.centos.org mirror
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


# Update and install necessary packages
RUN yum update -y;


ADD /packages/areplicate-2023.11.0-720* /tmp
ADD /packages/areplicate-2023.11.0-720_fileMerge.py /tmp
RUN python3 /tmp/areplicate-2023.11.0-720_fileMerge.py

RUN systemd=no rpm -i /tmp/areplicate-2023.11.0-720.rpm


RUN rm -f /tmp/areplicate*


ENV PATH=/home/stefani/.local/bin:/home/stefani/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/opt/mssql-tools/bin
ENV LD_LIBRARY_PATH=:/opt/microsoft/msodbcsql18/lib64
