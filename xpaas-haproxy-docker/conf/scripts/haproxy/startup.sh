#!/bin/sh

# Welcome message
echo Welcome to haproxy
echo
echo Starting haproxy container


echo "" > /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# Example configuration for a possible web application.  See the" >> /etc/haproxy/haproxy.cfg
echo "# full configuration options online." >> /etc/haproxy/haproxy.cfg
echo "#" >> /etc/haproxy/haproxy.cfg
echo "#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt" >> /etc/haproxy/haproxy.cfg
echo "#" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# Global settings" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "global" >> /etc/haproxy/haproxy.cfg
echo "    # to have these messages end up in /var/log/haproxy.log you will" >> /etc/haproxy/haproxy.cfg
echo "    # need to:" >> /etc/haproxy/haproxy.cfg
echo "    #" >> /etc/haproxy/haproxy.cfg
echo "    # 1) configure syslog to accept network log events.  This is done" >> /etc/haproxy/haproxy.cfg
echo "    #    by adding the '-r' option to the SYSLOGD_OPTIONS in" >> /etc/haproxy/haproxy.cfg
echo "    #    /etc/sysconfig/syslog" >> /etc/haproxy/haproxy.cfg
echo "    #" >> /etc/haproxy/haproxy.cfg
echo "    # 2) configure local2 events to go to the /var/log/haproxy.log" >> /etc/haproxy/haproxy.cfg
echo "    #   file. A line like the following can be added to" >> /etc/haproxy/haproxy.cfg
echo "    #   /etc/sysconfig/syslog" >> /etc/haproxy/haproxy.cfg
echo "    #" >> /etc/haproxy/haproxy.cfg
echo "    #    local2.*                       /var/log/haproxy.log" >> /etc/haproxy/haproxy.cfg
echo "    #" >> /etc/haproxy/haproxy.cfg
echo "    log         127.0.0.1 local2" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "    chroot      /var/lib/haproxy" >> /etc/haproxy/haproxy.cfg
echo "    pidfile     /var/run/haproxy.pid" >> /etc/haproxy/haproxy.cfg
echo "    maxconn     4000" >> /etc/haproxy/haproxy.cfg
echo "    user        haproxy" >> /etc/haproxy/haproxy.cfg
echo "    group       haproxy" >> /etc/haproxy/haproxy.cfg
echo "    daemon" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "    # turn on stats unix socket" >> /etc/haproxy/haproxy.cfg
echo "    stats socket /var/lib/haproxy/stats" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# common defaults that all the 'listen' and 'backend' sections will" >> /etc/haproxy/haproxy.cfg
echo "# use if not designated in their block" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "defaults" >> /etc/haproxy/haproxy.cfg
echo "    mode                    http" >> /etc/haproxy/haproxy.cfg
echo "    log                     global" >> /etc/haproxy/haproxy.cfg
echo "    option                  httplog" >> /etc/haproxy/haproxy.cfg
echo "    option                  dontlognull" >> /etc/haproxy/haproxy.cfg
echo "    option http-server-close" >> /etc/haproxy/haproxy.cfg
echo "    option forwardfor       except 127.0.0.0/8" >> /etc/haproxy/haproxy.cfg
echo "    option                  redispatch" >> /etc/haproxy/haproxy.cfg
echo "    retries                 3" >> /etc/haproxy/haproxy.cfg
echo "    timeout http-request    10s" >> /etc/haproxy/haproxy.cfg
echo "    timeout queue           1m" >> /etc/haproxy/haproxy.cfg
echo "    timeout connect         10s" >> /etc/haproxy/haproxy.cfg
echo "    timeout client          1m" >> /etc/haproxy/haproxy.cfg
echo "    timeout server          1m" >> /etc/haproxy/haproxy.cfg
echo "    timeout http-keep-alive 10s" >> /etc/haproxy/haproxy.cfg
echo "    timeout check           10s" >> /etc/haproxy/haproxy.cfg
echo "    maxconn                 3000" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# main frontend which proxys to the backends" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "frontend  main *:5000" >> /etc/haproxy/haproxy.cfg
echo "#    acl url_static       path_beg       -i /static /images /javascript /stylesheets" >> /etc/haproxy/haproxy.cfg
echo "#    acl url_static       path_end       -i .jpg .gif .png .css .js" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#    use_backend static          if url_static" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "    default_backend             app" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# static backend for serving up images, stylesheets and such" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "backend static" >> /etc/haproxy/haproxy.cfg
echo "    balance     roundrobin" >> /etc/haproxy/haproxy.cfg
echo "    server      static 127.0.0.1:4331 check" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "# round robin balancing between the various backends" >> /etc/haproxy/haproxy.cfg
echo "#---------------------------------------------------------------------" >> /etc/haproxy/haproxy.cfg
echo "backend app" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "    cookie BPMSNODE insert indirect nocache" >> /etc/haproxy/haproxy.cfg
echo "    option httpchk GET /" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "    balance     roundrobin" >> /etc/haproxy/haproxy.cfg

ORIGINAL_IFS=$IFS
export IFS=","
count=0
for line in $HA_HOSTS; do
   count=$[$count +1]
   echo "    server  app$count $line check cookie app$count" >> /etc/haproxy/haproxy.cfg
done
export IFS=$ORIGINAL_IFS


echo "#   server  app3 127.0.0.1:5003 check" >> /etc/haproxy/haproxy.cfg
echo "#   server  app4 127.0.0.1:5004 check" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg
echo "listen stats *:9000" >> /etc/haproxy/haproxy.cfg
echo "    mode http" >> /etc/haproxy/haproxy.cfg
echo "    stats enable" >> /etc/haproxy/haproxy.cfg
echo "    stats uri /stats" >> /etc/haproxy/haproxy.cfg
echo "" >> /etc/haproxy/haproxy.cfg


# Run haproxy service.
haproxy -f /etc/haproxy/haproxy.cfg

exit 0