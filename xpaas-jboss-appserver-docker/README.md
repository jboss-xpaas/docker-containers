 JBoss Wildfly/EAP Docker Image
====================================

This project builds a [docker](http://docker.io/) container for running JBoss Wildfly or JBoss EAP application server.

This image provides a container including:     
* XPaaS Base     
* HTTP daemon     
* JBoss Wildfly 8.1 / JBoss Enterprise Application Platform (EAP) 6.1.1    

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Connection to a container using SSH](#connection-to-a-container-using-SSH)**
* **[Starting, stopping and restarting the HTTPD daemon](#starting,-stopping-and-restarting-the-HTTPD-daemon)**
* **[Starting, stopping and restarting JBoss Application Server](#starting,-stopping-and-restarting-JBoss-Application-Server)**
* **[Acessing JBoss Application Server HTTP interface](#acessing-JBoss-Application-Server-HTTP-interface)**
* **[Configuring JBoss Application Server](#configuring-JBoss-Application-Server)**
* **[Deploying web applications into JBoss Application Server](#deploying-web-applications-into-JBoss-Application-Server)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[JBoss startup scripts](#JBoss-startup-scripts)**
* **[Experimenting](#Experimenting)**
* **[Extending this docker image](#extending-this-docker-image)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts:    
* <code>build.sh</code> Builds the JBoss Wildfly / EAP docker image    
* <code>start.sh</code> Starts a new XPaaS JBoss Wildfly / EAP docker container based on this image    
* <code>stop.sh</code>  Stops the runned XPaaS Wildfly  docker container    

Building the docker container
-----------------------------

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

First, clone the repository:
    
    git clone git@github.com:pzapataf/xpaas-docker-containers.git
    cd xpaas-docker-containers/xpaas-jboss-appserver-docker
    
**Creating the JBoss Wildly container**
    
    ./build.sh wildfly

**Creating the JBoss EAP container**
    
    ./build.sh eap

Running the container
---------------------

To run a new image container from XPaaS JBoss Wildfly/EAP  run:
    
    ./start.sh [-i [wildfly,eap]] [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-args <run_arguments>] [ --conf-file <conf_file>] 
    Example: ./start.sh -i wildfly -c xpaas_wildfly -p "root123!" -ap "root123!"

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_HTTP_PORT="<http_port>"] [-e JBOSS_HTTPS_PORT="<https_port>"] [-e JBOSS_AJP_PORT="<ajp_port>"] [-e JBOSS_MGMT_HTTP_PORT="<mgmt_http_port>"] [-e JBOSS_MGMT_HTTPS_PORT="<mgmt_https_port>"] [-e JBOSS_ARGUMENTS="<run_arguments>"] xpaas/xpaas_wildfly:<version>
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_HTTP_PORT="<http_port>"] [-e JBOSS_HTTPS_PORT="<https_port>"] [-e JBOSS_AJP_PORT="<ajp_port>"] [-e JBOSS_MGMT_HTTP_PORT="<mgmt_http_port>"] [-e JBOSS_MGMT_HTTPS_PORT="<mgmt_https_port>"] [-e JBOSS_ARGUMENTS="<run_arguments>"] xpaas/xpaas_eap:<version>

These commands will start a new XPaas Wildfly container with HTTP daemon and Wildfly programs enabled.     

**Notes**           
* If no container name argument is set and image to build is <code>wildfly</code>, it defaults to <code>xpaas-wildfly</code>        
* If no container name argument is set and image to build is <code>eap</code>, it defaults to <code>xpaas-eap</code>
* If no root password argument is set, it defaults to <code>xpaas</code>    
* If no JBoss Wildfly/EAP admin user password argument is set, it defaults to <code>admin123!</code>

**Environment variables**

These are the environment variables supported when running the JBoss Wildfly/EAP container:       

* <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH     
* <code>JBOSS_ADMIN_PASSWORD</code> - The JBoss <code>admin</code> user password      
* <code>JBOSS_STANDALONE_CONF_FILE</code> - The JBoss configuration file to use when running in standalone mode, default to <code>standalone.xml</code> (default profile)       
* <code>JBOSS_ARGUMENTS</code> - The arguments to pass when executing <code>standalone.sh</code> startup script     
* <code>JBOSS_BIND_ADDRESS</code> - The server bind address, default to <code>0.0.0.0</code>     
* <code>JBOSS_HTTP_PORT</code> - The server HTTP port, default to <code>8080</code>     
* <code>JBOSS_HTTPS_PORT</code> - The server HTTPS port, default to <code>8443</code>     
* <code>JBOSS_AJP_PORT</code> - The server AJP port, default to <code>8009</code>     
* <code>JBOSS_MGMT_HTTP_PORT</code> - The server HTTP management port, default to <code>9990</code> (Wildly) or <code>9999</code> (EAP)      
* <code>JBOSS_MGMT_HTTPS_PORT</code> - The server HTTPS management port, default to <code>9993</code> (Wildly) or <code>9443</code> (EAP)      

**Standalone mode - Profiles**     

If running the JBoss server in standalone mode, you can run it using one of the default profiles <code>default, full, full-ha, ha, osgi</code>      
By default, the configuration file used for running JBoss server is <code>standalone.xml</code>     
You can change the default configuration file to use (changing the profile for the server) by setting the environment variable <code>JBOSS_STANDALONE_CONF_FILE</code> 

      # Use the full profile.
      # If running using start.sh script.
      ./start.sh -i wildfly -c xpaas_wildfly -p "root123!" -ap "root123!" -conf-file =standalone-full.xml"
      
      # Use the full profile.
      # If running using docker command
      docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="root123!"]  [-e JBOSS_ADMIN_PASSWORD="root123!"] [-e JBOSS_STANDALONE_CONF_FILE="standalone-full.xml"] xpaas/xpaas_wildfly:<version>


**Custom JBoss Wildfly/EAP startup script**
 
By default JBoss Wildfly/EAP is run using:
    
    standalone.sh --server-config=$JBOSS_STANDALONE_CONF_FILE -b $JBOSS_BIND_ADDRESS -Djboss.http.port=$JBOSS_HTTP_PORT -Djboss.https.port=$JBOSS_HTTPS_PORT -Djboss.ajp.port=$JBOSS_AJP_PORT -Djboss.management.http.port=$JBOSS_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_MGMT_HTTPS_PORT -Djboss.bind.address.management=$DOCKER_IP $JBOSS_ARGUMENTS
    
You can override the way it's started up by overriding this script inside the docker container:

    conf/scripts/jboss-appserver/start-jboss.sh

**Disabling autostart for JBoss Wildfly/EAP**      

If you don't want by default that JBoss Wildfly/EAP container is started when running the docker container, you can modify the supervisor daemon configuration file:       
* This file is located at <code>/etc/supervisord/conf.d/jboss-appserver.sv.conf</code> inside the container.        
* In oder to disable autostart, modify the attribute <code>autostart</code> using the value <code>false</code>       
* Then you can start/stop the JBoss server on demand. See **[Starting, stopping and restarting the HTTPD daemon](#starting,-stopping-and-restarting-the-HTTPD-daemon)**

Connection to a container using SSH
-----------------------------------

When running a new container over this docker image, the SSH daemon is started by default and waiting for connections.     

In order to connect to the container using SSH you must know the container binding SSH port. If you type:

    docker ps
    
you should see the port mappings for each docker container. For example you may see something like this in the PORTS section....

    0.0.0.0:49001->22/tcp
    
This means that from outside the docker container; you need to use port 49001 to access port 22 inside the container. Note this number changes for each container; outside of each docker container there are different ports that forward to the 22 port.     

So if the port number is 49001 then you can type something like this:

    ssh root@localhost -p 49001
    
**Notes**        
* By default, the only available user to connect using SSH is <code>root</code>     
* By default, the <code>root</code> user password is <code>xpaas</code>     
* You can change the default root password when running the container. See **[Running the container](#running-the-container)**      

Starting, stopping and restarting the HTTP daemon
-------------------------------------------------

To start the HTTP daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh httpd

To stop the HTTP daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh httpd

To restart the HTTP daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh httpd

Starting, stopping and restarting JBoss Application Server
----------------------------------------------------------

To start JBoss Wildfly/EAP run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh wildfly
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh eap

To stop JBoss Wildfly/EAP run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh wildfly
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh eap

To restart JBoss Wildfly/EAP run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh wildfly
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh eap

You can modify the way it's started by overriding this script inside the docker container:

    conf/scripts/jboss-appserver/start-jboss.sh

Acessing JBoss Application Server HTTP interface
------------------------------------------------

By default, the JBoss Wildfly/EAP HTTP interface bind address points to <code>0.0.0.0</code>, so you can discover your container port mapping for port <code>8080</code> 
and type in you browser:
 
    http://localhost:<binding_port>
    
Where <code>&lt;binding_port&gt;</code> can be found by running:

    docker ps -a
    
Another option if about accessing the Wildfly HTTP interface using the container IP address to, that can be found by running:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>
    
Then you can type this URL:

    http://<container_ip_address>:8080
    
    
Configuring JBoss Application Server
------------------------------------

**HTTP Administration console**

In order to access the Administration console of your JBoss Wildfly/EAP you have two options:     

You can discover your container port mapping for port <code>9990</code> and type in you browser:
 
    http://localhost:<binding_port>
    
Where <code>&lt;binding_port&gt;</code> can be found by running:

    docker ps -a

Or another option is about discovering the container IP address first.     

The container IP address can be found by running:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>
    
Once discovered the IP address for the JBoss Wildfly/EAP running container, you can access the administration console in the URL:

    http://<container_ip>:9990

**Acessing via SSH**

You can configure your JBoss Wildfly/EAP by accessing command line via SSH.      
First step is connecting to the running container using SSH. See [Connection to a container using SSH].      
Once connected, you can enter the JBoss CLI by running:

    /jboss/scripts/jboss-appserver/jboss-cli.sh


Once connected, you can create users too by running:

    /opt/jboss-appserver/bin/add-user-sh

Deploying web applications into JBoss Application Server
--------------------------------------------------------

There are several ways to deploy a web application into your JBoss Wildfly/EAP container.      

**Using HTTP administration console**      
You can access the HTTP administration console and deploy you files using this interface.

**Using JBoss CLI**       
You can access the container via SSH and copy the applciation to deploy into a temporal folder in the container (using <code>scp</code>) and deploy it using JBoss CLI

Logging
-------

You can see all logs generated by supervisor daemon & programs by running:

    docker logs <container_id>
    
You can see only the HTTP daemon logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/httpd-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/httpd-stderr.log

You can see only JBoss Wildfly/EAP logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stderr.log

Stopping the container
----------------------

To stop the previous image container run using <code>start.sh</code> script just type:

    ./stop.sh

JBoss startup scripts
----------------------

In order to execute your custom JBoss Command Line Interface (CLI) commands, this container provides
a mechanism that executes all <code>sh</code> script files located at <code>/jboss/scripts/jboss-appserver/startup</code> 
once the application server has been started.     

These scripts will be executed only once (on first container run), in order to allow the image developer to add custom 
initial configurations for JBoss Wildfly/EAP before doing any deploy.     

These scripts allows to configure the JBoss server once being run by first time.      

NOTES:     
* Those scripts will be executed using filename alphabetically ascendant sort order       
* The reason why CLI commands are executed once JBoss is up is because the configuration file that CLI commands will modify depends on the startup script (profile). In addition, note that is JBoss server is not up, the CLI interface is not available too.      

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t xpaas/xpaas_wildfly /bin/bash # For JBoss Wildfly distribution
    docker run -P -i -t xpaas/xpaas_eap /bin/bash # For JBoss EAP distribution
    
You can then noodle around the container and run stuff & look at files etc.

Extending this docker image
---------------------------

You can create a new container that uses this docker image as base:

    FROM xpaas/xpaas_eap:<version> # For EAP case
    FROM xpaas/xpaas_wildfly:<version> # For Wildfly case
    
As extending this image, the JBoss Wildfly/EAP container is run by default, you can add your custom configuration changes
or deployments via CLI.     

You can place a <code>sh</code> that runs some JBoss CLI commands in the following path: <code>/jboss/scripts/jboss-appserver/startup</code>.
This script will be executed only once just after container has been started for first time.

Notes
-----
**JBoss Wildfly/EAP:**     
* The default admin password for Wildfly is <code>admin123!</code>      
* The web interface address is bind by default to <code>0.0.0.0</code>, you can change it using the environemnt variable <code>JBOSS_BIND_ADDRESS</code>     
* There is a MySQL JBDC driver module pre-installed      
* There is no support for domain mode
* There is no support for clustering

**JBoss Wildfly/EAP ports:**            
* The HTTP port by default is <code>8080</code>, you can change it using the environemnt variable <code>JBOSS_HTTP_PORT</code>      
* The HTTPS port by default is <code>8443</code>, you can change it using the environemnt variable <code>JBOSS_HTTPS_PORT</code>      
* The AJP port by default is <code>8009</code>, you can change it using the environemnt variable <code>JBOSS_AJP_PORT</code>      
* The management HTTP port by default is <code>9990</code> (Wildfly) or <code>9999</code> (EAP) , you can change it using the environemnt variable <code>JBOSS_MGMT_HTTP_PORT</code>      
* The management HTTPS port by default is <code>9993</code> (Wildfly) or <code>9443</code> (EAP) , you can change it using the environemnt variable <code>JBOSS_MGMT_HTTPS_PORT</code>      
* The management interface address is bind by default to the docker container IP address
* NOTE: This ports can be changed for internal use, but the docker container always exposes ports: <code>80,8080,8443,9990,9999</code>        

**EAP:**      
* As EAP is a non-community product, in order to build the JBoss EAP image you have to manualy add JBoss EAP ZIP file into <code>bin/</code> directory before building the JBoss EAP docker container image. See the [README.md](bin/README.md)
