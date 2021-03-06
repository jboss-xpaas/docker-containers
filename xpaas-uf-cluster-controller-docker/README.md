XPaaS Zookeeper Docker Image
===========================

This project builds a [docker](http://docker.io/) container for running XPaaS Zookeeper.

This image is based on a <code>redhat/xpaas-base</code> version <code>1.0</code> and provides a container including:
zookeeper server and helix controller initialization

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Connection to a container using SSH](#connection-to-a-container-using-ssh)**
* **[Starting, stopping and restarting the SSH daemon](#starting,-stopping-and-restarting-the-ssh-daemon)**
* **[Starting, stopping and restarting Zookeeper](#starting,-stopping-and-restarting-zookeeper)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Experimenting](#experimenting)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts:    
* <code>build.sh</code> Builds the docker image    
* <code>start.sh</code> Starts a new XPaaS zookeeper  docker container based on this image
* <code>stop.sh</code>  Stops the runned XPaaS zookeeper  docker container

Building the docker container
-----------------------------

We have a Docker Index trusted build setup to automatically rebuild the xpass/xpass-zookeeper container whenever the
[Dockerfile](https://github.com/jboss-xpaas/docker-containers/blob/master/xpaas-zookeeper-docker/Dockerfile) is updated, so you shouldn't have to rebuild it locally. But if you want to, here's now to do it...

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

    git clone git@github.com:jboss-xpaas/docker-containers.git
    cd xpaas-docker-containers/xpaas-zookeeper-docker
    ./build.sh

Running the container
---------------------

To run a new container from XPaaS zookeeper run:
    
    ./start.sh [-c <container_name>] [-p <root_password>]
    ./start.sh [-c <container_name>] [-p <root_password>]] -zServers [server.1=zServer1_IP:zooServer1_Port1:zooServer1_Port2\\\\nserver.2=zServer2_IP:zooServer2_Port1:zooServer2_Port2] [-cn <cluster_name>] [-cvfs <vfs-repo>] | [-h]

The parameter -zServers or --zookeeperServers: expects  the list of zookeeper servers that work together to ensure the zookeepeer HA.
the   server.1=zoo1:2888:3888\\nserver.2=zoo2:2888:3888\\nserver.3=zoo3:2888:3888
                           Other zookeeper server to ensure HA
Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"] redhat/xpaas-uf-cluster-controller:<version>

These commands will start a new XPaas zookeeper container with Zookeeper services enabled

**Environment variables**

These are the environment variables supported when running the JBoss Wildfly/EAP container:       

- <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH

**Notes**           
* If no container name argument is set, it defaults to <code>xpaas-zookeeper</code>
* If no root password argument is set, it defaults to <code>xpaas</code>    

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
* By default, the available users to connect using SSH are <code>root</code> and <code>fabric8</code>      
* By default, the <code>root</code> user password is <code>xpaas</code>     
* You can change the default <code>root</code> password when running the container. See **[Running the container](#running-the-container)**


Starting, stopping and restarting the SSH daemon
------------------------------------------------

To start the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh sshd

To stop the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh sshd

To restart the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh sshd

Logging
-------
You can see all logs generated by supervisor daemon & programs by running:

    docker logs [-f] <container_id>
    
You can see only the SSH daemon logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/sshd-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/sshd-stderr.log

You can see only the Fabric8 logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/fabric8-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/fabric8-stderr.log

Stopping the container
----------------------
To stop the previous container run using <code>start.sh</code> script just type:

    ./stop.sh

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t redhat/xpaas-uf-cluster-controller /bin/bash
    
You can then noodle around the container and run stuff & look at files etc.

In order to run all container services provided by this image, you have to run the following command:

    supervisord -c /etc/supervisord.conf
    
Notes
-----
* This docker container is copied and adapted to build from <code>redhat/xpaas-base</code> image