JBoss Wildfly/EAP Docker Image
==============================

This project builds a [docker](http://docker.io/) container for running JBoss Wildfly or JBoss EAP application server.

This image provides a container including:     
* HTTP daemon     
* JBoss Wildfly 8.1 / JBoss Enterprise Application Platform (EAP) 6.1.1    

An its based on XPaaS Base docker image.

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Connection to a container using SSH](#connection-to-a-container-using-ssh)**
* **[Starting, stopping and restarting the HTTPD daemon](#starting,-stopping-and-restarting-the-httpd-daemon)**
* **[Starting, stopping and restarting JBoss Application Server](#starting,-stopping-and-restarting-jboss-application-server)**
* **[Acessing JBoss Application Server HTTP interface](#acessing-jboss-application-server-http-interface)**
* **[Configuring JBoss Application Server](#configuring-jboss-application-Server)**
* **[Deploying web applications into JBoss Application Server](#deploying-web-applications-into-jboss-application-server)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[JBoss startup scripts](#jboss-startup-scripts)**
* **[Experimenting](#experimenting)**
* **[Extending this docker image](#extending-this-docker-image)**
* **[Notes](#notes)**
* **[Upgrading JBoss Wildfly/EAP versions](#upgrading-jboss-eildfly/eap-versions)**

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

NOTE: See section **[Notes](#notes)** for JBoss EAP case. The binaries are not provided in this image.     

Running the container
---------------------

In order to run a JBoss Wildfly/EAP docker container you have two options:     

* Running using the <code>start.sh</code> control script and using the applicable script arguments       
* Running the <code>docker</code> command directly and setting the applicable environment variables       

It's important to note that this container supports the startup of JBoss Wildfly/EAP intance in one of these three modes:     

* **STANDALONE mode** - Single server instance, single process, not managed by others       
* **DOMAIN CONTROLLER mode** - Single server domain controller instance. This instance, by default, does not run any server. It's used to manage the other server host instances in the managed domain       
* **DOMAIN HOST mode** - Single server domain host instance. This instance runs by default several servers that are managed from single domain controller instance       

**Standalone mode**     

For many use cases, the centralized management capability available via a managed domain is not necessary. For these use cases, a JBoss Application Server 7 instance can be run as a "standalone server". A standalone server instance is an independent process.       

If more than one standalone instance is launched and multi-server management is desired, it is the user's responsibility to coordinate management across the servers. For example, to deploy an application across all of the standalone servers, the user would need to individually deploy the application on each server.      

**Running a standalone instance**       

To run a new container from XPaaS JBoss Wildfly/EAP in standalone mode run:
    
    # NOTE: Type "./start.sh -h" to see all available script arguments.
    ./start.sh [-i [wildfly,eap]] [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-args <run_arguments>] [ --conf-file <conf_file>] 
    
    # Example: Running a JBoss Wildfly container named "xpaas_wildfly" using all default arguments 
    ./start.sh -i wildfly -c xpaas_wildfly
    
    # Example: Running a JBoss EAP container named "xpaas_eap" using all default arguments 
    ./start.sh -i eap -c xpaas_eap
    
    # Example: Running a JBoss Wildfly container named "xpaas_wildfly" using a custom root and server administration password
    ./start.sh -i wildfly -c xpaas_wildfly -p "myrootpass" -ap "myadminpass"

Or you can try it out via docker command directly:

    # Note: See environment variables section to discover the available environment variables when running this docker container
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] xpaas/xpaas_wildfly
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly container named "xpaas_wildfly" using all default arguments 
    docker run -P -d --name xpaas_wildfly xpaas/xpaas_wildfly
    
    # Example: Running a JBoss EAP container named "xpaas_eap" using all default arguments 
    docker run -P -d --name xpaas_eap xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly container named "xpaas_wildfly" using a custom root and server administration password
    docker run -P -d --name xpaas_wildfly -e ROOT_PASSWORD="myrootpass" -e JBOSS_ADMIN_PASSWORD="myadminpass" xpaas/xpaas_wildfly

In addition you can run the container using any of the server **profiles** rather than the <code>default</code> one: <code>full, full-ha, ha, osgi</code>      

By default, the configuration file used for running JBoss server is <code>standalone.xml</code> but you can change the default configuration file to use (changing the profile for the server) by setting the environment variable <code>JBOSS_STANDALONE_CONF_FILE</code> 

    # Running using start.sh script (full profile)
    ./start.sh -i wildfly -c xpaas_wildfly -conf-file =standalone-full.xml"
    
    # Running using docker command (full profile)
    docker run -P -d --name <container_name> -e JBOSS_STANDALONE_CONF_FILE="standalone-full.xml" xpaas/xpaas_wildfly

**Domain mode**     

One of the primary new features of JBoss Wildfly/EAP is the ability to manage multiple JBoss Wildfly/EAP instances from a single control point.       

A collection of such servers is referred to as the members of a "domain" with a single Domain Controller process acting as the central management control point. 
All of the JBoss Wildfly/EAP instances in the domain share a common management policy, with the Domain Controller acting to ensure that each server is configured according to that policy. 
Domains can span multiple physical (or virtual) machines, with all JBoss Wildfly/EAP instances on a given host under the control of a special Host Controller process. 
One Host Controller instance is configured to act as the central Domain Controller. The Host Controller on each host interacts with the Domain Controller to control the lifecycle of the application server instances running on its host and to assist the Domain Controller in managing them.      

The following is an example managed domain topology:      

![Managed domain topology](eap-domain.png)

So in order to run a managed domain you have to run:    

1.- The domain host controller docker container first      
2.- Run the number of desired domain host docker containers (that will be managed by the previous domain host controller instance)      

Notes about domain mode:        

* A JBoss Wildfly/EAP JMX administration user is automatically created for domain controller/hosts authentication/authorization. The username is <code>adminjmx</code> and the password is <code>adminjmx123!</code>       
* The domain controller, master host and managed hosts are configured using the default configuration, feel free to change it. See next bullets to get the details        
* By default, a single domain controller host is started with two server groups: <code>main-server-group</code> (<code>full</code> profile) and <code>other-server-group</code> (<code>full-ha</code> profile)        
* By default, the domain controller does not start any server (by default uses <code>%lt;JBOSS_HOME&gt;/domain/configuration/host-master.xml</code>)    
* The domain managed hosts must specify the domain controller host IP address and port when running the container in order to connect to that controller instance      
* By default, each domain managed host starts two servers by default: <code>server-one</code> (group <code>main-server-group</code>) and <code>server-two</code> (group <code>other-server-group</code>) (by default uses <code>%lt;JBOSS_HOME&gt;/domain/configuration/host-slave.xml</code>)         
    
**Running a domain controller host**

So first run a new container from XPaaS JBoss Wildfly/EAP in domain mode used as a domain controller host:      
    
    # NOTE: Type "./start.sh -h" to see all available script arguments.
    ./start.sh [-i [wildfly,eap]] -d [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-args <run_arguments>]  
    
    # Example: Running a JBoss Wildfly domain controller host instance named "domain-controller" using all default arguments 
    ./start.sh -i wildfly -c domain-controller -d
    
    # Example: Running a JBoss EAP domain controller host instance named "domain-controller" using all default arguments 
    ./start.sh -i eap -c domain-controller -d
    
    # Example: Running a JBoss Wildfly domain controller host instance named "domain-controller" using a custom root and server administration password 
    ./start.sh -i wildfly -c domain-controller -d -p "myrootpass" -ap "myadminpass"

Running this command will start a domain host controller instance, and the container IP address will be displayed as script output:       

    Server started in 172.17.0.35

Or you can try it out via docker command directly:

    # Note: See environment variables section to discover the available environment variables when running this docker container
    # Note: To run the container as a domain controller you must set the environment variable JBOSS_MODE the value DOMAIN
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_MODE="DOMAIN"] xpaas/xpaas_wildfly
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_MODE="DOMAIN"] xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly domain controller host named "domain-controller" using all default arguments 
    docker run -P -d --name domain-controller -e JBOSS_MODE="DOMAIN" xpaas/xpaas_wildfly
    
    # Example: Running a JBoss EAP domain controller host named "domain-controller" using all default arguments 
    docker run -P -d --name domain-controller -e JBOSS_MODE="DOMAIN" xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly container named "domain-controller" using a custom root and server administration password
    docker run -P -d --name domain-controller -e ROOT_PASSWORD="myrootpass" -e JBOSS_ADMIN_PASSWORD="myadminpass" -e JBOSS_MODE="DOMAIN" xpaas/xpaas_wildfly


**Running a domain managed host**

Once a JBoss Wildfly/EAP domain controller host container has been started, you can run several JBoss Wildfly/EAP container used as domain managed hosts by setting the IP address and native management port of the controller         

Now you can run several domain host instances that are managed by the previously started domain controller host in address <code>172.17.0.35</code> and default port <code>9999</code>:      

    ./start.sh [-i [wildfly,eap]] -dh <controller_ip>:<controller_port> [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-args <run_arguments>]  
    
    # Example: Running a JBoss Wildfly domain host instance named "domain-host1" using all default arguments 
    ./start.sh -i wildfly -c domain-host1 -dh 172.17.0.35:9999
    
    # Example: Running a JBoss EAP domain host instance named "domain-host1" using all default arguments 
    ./start.sh -i eap -c domain-host1 -dh 172.17.0.35:9999
    
    # Example: Running a JBoss Wildfly domain host instance named "domain-host1" using a custom root and server administration password 
    ./start.sh -i wildfly -c domain-host1 -dh 172.17.0.35:9999 -p "myrootpass" -ap "myadminpass"

Or you can try it out via docker command directly:

    # Note: See environment variables section to discover the available environment variables when running this docker container
    # Note: To run the container as a domain controller you must set the environment variable JBOSS_MODE the value DOMAIN-HOST and set the controller IP address and port too using JBOSS_DOMAIN_MASTER_ADDR and JBOSS_DOMAIN_MASTER_PORT respectively
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_MODE="DOMAIN-HOST"] [-e JBOSS_DOMAIN_MASTER_ADDR=<controller_address>] [ -e JBOSS_DOMAIN_MASTER_PORT=<controller_port>] xpaas/xpaas_wildfly
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_ADMIN_PASSWORD="<jboss_admin_password>"] [-e JBOSS_BIND_ADDRESS="<bind_address>"] [-e JBOSS_MODE="DOMAIN-HOST"] [-e JBOSS_DOMAIN_MASTER_ADDR=<controller_address>] [ -e JBOSS_DOMAIN_MASTER_PORT=<controller_port>] xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly domain host named "domain-host1" using all default arguments 
    docker run -P -d --name domain-host1 -e JBOSS_MODE="DOMAIN-HOST" -e JBOSS_DOMAIN_MASTER_ADDR=172.17.0.35 -e JBOSS_DOMAIN_MASTER_PORT=9999 xpaas/xpaas_wildfly
    
    # Example: Running a JBoss EAP domain  host named "domain-host1" using all default arguments 
    docker run -P -d --name domain-host1 -e JBOSS_MODE="DOMAIN-HOST" -e JBOSS_DOMAIN_MASTER_ADDR=172.17.0.35 -e JBOSS_DOMAIN_MASTER_PORT=9999 xpaas/xpaas_eap
    
    # Example: Running a JBoss Wildfly domain host instance named "domain-host1" using a custom root and server administration password
    docker run -P -d --name domain-host1 -e ROOT_PASSWORD="myrootpass" -e JBOSS_ADMIN_PASSWORD="myadminpass" -e JBOSS_MODE="DOMAIN-HOST" -e JBOSS_DOMAIN_MASTER_ADDR=172.17.0.35 -e JBOSS_DOMAIN_MASTER_PORT=9999 xpaas/xpaas_wildfly

**Environment variables**

This section describes the environment variables supported when running the JBoss Wildfly/EAP container using the <code>docker</code> command.       

These are global for all container run modes:      
* <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH     
* <code>JBOSS_ADMIN_PASSWORD</code> - The JBoss <code>admin</code> user password      
* <code>JBOSS_MODE</code> - The server mode ro use. The possible values are:      

            - STANDALONE - Use standalone mode. This is the default value for this variable if not set       
            - DOMAIN - Use domain mode. This server instance will be the domain controller       
            - DOMAIN-HOST - Use domain mode. This server instance will be a domain host       

* <code>JBOSS_ARGUMENTS</code> - The arguments to pass when executing <code>standalone.sh</code> startup script     
* <code>JBOSS_BIND_ADDRESS</code> - The server bind address, default to <code>0.0.0.0</code>     

These are specific for server ports:     
* <code>JBOSS_HTTP_PORT</code> - The server HTTP port, default to <code>8080</code>     
* <code>JBOSS_HTTPS_PORT</code> - The server HTTPS port, default to <code>8443</code>     
* <code>JBOSS_AJP_PORT</code> - The server AJP port, default to <code>8009</code>     
* <code>JBOSS_MGMT_NATIVE_PORT</code> - The server native management port, default to <code>9999</code>      
* <code>JBOSS_MGMT_HTTP_PORT</code> - The server HTTP management port, default to <code>9990</code>      
* <code>JBOSS_MGMT_HTTPS_PORT</code> - The server HTTPS management port, default to <code>9993</code> (Wildly) or <code>9443</code> (EAP)      

These are specific for standalone mode:     
* <code>JBOSS_STANDALONE_CONF_FILE</code> - The JBoss configuration file, default to <code>standalone.xml</code> (default profile)       

These are specific for domain controller mode:     
* <code>JBOSS_DOMAIN_CLUSTER_PASSWORD</code> - The JBoss domain cluster password. If not set, defaults to <code>jboss</code>        

These are specific for domain host mode:     
* <code>JBOSS_DOMAIN_MASTER_ADDR</code> - Indicates the domain master IP address where domain controller is running. If not set, defaults to <code>127.0.0.1</code>        
* <code>JBOSS_DOMAIN_MASTER_PORT</code> - Indicates the domain master port where domain controller is running. If not set, defaults to <code>9999</code>        

**JBoss server ports**

By default this docker image always exposes ports: <code>80,8080,8443,9990,9999</code>.      

As you can see in previous section, you can change the server ports when running the container using environment variables.    

So if you change any of those ports, you will have to run the container uinsg <code>-p &lt;bind_port&gt;:&lt;source_port&gt;</code> in order to bind the new ports used.    

**Custom JBoss Wildfly/EAP startup script**
 
You can override the way it's started by default up by overriding this script inside the docker container:

    /jboss/scripts/jboss-appserver/start-jboss.sh

**Disabling auto-start for JBoss Wildfly/EAP**      

If you don't want by default that JBoss Wildfly/EAP container is started when running the docker container, you can modify the supervisor daemon configuration file:       
* This file is located at <code>/etc/supervisord/conf.d/jboss-appserver.sv.conf</code> inside the container.        
* In oder to disable auto-start, modify the attribute <code>autostart</code> using the value <code>false</code>       
* Then you can start/stop the JBoss server on demand. See **[Starting, stopping and restarting the HTTPD daemon](#starting,-stopping-and-restarting-the-HTTPD-daemon)**

**Clustering**      

You can run some JBoss Wildfly/EAP containers using a clustered environment in both standalone or domain mode.    
 
To run the cluster you will have to setup manually the docker containers that will perform the cluster before running them:     
* The profile for the standalone instances or the server group instances (domain mode) must be changed to <code>ha</code> or <code>full-ha</code>       
* Optional - The jgroups subsystem by default uses multicast discovery protocol to find out all the cluster nodes. If this protocol is not working in your environment you have to change it to <code>TCPPING</code> and set all the cluster node IP addresses.       

**Other Notes**           
* If no container name argument is set and image to build is <code>wildfly</code>, it defaults to <code>xpaas-wildfly</code>        
* If no container name argument is set and image to build is <code>eap</code>, it defaults to <code>xpaas-eap</code>
* If no root password argument is set, it defaults to <code>xpaas</code>    
* If no JBoss server mode is set, it defaults to <code>STANDALONE</code>         
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

You can modify the way it's started by overriding this script inside the docker container:

    conf/scripts/jboss-appserver/start-jboss.sh

Notes:         
* If you are running server in a managed domain, you start/stop/restart the server instances from the domain controller hosts, either using management HTTP interface or native management interface      

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
You can access the container via SSH and copy the application to deploy into a temporal folder in the container (using <code>scp</code>) and deploy it using JBoss CLI

Notes:      
* If running the containers in domain mode, you can deploy/undeploy to several server instances at same time by doing a server-group deploy      

Logging
-------

You can see all logs generated by supervisor daemon & programs by running:

    docker logs [-f] <container_id>
    
You can see only the HTTP daemon logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/httpd-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/httpd-stderr.log

You can see only JBoss Wildfly/EAP logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stderr.log

Stopping the container
----------------------

To stop a running docker container just type:

    ./stop.sh <container_name>

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

In order to run all container services provided by this image, you have to run the following command:

    supervisord -c /etc/supervisord.conf
    
Extending this docker image
---------------------------

You can create a new container that uses this docker image as base:

    FROM xpaas/xpaas_eap:<version> # For EAP case
    FROM xpaas/xpaas_wildfly:<version> # For Wildfly case
    
As extending this image, the JBoss Wildfly/EAP container is run by default, you can add your custom configuration changes
or deployments via CLI.     

You can place a <code>sh</code> that runs some JBoss CLI commands in the following path: <code>/jboss/scripts/jboss-appserver/startup</code>.
This script will be executed only once just after container has been started for first time. See **[JBoss startup scripts](#JBoss-startup-scripts)**     

In addition, you can modify the way that JBoss server is started by default by modifying the startup script located inside the container at directory <code>/jboss/scripts/jboss-appserver/start-jboss.sh</code>. See **[Running the container](#running-the-container)** (section <i>Custom JBoss Wildfly/EAP startup script</i>)       

In order to run all container services provided by this image, you have to run the following command:

    supervisord -c /etc/supervisord.conf
    
    
Notes
-----
**JBoss Wildfly/EAP:**     
* The default admin password for Wildfly is <code>admin123!</code>      
* The web interface address is bind by default to <code>0.0.0.0</code>, you can change it using the environemnt variable <code>JBOSS_BIND_ADDRESS</code>     
* There is a MySQL JBDC driver module pre-installed      

**JBoss Wildfly/EAP ports:**            
* The HTTP port by default is <code>8080</code>, you can change it using the environment variable <code>JBOSS_HTTP_PORT</code>      
* The HTTPS port by default is <code>8443</code>, you can change it using the environment variable <code>JBOSS_HTTPS_PORT</code>      
* The AJP port by default is <code>8009</code>, you can change it using the environment variable <code>JBOSS_AJP_PORT</code>      
* The management HTTP port by default is <code>9990</code>, you can change it using the environment variable <code>JBOSS_MGMT_HTTP_PORT</code>      
* The management HTTPS port by default is <code>9993</code> (Wildfly) or <code>9443</code> (EAP) , you can change it using the environment variable <code>JBOSS_MGMT_HTTPS_PORT</code>      
* The management interface address is bind by default to the docker container IP address       
* NOTE: This ports can be changed, but this docker image always exposes ports: <code>80,8080,8443,9990,9999</code>. So if you change any of these ports, you will have to run the container uinsg <code>-p &lt;bind_port&gt;:&lt;source_port&gt;</code>        

**EAP:**      
* As EAP is a non-community product, in order to build the JBoss EAP image you have to manually add JBoss EAP ZIP file into <code>bin/</code> directory before building the JBoss EAP docker container image. See the [README.md](bin/README.md)

Upgrading JBoss Wildfly/EAP versions
------------------------------------

This section is oriented to this docker image developers. It describes the steps for upgrading or downgrading the JBoss Wildfly/EAP that this image uses, in order not to forget any stuff.          

Steps:       

1.- Modify Dockerfile.eap or Dockerfile.wildfly and modify the source artifact URL for the new version one        

2.- Check CLI in jboss-appserver/startup are working       

3.- Hardcoded files (copied from orginal JBoss Wildfly or EAP sources)       
    
    -> xpaas-jboss-appserver-docker/conf/jboss-appserver/host-slave-eap.xml # For JBoss EAP 
    -> xpaas-jboss-appserver-docker/conf/jboss-appserver/host-slave-wf.xml # For JBoss Wildfly
          
4.- Remember to increase the current version of this image tag       
