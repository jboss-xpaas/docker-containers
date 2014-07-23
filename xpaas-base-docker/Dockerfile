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
FROM fedora:20

####### MAINTAINER ############
MAINTAINER "JBoss XPaaS Team" "xpass-eng@redhat.com"

####### BASE VARIABLES ############
ENV JAVA_HOME /usr/lib/jvm/jre
ENV ENV_COMMANDS_FILE /etc/profile.d/jboss.sh
ENV M2 /opt/apache-maven/bin
ENV M2_HOME /opt/apache-maven
ENV MAVEN_HOME /opt/apache-maven

####### BASE SOFTWARE ############
# telnet is required by some fabric command. without it you have silent failures
RUN yum install -y net-tools java-1.7.0-openjdk java-devel which telnet unzip openssh-server sudo openssh-clients supervisor wget python-pip git
RUN yum clean all
RUN pip install supervisor-stdout

####### BASE SOFTWARE CONFIGURATION ############

# Configure the SSH daemon
RUN mkdir -p /var/run/sshd
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key

# Configure supervisor
RUN mkdir -p /var/log/supervisord
RUN mkdir -p /etc/supervisord/conf.d
ADD conf/supervisord/supervisord.conf /etc/supervisord.conf

####### MAVEN ############
RUN curl --silent --output /tmp/maven.tar.gz http://apache.rediris.es/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
WORKDIR /tmp
RUN tar -xzvf maven.tar.gz
RUN mv apache-maven-3.0.5/ apache-maven/
RUN mv apache-maven/ /opt/
# Add the custom settings.xml file with JBoss Nexus repositories configured as well.
ADD conf/maven/settings.xml /opt/apache-maven/conf/settings.xml
RUN rm -rf maven.tar.gz

####### SYSTEM PRIVILEGES CONFIGURATION ############
WORKDIR /
# enabling sudo group
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/#Defaults requiretty/' /etc/sudoers

####### SYSTEM CONFIGURATION ############
WORKDIR /
# environment variables for ALL users
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> $ENV_COMMANDS_FILE
RUN echo "export M2_HOME=$M2_HOME" >> $ENV_COMMANDS_FILE
RUN echo "export M2=$M2" >> $ENV_COMMANDS_FILE
RUN echo "export PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH" >> $ENV_COMMANDS_FILE
RUN echo "export MAVEN_OPTS='-Xms256m -Xmx512m'" >> $ENV_COMMANDS_FILE

# useful aliases for ALL users
RUN echo "alias ll='ls -l --color=auto'" >> $ENV_COMMANDS_FILE
RUN echo "alias grep='grep --color=auto'" >> $ENV_COMMANDS_FILE

# Do the profile script executable
RUN chmod +x $ENV_COMMANDS_FILE

####### PORT EXPOSING ###########
# SSH daemon port
EXPOSE 22

####### HELPER SCRIPTS ###########
WORKDIR /
RUN mkdir -p /jboss/scripts
ADD conf/scripts/docker-ip.sh /jboss/scripts/docker-ip.sh

####### CONFIGURE & RUN THE SUPERVISOR DAEMON ###########
ADD conf/scripts/init.sh /jboss/scripts/init.sh
ADD conf/scripts/root-password.sh /jboss/scripts/root-password.sh
ADD conf/scripts/supervisord/start.sh /jboss/scripts/start.sh
ADD conf/scripts/supervisord/restart.sh /jboss/scripts/restart.sh
ADD conf/scripts/supervisord/stop.sh /jboss/scripts/stop.sh

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
