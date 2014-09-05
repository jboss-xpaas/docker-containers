############################################################
# Dockerfile to build xpaas-zookeeper-docker container image including:
#   - Zookeeper IO v3.4.6
# Based on XPaas Base docker image
# Version: 1.0
############################################################

####### BASE ############
FROM xpaas/xpaas_base:1.0

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
ENV ZOOKEEPER_VERSION 3.4.6
ENV ZOOKEEPER_NAME root
ENV ZOOKEEPER_BINDADDRESS 0.0.0.0
ENV ZOOKEEPER_PROFILES docker

ENV ZOOKEEPER_DATA_DIR /tmp/data/zookeeper
ENV ZOOKEEPER_CLIENT_PORT 2181
ENV ZOOKEEPER_REGISTERED_SERVERS #

####### USERS ############
RUN useradd -m zookeeper ; echo zookeeper: | chpasswd ; usermod -a -G wheel zookeeper

####### ZOOKEEPER ############
WORKDIR /tmp
RUN curl --silent --output zookeeper.tar.gz http://ftp.cixug.es/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz
RUN tar zxf zookeeper.tar.gz
RUN mv zookeeper-$ZOOKEEPER_VERSION zookeeper
RUN mv zookeeper/ /opt/
RUN rm zookeeper.tar.gz


####### ZOOKEEPER CONFIGURATION ############
WORKDIR /opt/zookeeper/etc

RUN echo bind.address=0.0.0.0 >> system.properties
RUN echo zookeeper.environment=docker >> system.properties
RUN echo zookeeper.password.encode=true >> system.properties


# Add a user
# TODO: should ideally come from env vars?
RUN echo >> users.properties 
RUN echo admin=admin,admin >> users.properties 

# Enable logging to standard out
RUN echo log4j.rootLogger=INFO, stdout, osgi:* >> org.ops4j.pax.logging.cfg 


####### HELPER SCRIPTS ###########
WORKDIR /
RUN mkdir -p /jboss/scripts/zookeeper
ADD conf/scripts/zookeeper/startup.sh /jboss/scripts/zookeeper/startup.sh



####### ADD THE SUPERVISOR DAEMON PROGRAMS ###########
WORKDIR /
ADD conf/supervisord/zookeeper.sv.conf /etc/supervisord/conf.d/zookeeper.sv.conf

####### PORT EXPOSING ###########
EXPOSE 2181

####### DEFAULT RUN COMMAND###########
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
