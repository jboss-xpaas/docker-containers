XPasS Fabric 8Docker Image
===========================

This project builds a [docker](http://docker.io/) container for running XPaaS Fabric8.

This image is based on a <code>xpaas/xpaas_base</code> version <code>1.0</code> and provides a container including:     
* Fabric8 IO version <code>1.1.0.CR5</code>   

Table of contents
------------------

* **[Control scripts](#control-scripts)**
* **[Building the docker container](#building-the-docker-container)**
* **[Running the container](#running-the-container)**
* **[Connection to a container using SSH](#connection-to-a-container-using-SSH)**
* **[Starting, stopping and restarting the SSH daemon](#starting,-stopping-and-restarting-the-SSH-daemon)**
* **[Starting, stopping and restarting Fabric8](#starting,-stopping-and-restarting-Fabric8)**
* **[Logging](#logging)**
* **[Stopping the container](#stopping-the-container)**
* **[Experimenting](#Experimenting)**
* **[Notes](#notes)**

Control scripts
---------------

There are three control scripts:    
* <code>build.sh</code> Builds the docker image    
* <code>start.sh</code> Starts a new XPaaS fabric8  docker image container    
* <code>stop.sh</code>  Stops the runned XPaaS fabric8  docker image container    

Building the docker container
-----------------------------

We have a Docker Index trusted build setup to automatically rebuild the xpass/xpass-fabric8 container whenever the
[Dockerfile](https://github.com/pzapataf/xpaas-docker-containers/blob/master/xpaas-fabric8-docker/Dockerfile) is updated, so you shouldn't have to rebuild it locally. But if you want to, here's now to do it...

Once you have [installed docker](https://www.docker.io/gettingstarted/#h_installation) you should be able to create the containers via the following:

If you are on OS X then see [How to use Docker on OS X](DockerOnOSX.md).

    git clone git@github.com:pzapataf/xpaas-docker-containers.git
    cd xpaas-docker-containers/xpaas-fabric8-docker
    ./build.sh

Running the container
---------------------

To run a new image container from XPaaS fabric8  run:
    
    ./start.sh [-c <container_name>] [-p <root_password>]


Or you can try it out via docker command directly:

    docker run -P -d [--name <container_name>] [-e ROOT_PASSWORD="<root_password>"] xpaas/xpaas_fabric8:<version>

These commands will start a new XPaas fabric8 container with Fabric8 services enabled     

**Environment variables**

These are the environment variables supported when running the JBoss Wildfly/EAP container:       

- <code>ROOT_PASSWORD</code> - The root password for <code>root</code> system user. Useful to connect via SSH

**Notes**           
* If no container name argument is set, it defaults to <code>xpaas-fabric8</code>       
* If no root password argument is set, it defaults to <code>xpaas</code>    
* An specific user for fabric8 is created in the container: <code>fabric8/fabric8</code>    

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
    ssh fabric8@localhost -p 49001
    
**Notes**        
* By default, the available users to connect using SSH are <code>root</code> and <code>fabric8</code>      
* By default, the <code>root</code> user password is <code>xpaas</code>     
* By default, the <code>fabric8</code> user password is <code>fabric8</code>     
* You can change the default <code>root</code> password when running the container. See **[Running the container](#running-the-container)**      

Starting, stopping and restarting the SSH daemon
------------------------------------------------

To start the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh sshd

To stop the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh sshd

To restart the SSH daemon run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh sshd

Starting, stopping and restarting Fabric8
-----------------------------------------

To start Fabric8 run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/start.sh fabric8

To stop Fabric8 run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/stop.sh fabric8

To restart Fabric8 run:
    
    ssh root@localhost -p <ssh_port> sh /jboss/scripts/restart.sh fabric8

Logging
-------
You can see all logs generated by supervisor daemon & programs by running:

    docker logs <container_id>
    
You can see only the SSH daemon logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/sshd-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/sshd-stderr.log

You can see only the Fabric8 logs by running this command:

    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/fabric8-stdout.log
    ssh root@localhost -p <ssh_port> tail -f /var/log/supervisord/fabric8-stderr.log

Stopping the container
----------------------
To stop the previous image container run using <code>start.sh</code> script just type:

    ./stop.sh

Experimenting
-------------
To spin up a shell in one of the containers try:

    docker run -P -i -t xpaas/xpaas_fabric8 /bin/bash
    
You can then noodle around the container and run stuff & look at files etc.
    
Notes
-----
* This docker container is copied and adapted to build from <code>xpaas/xpaas_base</code> image and its services from this source [repository](https://github.com/fabric8io/fabric8-docker/)      