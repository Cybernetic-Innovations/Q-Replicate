# Use the official CentOS image
FROM centos:latest

# Update the repository configuration to use the vault.centos.org mirror
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*


# Update and install necessary packages
RUN yum update -y; yum clean all;
