![example workflow](https://github.com/dalmatialab/zookeeper/actions/workflows/main.yml/badge.svg)

# Supported tags and respective Dockerfile links

 - 6.2

# What is Rudder ?

RUDDER is a professional, open source and multi-platform solution allowing you to continuously deploy, audit and remediate the configurations of your critical systems. RUDDER acts as a control tower providing a real-time visibility of your systems’ compliance for reliability and security.

<img src="https://github.com/dalmatialab/rudder/blob/e4d54d8c453c6985961cf5283062b1435b29759e/logo.png?raw=true" width="200" height="200">

# How to use this image

## Start Rudder server

	docker run -d --privileged -h rudder-server -p 443:443 -p 5309:5309 -v /rudder_configuration/openldap-data/:/var/rudder/ldap/openldap-data/ -v /rudder_configuration/12/:/usr/share/postgresql/12 -v /rudder_configuration/etc/:/opt/rudder/etc -v /rudder_configuration/configuration-repository/:/var/rudder/configuration-repository/ -v /rudder_configuration/ppkeys/:/var/rudder/cfengine-community/ppkeys -v /sys/fs/cgroup:/sys/fs/cgroup:ro image:tag

Where:
 - *tag* is docker image version

Important:
 - **After running command from above, You will have to wait up to 10 minutes before server starts. If mounted directories contains configuration files, delay time may extend up to 15 minutes.**

## Environment variables

**RUDDER_USER**

This is required variable. It specifies username for login to the website. Default value: rudderserver

**RUDDER_PASSWORD**

This is required variable. It specifies password for login to the website. Default value: rudderserver

**RUDDER_ROLE**

This is required variable. It specifies type of user. Default value: administrator

**These ENV variables have been forwarded to systemd unit file, entrypoint.service**

## Ports

Rudder server exposes user interface at port 443. Port 5309 is used to ensure communication between Rudder server and Rudder clients.

## Volumes

To save Rudder server configuration, mount these container paths to host paths:

	-v some-host-path:/var/rudder/ldap/openldap-data
	-v some-host-path:/usr/share/postgresql/12
	-v some-host-path:/opt/rudder/etc
	-v some-host-path:/var/rudder/configuration-repository
	-v some-host-path:/var/rudder/cfengine-community/ppkeys

## NOTE

There are several features of Rudder server that cause problems with deployment into Docker container:
 
 - Rudder server requires systemd to run properly
 - Server starts to run during installation
 - Rudder server doesn't implement option of installing server with existing configuration.

To reslove these drawbacks, the following needs to be done:

 - Create two bash scripts (install.sh and create_user.sh) and one systemd unit file (entrypoint.service).

	*install.sh* manages installation of rudder server, also it manages existing configuration that is stored in directories on the host. These directories are mounted at startup of container.
	*create_user.sh* script manages creation of users.
	*entrypoint.service* will get executed at the moment of startup of docker container, the purpose of this unit file is to launch *install.sh* script.

Configuration of install.sh script

1. Script will check if mounted directories are empty, if they are, it is going to install rudder server as usual.

2. If mounted directories are not empty, script will create temporary directories inside /tmp and mount these ***original*** directories to the /tmp directory.
For this mount command, we have used option --bind. Use of this option requires running container with --privileged option.
After execution of the "mount" command, all non-empty ***original*** directories are going to point to empty /tmp directories, and rudder installation will store default configuration to these directories.

3. Install rudder server, and execute create_user.sh script. At this moment we will have running rudder server with plain configuration.

4. Stop and disable necessary rudder systemd services.

5. Unmount all directories that are pointing to /tmp directories. Now they are going to point to ***original*** directories, where desired configuration is stored.

6. Start and enable necessary rudder systemd services. At this moment we will have running rudder server with desired configuration.


***original*** - directories we mounted on startup of the container, server configuration is stored in these directories.

 
