JBoss BPMS Docker Image
=======================

This project builds a [docker](http://docker.io/) container for running JBoss BPMS.

This image provides a container including:     
* XPaaS JBoss Wildfly / JBoss EAP docker image
* JBoss BPMS 6.1.0.CR1

Before running this container it's recommended to read the documentation about JBoss Wildfly / EAP docker container.     
It can be found at this [location](../xpaas-jboss-appserver-docker/README.md)     

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Using JBoss BPMS](#using-JBoss-BPMS)**
* **[BPMS Users and roles](#BPMS-Users-and-roles)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Using external database](#Using-external-database)**
* **[Experimenting](#Experimenting)**
* **[Notes](#Notes)**

Control scripts
---------------

There are three control scripts:    
* <code>build.sh</code> Builds the JBoss BPMS docker image    
* <code>start.sh</code> Starts a new XPaaS JBoss BPMS docker container based on this image    
* <code>stop.sh</code>  Stops the runned XPaaS JBoss BPMS docker container    

Building the docker container
-----------------------------

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

First, clone the repository:
    
    git clone git@github.com:pzapataf/xpaas-docker-containers.git
    cd xpaas-docker-containers/xpaas-bpms-docker
    
**Creating the JBoss BPMS for Wildly container**
    
    ./build.sh bpms-wildfly

**Creating the JBoss BPMS for EAP container**
    
    ./build.sh bpms-eap

Running the container
---------------------

To run a new container from XPaaS JBoss Wildfly/EAP run:
    
    ./start.sh [-i [bpms-wildfly,bpms-eap]] [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-d <connection_driver>] [-url <connection_url>] [-user <connection_user>] [-password <connection_password>] [-l <container_linking>]
    Example: ./start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -p "root123!" -ap "root123!" -d "h2" -url "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE" -user sa -password sa

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] [-e BPMS_CONNECTION_DRIVER="<connection_driver>"] [-e BPMS_CONNECTION_URL="<connection_url>"] [-e BPMS_CONNECTION_USER="<connection_user>"] [-e BPMS_CONNECTION_PASSWORD="<connection_password>"] xpaas/xpaas_bpms-wildfly:<version>
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] [-e BPMS_CONNECTION_DRIVER="<connection_driver>"] [-e BPMS_CONNECTION_URL="<connection_url>"] [-e BPMS_CONNECTION_USER="<connection_user>"] [-e BPMS_CONNECTION_PASSWORD="<connection_password>"] xpaas/xpaas_bpms-eap:<version>

These commands will start JBoss BPMS web application.

**Environment variables**

These are the environment variables supported when running the JBoss Wildfly/EAP container:       

- <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH     
- <code>JBOSS_APPSERVER_ADMIN_PASSWORD</code> - The JBoss <code>admin</code> user password      
- <code>JBOSS_APPSERVER_ARGUMENTS</code> - The arguments to pass when executing <code>standalone.sh</code> startup script     

For running bpms, you need to specify some database connection JBoss Wildfly/EAP run arguments:

- <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
- <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>

**Notes**           
* If no container name argument is set and image to build is <code>bpms-wildfly</code>, it defaults to <code>xpaas_bpms-wildfly</code>        
* If no container name argument is set and image to build is <code>bpms-eap</code>, it defaults to <code>xpaas_bpms-eap</code>    
* If no root password argument is set, it defaults to <code>xpaas</code>    
* If no JBoss Wildfly/EAP admin user password argument is set, it defaults to <code>admin123!</code>      
* Current available bpms connection drivers are <code>h2</code> and <code>mysql</code>     

Using JBoss BPMS
----------------
By default, the JBoss Wildfly/EAP HTTP interface bind address points to <code>0.0.0.0</code>, so you can discover your container port mapping for port <code>8080</code> 
and type in you browser:
 
    http://localhost:<binding_port>/kie-wb
    
Where <code>&lt;binding_port&gt;</code> can be found by running:

    docker ps -a
    
Another option if about accessing the Wildfly HTTP interface using the container IP address to, that can be found by running:

    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_id>
    
Then you can type this URL:

    http://<container_ip_address>:8080/kie-wb

**Notes**           
* The context name for JBoss BPMS is <code>kie-wb</code>      
* The default <code>admin</code> password is <code>admin</code>           

BPMS Users and roles
--------------------

BPMS uses a custom security application realm based on a properties file.   

The default JBoss BPMS application users & roles are:

<table>
    <tr>
        <td><b>User</b></td>
        <td><b>Password</b></td>
        <td><b>Role</b></td>
    </tr>
    <tr>
        <td>admin</td>
        <td>admin</td>
        <td>admin</td>
    </tr>
    <tr>
        <td>pzapata</td>
        <td>pzapata</td>
        <td>analyst</td>
    </tr>
    <tr>
        <td>roger</td>
        <td>roger</td>
        <td>developer</td>
    </tr>
    <tr>
        <td>neus</td>
        <td>neus</td>
        <td>manager</td>
    </tr>
    <tr>
        <td>user</td>
        <td>user</td>
        <td>user</td>
    </tr>
</table>

You can manage additional users and roles via SSH by editing the properties files:     

    vi /opt/jboss-appserver/standalone/configuration/bpms-users.properties
    vi /opt/jboss-appserver/standalone/configuration/bpms-roles.properties


Note: In order to manage JBoss EAP/Wildfly management users see [JBoss Wildfly/EAP Docker Image](../xpaas-jboss-appserver-docker/README.md)

Logging
-------

You can see all logs generated by supervisor daemon & programs by running:

    docker logs [-f] <container_id>
    
You can see only JBoss BPMS logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/jboss-appserver-stderr.log

Stopping the container
----------------------

To stop the previous container run using <code>start.sh</code> script just type:

    ./stop.sh

Using external database
-----------------------

You can use any external database instance for running JBoss BPMS.      

In order to connect to an external database you have to set these environment variables:    

- <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
- <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>      

For example, you can use the  to run a MySQL docker container and use the database instance with JBoss BPMS:    

1.- Download the Docker MySQL image
    
    docker pull mysql
    
2.- Run the MySQL docker image

    docker run -e MYSQL_ROOT_PASSWORD=root123 -d -P mysql
    
3.- Create the JBoss BPMS database in the MySQL instance     

4.- Run the JBoss BPMS docker image

    ./start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -p "root123!" -ap "root123!" -d "mysql" -url "jdbc:mysql://<mysql_container_ip>:<mysql_port>/<database>" -user <username> -password <password>

Where <code>mysql_container_ip</code> - Can be found by running:
    
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' <mysql_container_id>
 
**Notes**     
* Using this strategy there is no need for running the containers using Docker container linking     
* Another strategy is to run the MySQL docker container using the argument <code>-P</code> and bind the connection to an available port on <code>localhost</code>      
* Current available bpms connection drivers are <code>h2</code> and <code>mysql</code>    

**MySQL docker container linking support**

If you are using as external database a MySQL instance, and it's provided using the [Official MySQL docker container](https://registry.hub.docker.com/_/mysql/), 
you can use [Docker container linking](https://docs.docker.com/userguide/dockerlinks/) to run JBoss BPMS with minimal startup configuration.     

When linking MySQL container with the JBoss BPMS one, there are two mandatory actions:      
* The <code>alias</code> for the MySQL linked container when running the BPMS one must be <code>mysql</code>      
* Set environment variable <code>BPMS_DATABASE</code> using the name of an existing database in the running MySQL container.     

Take a look at the following example:

1.- Download the Docker MySQL image
    
    docker pull mysql
    
2.- Run the MySQL docker image (with container naming support)

    docker run --name bpms-mysql -e MYSQL_ROOT_PASSWORD=root123 -d -P mysql
    
3.- Create the JBoss BPMS database in the MySQL instance named <code>bpms</code>  

4.- Run the JBoss BPMS docker image (with container linking support)

    ./start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -l bpms-mysql:mysql -db bpms # Using start.sh script
     
     docker run --link bpms-mysql:mysql -P -d -e BPMS_DATABASE="bpms" xpaas/xpaas_bpms-wildfly # Using docker command
     
The JBoss BPMS database connection will automatically link to the MySQL docker container instance using the <code>bpms</code> database.

NOTE: When using MySQL container linking with JBoss BPMS container, the connection envrionment variables <code>BPMS_CONNECTION_URL, BPMS_CONNECTION_DRIVER, BPMS_CONNECTION_USER, BPMS_CONNECTION_PASSWORD</code> have no effect, even if set when running the JBoss BPMS container.

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t xpaas/xpaas_bpms-wildfly /bin/bash # For JBoss Wildfly distribution
    docker run -P -i -t xpaas/xpaas_bpms-eap /bin/bash # For JBoss EAP distribution
    
You can then noodle around the container and run stuff & look at files etc.

Notes
-----
* This container overrides the default JBoss Wildfly/EAP start command (from XPaaS JBoss Wildfly/EAP image), adding some custom system properties     
* There is no support for clustering     
