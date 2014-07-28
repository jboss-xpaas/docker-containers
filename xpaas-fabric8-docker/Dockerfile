############################################################
# Dockerfile to build xpaas-fabric8-docker container image including:
#   - Fabric8 IO v1.1.0.CR5
# Based on XPaas Base docker image
# Version: 1.0
############################################################

####### BASE ############
FROM xpaas/xpaas_base:1.0

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### ENVIRONEMNT ############
ENV FABRIC8_VERSION 1.1.0.CR5
ENV FABRIC8_KARAF_NAME root
ENV FABRIC8_BINDADDRESS 0.0.0.0
ENV FABRIC8_PROFILES docker

####### USERS ############
RUN useradd -m fabric8 ; echo fabric8: | chpasswd ; usermod -a -G wheel fabric8

####### FABRIC8 ############
WORKDIR /tmp
RUN curl --silent --output fabric8.zip https://repository.jboss.org/nexus/service/local/repositories/fs-releases-to-central/content/io/fabric8/fabric8-karaf/$FABRIC8_VERSION/fabric8-karaf-$FABRIC8_VERSION.zip
RUN unzip -q fabric8.zip 
RUN mv fabric8-karaf-$FABRIC8_VERSION fabric8-karaf
RUN mv fabric8-karaf/ /opt/
RUN rm fabric8.zip


####### FABRIC8 CONFIGURATION ############
WORKDIR /opt/fabric8-karaf/etc
# Remove the karaf.name by default so we can default it from env vars
RUN sed -i '/karaf.name=root/d' system.properties 

RUN echo bind.address=0.0.0.0 >> system.properties
RUN echo fabric.environment=docker >> system.properties
RUN echo zookeeper.password.encode=true >> system.properties

# Remove the karaf.delay.console=true to disable the progress bar
RUN sed -i '/karaf.delay.console=true/d' config.properties 
RUN echo karaf.delay.console=false >> config.properties

# Add a user
# TODO: should ideally come from env vars?
RUN echo >> users.properties 
RUN echo admin=admin,admin >> users.properties 

# Enable logging to standard out
RUN echo log4j.rootLogger=INFO, stdout, osgi:* >> org.ops4j.pax.logging.cfg 

WORKDIR /opt/fabric8-karaf
RUN mkdir -p data/log
RUN echo >> data/log/karaf.log

####### HELPER SCRIPTS ###########
WORKDIR /
RUN mkdir -p /jboss/scripts/fabric8
ADD conf/scripts/fabric8/startup.sh /jboss/scripts/fabric8/startup.sh

####### ADD THE SUPERVISOR DAEMON PROGRAMS ###########
WORKDIR /
ADD conf/supervisord/fabric8.sv.conf /etc/supervisord/conf.d/fabric8.sv.conf

####### PORT EXPOSING ###########
EXPOSE 1099
EXPOSE 2181
EXPOSE 8101
EXPOSE 8181
EXPOSE 9300
EXPOSE 9301 
EXPOSE 44444
EXPOSE 61616

####### DEFAULT RUN COMMAND###########
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
