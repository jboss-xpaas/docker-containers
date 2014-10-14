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
* **[Using JBoss BPMS](#using-jboss-bpms)**
* **[BPMS Users and roles](#bpms-users-and-roles)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Using external database](#using-external-database)**
* **[BPMS Clustering](#bpms-clustering)**
* **[Experimenting](#experimenting)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts for running BPMS with no clustering support:    
* <code>scripts/build.sh</code> Builds the JBoss BPMS docker image    
* <code>scripts/start.sh</code> Starts a new XPaaS JBoss BPMS docker container based on this image    
* <code>scripts/stop.sh</code>  Stops the runned XPaaS JBoss BPMS docker container    

To run the BPMS using a clustered environment, you can use:        
* <code>scripts/cluster/create_cluster.sh</code> Creates a clustered environment for BPMS web application. See **[BPMS Clustering](#bpms-clustering)**          

Building the docker container
-----------------------------

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

First, clone the repository:
    
    git clone git@github.com:jboss-xpaas/docker-containers.git
    cd xpaas-docker-containers/xpaas-bpms-docker
    
**Creating the JBoss BPMS for Wildly container**
    
    ./scripts/build.sh bpms-wildfly

**Creating the JBoss BPMS for EAP container**
    
    ./scripts/build.sh bpms-eap

Running the container
---------------------

To run a new container from XPaaS JBoss Wildfly/EAP run:
    
    ./scripts/start.sh [-i [bpms-wildfly,bpms-eap]] [-c <container_name>] [-p <root_password>] [-ap <admin_password>] [-d <connection_driver>] [-url <connection_url>] [-user <connection_user>] [-password <connection_password>] [-l <container_linking>]
    Example: ./scripts/start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -p "root123!" -ap "root123!" -d "h2" -url "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE" -user sa -password sa

Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] [-e BPMS_CONNECTION_DRIVER="<connection_driver>"] [-e BPMS_CONNECTION_URL="<connection_url>"] [-e BPMS_CONNECTION_USER="<connection_user>"] [-e BPMS_CONNECTION_PASSWORD="<connection_password>"] xpaas/xpaas_bpms-wildfly:<version>
    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"]  [-e JBOSS_APPSERVER_ADMIN_PASSWORD="<jboss_admin_password>"] [-e BPMS_CONNECTION_DRIVER="<connection_driver>"] [-e BPMS_CONNECTION_URL="<connection_url>"] [-e BPMS_CONNECTION_USER="<connection_user>"] [-e BPMS_CONNECTION_PASSWORD="<connection_password>"] xpaas/xpaas_bpms-eap:<version>

These commands will start JBoss BPMS web application.

**Environment variables**

These are the environment variables supported when running the JBoss Wildfly/EAP container:       

- <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH     
- <code>JBOSS_APPSERVER_ADMIN_PASSWORD</code> - The JBoss <code>admin</code> user password      
- <code>JBOSS_APPSERVER_ARGUMENTS</code> - The arguments to pass when executing <code>standalone.sh</code> startup script     

For running BPMS, you need to specify some database connection JBoss Wildfly/EAP run arguments:

- <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
- <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
- <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>
- <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>       

For running BPMS in a clustered environment, you need to specify some other parameters:     

- <code>HELIX_VERSION</code> - The Apache Helix version to use, defaults to <code>0.6.3</code>           
- <code>BPMS_ZOOKEEPER_SERVER</code> - The Apache Zookeeper server URL in a format as <ocde>&lt;server:port&gt;</code>, not set by default          
- <code>BPMS_CLUSTER_NAME</code> - The Apache helix cluster name to use, not set by default          
- <code>BPMS_CLUSTER_NODE</code> - The number of the current node that will compose the cluster, defaults to <code>1</code>          
- <code>BPMS_VFS_LOCK</code> -  The Apache helix VFS repository lock name to use, defaults to <code>bpms-vfs-lock</code>           
- <code>BPMS_GIT_HOST</code> - The Git daemon host, defaults to the current container's IP address       
- <code>BPMS_GIT_DIR</code> - The Git daemon working directory, defaults to <code>/opt/jboss/bpms/vfs</code>       
- <code>BPMS_GIT_PORT</code> - The Git daemon port, defaults to <code>9520</code>          
- <code>BPMS_SSH_PORT</code> - The SSH daemon port, defaults to <code>9521</code>          
- <code>BPMS_SSH_HOST</code> - The SSH daemon host, defaults to the current container's IP address          
- <code>BPMS_INDEX_DIR</code> - The Lucene index directory, defaults to <code>/opt/jboss/bpms/index</code>          

**Notes**           
* If no container name argument is set and image to build is <code>bpms-wildfly</code>, it defaults to <code>xpaas_bpms-wildfly</code>        
* If no container name argument is set and image to build is <code>bpms-eap</code>, it defaults to <code>xpaas_bpms-eap</code>    
* If no root password argument is set, it defaults to <code>xpaas</code>    
* If no JBoss Wildfly/EAP admin user password argument is set, it defaults to <code>admin123!</code>      
* Current available bpms connection drivers are <code>h2</code> and <code>mysql</code>     

Using JBoss BPMS
----------------
By default, the JBoss Wildfly/EAP HTTP interface bind address points to <code>127.0.0.1</code>, so you can discover your container port mapping for port <code>8080</code> 
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

    ssh root@localhost -p <ssh_port> tail -f /opt/jboss-appserver/standalone/log/server.log

Stopping the container
----------------------

To stop the previous container run using <code>start.sh</code> script just type:

    ./scripts/stop.sh

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

    ./scripts/start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -p "root123!" -ap "root123!" -d "mysql" -url "jdbc:mysql://<mysql_container_ip>:<mysql_port>/<database>" -user <username> -password <password>

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

    ./scripts/start.sh -i bpms-wildfly -c xpaas_bpms-wildfly -l bpms-mysql:mysql -db bpms # Using start.sh script
     
     docker run --link bpms-mysql:mysql -P -d -e BPMS_DATABASE="bpms" xpaas/xpaas_bpms-wildfly # Using docker command
     
The JBoss BPMS database connection will automatically link to the MySQL docker container instance using the <code>bpms</code> database.

NOTE: When using MySQL container linking with JBoss BPMS container, the connection envrionment variables <code>BPMS_CONNECTION_URL, BPMS_CONNECTION_DRIVER, BPMS_CONNECTION_USER, BPMS_CONNECTION_PASSWORD</code> have no effect, even if set when running the JBoss BPMS container.


BPMS Clustering
---------------

**BPMS clustered environment**

JBoss BPMS web application can run in a clustered environment.    
This environment consist of:       
* An Apache Zookeeper / Helix server & controller - Handle the cluster nodes      
* An external shared database between all BPMS server instances       
* Several BPMS server instances      
* An haproxy load balancer       

**Running BPMS in a clustered environment**

You can run an external Zookeeper/Helix, haproxy and database using Docker containers or system services.      
In order to run the BPMS container using these services for a clustered environment you have to set these environment variables on container startup:     
* <code>BPMS_CLUSTER_NAME</code> - The Apache helix cluster name to use, not set by default          
* <code>BPMS_ZOOKEEPER_SERVER</code> - The Apache Zookeeper server URL in a format as <ocde>&lt;server:port&gt;</code>, not set by default          
* <code>BPMS_CLUSTER_NODE</code> - The number of the current node that will compose the cluster, defaults to <code>1</code>          
* <code>BPMS_VFS_LOCK</code> -  The Apache helix VFS repository lock name to use, defaults to <code>bpms-vfs-lock</code>           
* <code>JBOSS_NODE_NAME</code> - The name for the JBoss server node, defaults to <code>node1</code>. Each server must have an unique JBoss node name.        

And the ones for the external database to use:        
* <code>BPMS_CONNECTION_URL</code> - The database connection URL. If not set, defaults to <code>jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE</code>          
* <code>BPMS_CONNECTION_DRIVER</code> - The database connection driver. See [Notes] for available database connection drivers. If not set, defaults to <code>h2</code>        
* <code>BPMS_CONNECTION_USER</code> - The database connection username. If not set, defaults to <code>sa</code>       
* <code>BPMS_CONNECTION_PASSWORD</code> - The database connection password. If not set, defaults to <code>sa</code>       

NOTES:        
* Currently the clustering for BPMS only works in standalone mode for all server instances.       
* The BPMS container configure the cluster parameters if <code>BPMS_CLUSTER_NAME</code> is set.       
* If clustering enabled, the standalone server forces to use the <code>standalone-full-ha.xml</code> config file
* Zookeeper server and external database must be configured & ready before running the bpms container.        
* The external database MUST have the quartz tables created before running the bpms container.      
* IMPORTANT: Set <code>BPMS_CLUSTER_NODE</code> environment variable using the number of the current cluster instance that will compose the cluster environment. Needed to rebalance the clustered resource.

**Running the pre-defined clustered environment for BPMS**

This BPMS docker container image provides a script to run a pre-defined BPMS clustered environment. It:       
* Creates and configures a Zookeeper docker container.      
* Creates and configures a MySQL docker container.      
* Creates and configures an haproxy docker container.      
* Creates and configures a several BPMS server instances.      

This script is located at <code>scripts/cluster/create_cluster.sh</code> and has the following input arguments:        
* <code>-name | --cluster-name</code>: The name for the cluster. If not set, defaults to <code>bpms-cluster</code>.         
* <code>-vfs | --vfs-lock</code>: The name for VFS resource lock for the cluster. If not set, defaults to <code>bpms-vfs-lock</code>.        
* <code>-n | --num-instances</code>: The number of BPMS server instances that will compose the cluster. If not set, defaults to <code>2</code>.        
* <code>-db-root-pwd</code>: The root password for the MySQL database. If not set, defaults to <code>mysql</code>.        

Here is an example of how to run the script:       
        
    sudo ./create_cluster.sh -name bpms-cluster -vfs bpms-vfs-lock -n 2 -db-root-pwd mysql

After running it, you can see the created containers by typing:       

    docker ps -a
    
Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t xpaas/xpaas_bpms-wildfly /bin/bash # For JBoss Wildfly distribution
    docker run -P -i -t xpaas/xpaas_bpms-eap /bin/bash # For JBoss EAP distribution
    
You can then noodle around the container and run stuff & look at files etc.

In order to run all container services provided by this image, you have to run the following command:

    supervisord -c /etc/supervisord.conf

Notes
-----
* This container overrides the default JBoss Wildfly/EAP start command (from XPaaS JBoss Wildfly/EAP image), adding some custom system properties     
* This container forces to start JBoss server using <code>full</code> profile       
* There is no support for clustering       
* Currently the BPMS version for JBoss Wildfly is now working due to -> https://issues.jboss.org/browse/WFLY-3355        
