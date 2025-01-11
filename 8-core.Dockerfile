# Use the official CentOS image
FROM docker.artifacts/qlikr:8

# Update the repository configuration to use the vault.centos.org mirror
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
ENV TZ=America/Chicago

ADD /packages/msodbcsql18-18.2.2.1-1.x86_64.rpm /tmp
ADD /packages/mssql-tools18-18.2.1.1-1.x86_64.rpm /tmp

RUN yum update -y; \
    yum -y install systemd; \
    yum install -y jq wget; \
    yum install -y python3 python3-pip; \
    yum -y install openssl unixODBC; \
    ACCEPT_EULA=Y yum -y install /tmp/msodbcsql18-18.2.2.1-1.x86_64.rpm; \
    ACCEPT_EULA=Y yum -y install /tmp/mssql-tools18-18.2.1.1-1.x86_64.rpm; \
    yum clean all;

RUN rm -f /tmp/msodbcsql18-*.rpm
RUN rm -f /tmp/mssql-tools18-*.rpm



#RUN yum update -y; \
#    yum groupinstall -y "Development Tools"; \
#    yum install -y openssl-devel bzip2-devel libffi-devel zlib-devel wget make jq;

## Download and install Python 3.13.0
#RUN wget https://www.python.org/ftp/python/3.13.0/Python-3.13.0.tgz && \
#    tar -xzf Python-3.13.0.tgz && \
#    cd Python-3.13.0 && \
#    ./configure --enable-optimizations && \
#    make altinstall

#RUN yum install -y wget && yum clean all
#
ADD scripts/versionCheck.sh /
RUN echo 'alias ls="ls --color=auto -lA"' >> ~/.bashrc

CMD [ "./versionCheck.sh" ]
