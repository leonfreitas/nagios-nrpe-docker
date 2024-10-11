FROM rockylinux:9
RUN dnf install epel-release -y \
    && dnf update -y
# Install Required build tools
RUN dnf install -y gcc \
	glibc \
	glibc-common \
	make \
	gettext \
	automake \
	autoconf \
	wget \
	procps \
	openssl-devel \
	pkgconf-pkg-config \
	diffutils \
	net-snmp-perl \
        supervisor        
# Build and Install NRPE Agent
COPY nrpe-4.1.0 /nrpe-4.1.0
WORKDIR /nrpe-4.1.0

# Configure NRPE Agent to adapt it to the system
RUN  ./configure \
     --enable-command-args \
     --with-nrpe-user=nagios \
     --with-nrpe-group=nagios

# Compile, Install NRPE, install config and,
# create nagios user/group
RUN make all \
    && make install-groups-users \
    && make install \
    && make install-config

# Build and Install Nagios Plugins;
COPY nagios-plugins-2.4.2 /nagios-plugins-2.4.2
WORKDIR /nagios-plugins-2.4.2
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios && \
    make && \
    make install

# Create custom plugins for Nagios
COPY custom-plugins /custom-plugins
WORKDIR /custom-plugins
RUN cp * /usr/local/nagios/libexec/ && chmod +x /usr/local/nagios/libexec/* && chown nagios:nagios /usr/local/nagios/libexec/* 

# Define NRPE Service, Port and Protocol
RUN echo "nrpe            5666/tcp                # NRPE Service" >> /etc/services
#
WORKDIR /root
# Add NRPE Startup script
ADD start.sh /
RUN chmod +x /start.sh

CMD [ "/start.sh" ]
