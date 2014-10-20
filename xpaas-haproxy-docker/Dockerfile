############################################################
# Dockerfile to build xpaas-base-docker container image including:
#   - Supervisor daemon
#   - Supervisor-stdout
#   - Git client
#   - Python PIP
#   - Net tools
#   - Telnet client
#   - Open SSH server & client
#   - Unzip tool
#   - wget tool
#   - Java 1.7.0 OpenJDK & development package
#   - Maven 3.0.5 & JBoss Nexus repositories configured
# Based on Fedora docker image
# Version: 1.0
############################################################

####### BASE ############
FROM redhat/xpaas_base:1.0

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### BASE VARIABLES ############
ENV HA_HOSTS .0.0.0.0:8080,0.0.0.0:8090

####### BASE SOFTWARE ############
# telnet is required by some fabric command. without it you have silent failures
RUN yum install -y haproxy
RUN yum clean all


####### HELPER SCRIPTS ###########
WORKDIR /
RUN mkdir -p /etc/scripts/haproxy
ADD conf/scripts/haproxy/startup.sh /etc/scripts/haproxy/startup.sh
#ADD conf/scripts/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg

####### ADD THE SUPERVISOR DAEMON PROGRAMS ###########
WORKDIR /
ADD conf/supervisord/haproxy.sv.conf /etc/supervisord/conf.d/haproxy.sv.conf

####### PORT EXPOSING ###########
EXPOSE 5000
EXPOSE 9000


####### DEFAULT RUN COMMAND###########
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

