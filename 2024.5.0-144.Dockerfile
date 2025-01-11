# Use the official CentOS image
FROM cyberneticinnovations/centos:8-core

# Update the repository configuration to use the vault.centos.org mirror
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


# Update and install necessary packages
RUN yum update -y;

#ADD /packages/areplicate-2024.5.0-144.rpm /tmp
ADD /packages/areplicate-2024.5.0-144* /tmp
ADD /packages/fileMerge-areplicate-2024.5.0-144.py /tmp
RUN python3 /tmp/fileMerge-areplicate-2024.5.0-144.py

RUN systemd=no rpm -i /tmp/areplicate-2024.5.0-144.rpm


RUN rm -f /tmp/areplicate*


ENV PATH=/home/stefani/.local/bin:/home/stefani/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/opt/mssql-tools/bin
ENV LD_LIBRARY_PATH=:/opt/microsoft/msodbcsql18/lib64

ENV ReplicateDataFolder=/opt/attunity/replicate/data
ENV ReplicateAdminPassword=AB1gL0ngPa33w0rd
ENV ReplicateRestPort=3552
ADD start_replicate.sh /opt/attunity/replicate/bin/start_replicate.sh
RUN chmod 775 /opt/attunity/replicate/bin/start_replicate.sh
ENTRYPOINT /opt/attunity/replicate/bin/start_replicate.sh ${ReplicateDataFolder} ${ReplicateAdminPassword} ${ReplicateRestPort}  ; tail -f /dev/null
