Using Docker on OS X
--------------------

If you are working on OS X then please use [dvm]() and the native docker client for OS X.

Here are the [installation instructions](http://hw-ops.com/blog/2014/01/07/introducing-dvm-docker-in-a-box-for-unsupported-platforms/)

You may wish to add this to your ~/.bashrc

    eval $(dvm env)
    
then in any shell you can just run docker commands and they connect correctly to the VM at $DOCKER_HOST

