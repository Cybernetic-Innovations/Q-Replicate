FROM cyberneticinnovations/qlikr:2023.11.0-720-core

# Update the repository configuration to use the vault.centos.org mirror
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


# Update and install necessary packages
RUN yum update -y;


ENV ReplicateDataFolder=/opt/attunity/replicate/data
ENV ReplicateAdminPassword=AB1gL0ngPa33w0rd
ENV ReplicateRestPort=3552
ADD start_replicate.sh /opt/attunity/replicate/bin/start_replicate.sh
RUN chmod 775 /opt/attunity/replicate/bin/start_replicate.sh

ADD license.json /

ENTRYPOINT /opt/attunity/replicate/bin/start_replicate.sh ${ReplicateDataFolder} ${ReplicateAdminPassword} ${ReplicateRestPort}  ; tail -f /dev/null
