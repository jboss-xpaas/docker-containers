 JBoss Wildfly/EAP Docker Image
====================================

This project builds a [docker](http://docker.io/) container for running JBoss Wildfly or JBoss EAP application server.

This image provides a container including:     
* XPaaS Base     
* HTTP daemon     
* JBoss Wildfly 8.1 / JBoss Enterprise Application Platform (EAP) 6.1.0    

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
* **[JBoss startup commands](#JBoss-startup-commands)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts:    
* <code>build.sh</code> Builds the JBoss Wildfly / EAP docker image    
* <code>start.sh</code> Starts a new XPaaS JBoss Wildfly / EAP docker image container    
* <code>stop.sh</code>  Stops the runned XPaaS Wildfly  docker image container    

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
    
    ./start.sh [-i [wildfly,eap]] [-c <container_name>] [-p <root_password>] [-ap <admin_password>]
    Example: ./start.sh -i wildfly -c xpaas_wildfly -p "root123!" -ap "root123!"

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] xpaas/xpaas_wildfly:<version>
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] xpaas/xpaas_eap:<version>

These commands will start a new XPaas Wildfly container with HTTP daemon and Wildfly programs enabled.     

**Notes**           
* If no container name argument is set and image to build is <code>wildfly</code>, it defaults to <code>xpaas-wildfly</code>        
* If no container name argument is set and image to build is <code>eap</code>, it defaults to <code>xpaas-eap</code>
* If no root password argument is set, it defaults to <code>xpaas</code>    
* If no JBoss Wildfly/EAP admin user password argument is set, it defaults to <code>admin123!</code>

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

**Administration console**

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

**Server profiles & configuration, users and roles**

TODO:

- Accesing via SSH:
    
    ssh rooŧ@localhost -p <port> ...
    
- Using a shared volume      

- Configuration artifacts:
    * standalone.xml / other xml files (profiles)
    * users -> connect via SSH & run add-user.sh
    * roles

Deploying web applications into JBoss Application Server
--------------------------------------------------------

TODO

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

JBoss startup commands
----------------------

In order to execute your custom JBoss Command Line Interface (CLI) commands, this container provides
a mechanism that executes all <code>sh</code> script files located at <code>/jboss/scripts/jboss-appserver/startup</code> 
once the application server has been started.

Notes
-----
**JBoss Wildfly/EAP:**     
- The default admin password for Wildfly is <code>admin123!</code>
- The web interface address is bind by default to <code>0.0.0.0</code>     
- The management interface address is bind by default to the docker container IP address

**EAP:**      
- As EAP is a non-community product, in order to build the JBoss EAP image you have to manualy add JBoss EAP ZIP file into <code>bin/</code> directory before building the JBoss EAP docker container image. See the [README.md](bin/README.md)