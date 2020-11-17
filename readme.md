
# **Installation of the EARS server**

## Prerequisites

The main prerequisite is linux with the docker daemon installed. Installing docker,docker-compose, installing git, get the EARS server files and building an image from the Dockerfile all require a fast and stable internet connection (on-shore cable or 4G preferred over satellite). This is not always possible on board, so plan the installation ahead. The EARS web applications can be installed on an already present physical or virtual server, or can be installed on-shore inside a virtual machine, taken on-board and deployed there. The server must be accessible from the ship&#39;s LAN.

To create a linux virtual machine, we refer to the many resources available on this topic, for instance: [https://linuxconfig.org/install-and-set-up-kvm-on-ubuntu-18-04-bionic-beaver-linux](https://linuxconfig.org/install-and-set-up-kvm-on-ubuntu-18-04-bionic-beaver-linux). The rest of these guidelines is written with Ubuntu in mind. If only windows servers are available on board, virtualisation is a must.

## Physical requirements

All data is stored inside a docker container (see below). This will increase in size as the campaigns are going on. The data is available as a database as well as NetCDF files.

## Create EARS datagrams

EARS needs three datagrams put on the network in a very specific format, each for navigation, thermosalinometry and meteorology (weather).

If the data is sent out via a serial port, it needs to be put on Ethernet. This can be done by using a MOXA Nport 5410 Serial Device Server.

The techniques needed to combine data into the datagrams are not part of these guidelines and are understood to be programmable by sysadmins.

**Datagram description navigation data (POS):**

Start identifier

Format$PSDGPOS

Date of position

Formatddmmyy

UTC time of position

Formathhmmss

Longitude in decimal degrees

Latitude in decimal degrees

Ship heading in °

FO/AF speed in kn

Water depth in m

Course over ground in °

Speed over ground in kn

_ **Example:** _

$PSDGPOS,131017,132035,3.01803,51.44738,216.2,8.9,

-27.7,215.4,8.7

**Datagram description thermosalinograph data (TSS):**

Start identifier

Format $PSDGTSS

Date of position

Format ddmmyy

UTC time of position

Format hhmmss

Sea water temperature in °C

Salinity in PSU

Sigma theta in kg/m³

Conductivity in S/m

Raw fluorometry in V

_ **Example:** _

$PSDGTSS,131017,132035,14.7808,33.5449,24.8983,41.1335,0.6275

**Datagram description MET (meteo data):**

Start identifier

Format $PSDGMET

Date of position

Format ddmmyy

UTC time of position

Format hhmmss

Mean wind speed in m/s

Wind gust speed in m/s

Wind direction in °

Air temperature in °C

Humidity in %

Solar radiation in W/m²

Atmospheric pressure in hPa

Sea water temperature in °C

_ **Example:** _

$PSDGMET,131017,132035,2.81,2.81,150.4,11.05,,189.07,1018.12

## Install docker (on physical or virtual machine)

Ubuntu: Follow the guidelines on [https://docs.docker.com/install/linux/docker-ce/ubuntu/](https://docs.docker.com/install/linux/docker-ce/ubuntu/)

Debian, CentOS, Fedora also available.

After installation, ensure that the docker daemon will be started when the server or virtual machine reboots, and start it right now:

```
sudo systemctl enable docker && sudo systemctl start docker
```

## Install docker-compose

Ubuntu: follow the guidelines on https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-18-04:

- Verify the current release of docker-compose on `https://github.com/docker/compose/releases`
- Install it: ```sudo curl -L https://github.com/docker/compose/releases/download/<version>/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose```
- And set the permissions: `sudo chmod +x /usr/local/bin/docker-compose`

## Install git

Ubuntu:

```
sudo apt-get update
sudo apt-get install git
```

## Get the required files for the EARS server, including the Dockerfile

Go to where you want to install the docker container. The location has no special need for permissions, as all docker operations require root rights anyway. `/home/general-user/` is a fine location, where general-user is the name of a general user.

```
cd <installation directory>
git clone https://github.com/naturalsciences/ears-server.git
cd ears-server
```

## Change the username and password to modify the vessel ontology

Only to save the vessel ontology a password and username is needed. This username and password needs to be provided in the options of the EARS front-end application as well. This step is optional but essential if you want to protect the vessel ontology (else the password &#39;REPLACEME&#39; remains the default).

Modify these lines in the Dockerfile to your username and password:

```
RUN echo 'be.naturalsciences.bmdc.ears.ontology.rest.username=earsontology' > /etc/.java/ears.properties
RUN echo 'be.naturalsciences.bmdc.ears.ontology.rest.password=REPLACEME' >> /etc/.java/ears.properties
```

If you modify the Dockerfile, or any file except the docker-compose.yml file for that matter, you will need to rebuild the image(``sudo docker-compose build``).

## Create the docker container and run the image

```
sudo docker-compose build
sudo docker-compose up -d
```

The -d flag starts the container based on the image in a detached mode, meaning that you can continue the terminal session. If you shutdown and reboot the server that hosts the EARS server container, the container will always restart along with the whole server.

When you run the image, the different components are started in certain order. The web server (tomcat) is the latest as it has to wait for the database to be completed. Wait at least a minute, then visit the following addresses in your web browser:

http://localhost:8181/ears3/html/event

http://localhost:8181/ears3/events

http://localhost:8181/ears3Nav/tss/getLast/xml
http://localhost:8181/ears3Nav/tss/getLast/datagram
http://localhost:8181/ears3Nav/tss/getLast/json
http://localhost:8181/ears3Nav/met/getLast/xml
http://localhost:8181/ears3Nav/met/getLast/json
http://localhost:8181/ears3Nav/met/getLast/datagram
http://localhost:8181/ears3Nav/nav/getLast/xml
http://localhost:8181/ears3Nav/nav/getLast/json
http://localhost:8181/ears3Nav/nav/getLast/datagram

http://localhost:8181/ears3Nav/tss/getNearest/xml?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/tss/getNearest/json?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/tss/getNearest/datagram?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/met/getNearest/xml?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/met/getNearest/json?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/met/getNearest/datagram?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/nav/getNearest/xml?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/nav/getNearest/json?date=2021-06-25T08:39:00
http://localhost:8181/ears3Nav/nav/getNearest/datagram?date=2021-06-25T08:39:00

http://localhost:8181/ears3Nav/tss/getBetween/xml?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/tss/getBetween/json?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/tss/getBetween/datagram?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/met/getBetween/xml?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/met/getBetween/json?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/met/getBetween/datagram?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/nav/getBetween/xml?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/nav/getBetween/json?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z
http://localhost:8181/ears3Nav/nav/getBetween/datagram?startDate=2020-08-18T00:00:00Z&endDate=2021-06-25T08:39:00Z

http://localhost:8080 for the acquisition server

Replace localhost:8080 localhost:8181 with the server&#39;s IP adress and the actual port you have configured (see lower).

Make sure that the server is accessible from the network.

## Adresses and ports

The EARS webservices are reachable on [http://localhost:818](http://localhost:8080/)1 and the acquisition server on [http://localhost:808](http://localhost:8080/)0, by default. You can modify these ports in the .env file but this is not recommended. If a port is already taken, you either change the port in the .env file, or preferrably kill the application that takes the port. In order to find applications using a port, use eg. `sudo netstat -tulpn | grep 8080`, note the pid in the last column and then `sudo kill <pid>`

## View the database, e.g. with MySQL Workbench

Install MySQL Workbench

```
sudo apt-get install mysql-workbench
```

First retrieve the ip address of the MySQL container:

```
sudo docker inspect ears-server_mysql
```

Shorthand:

```
sudo docker inspect ears-server_mysql | pcregrep -o1 &#39;&quot;IPAddress&quot;: &quot;([0-9\.]+)&quot;&#39;
```

and note the value for the key &quot;IPAddress&quot;.

Create a new connection in MySQL Workbench towards this IP address, using as database name &#39;casino&#39;, user &#39;casino&#39; and password &#39;casino&#39;, and using the default port 3306.

## Or by command line

With command line mysql, you can use:

```
ip=$(sudo docker inspect ears-server_mysql | pcregrep -o1 '"IPAddress": "([0-9\.]+)"') \
mysql -h $ip -u casino -p casino -e 'show tables;'
```

Type the password (casino) and verify the tables have been created correctly. Later you can use this to verify data insertion, eg. by:

```
mysql -h $ip -u casino -p casino -e 'select * from Navigation limit 10;'
mysql -h $ip -u casino -p casino -e 'select * from event limit 10;'
```

## Verify the acquisition works

The acquisition module stores the datagrams created above as NetCDF files and in the EARS database as above. For EARS to work, the navigation datagram must be sent to UDP port 3101 of the server EARS is running on, the meteorology datagram to UDP port 3102 and the Thermosalinometry datagram to UDP port 3103.

This ideally only works on a research vessel. To test if the acquisition server has correctly run, we provide a small test program that can send fake information to these ports. This can be found in the FileToUDP/ directory.

For this you need to install Java JDK 8 on the host running the docker. On Ubuntu:

```
sudo apt install openjdk-8-jdk openjdk-8-jre
```

If you have a more recent version of java, enable java 8 temporarily (inside the docker java is run as well, but this is independent from what is run on the host).

Then, to run the program, type:

```
java -jar FileToUDP/FileToUDP.jar FileToUDP/09022016.posicion.raw 3101 1
```

You immediately see the output being sent. In order to run this process in the background and log what it wrote to a log file, use the following three commands for resp. position, meteorology and thermosalinometry.

```
nohup java -jar FileToUDP/FileToUDP.jar FileToUDP/09022016.posicion.raw  3101 1 > ~/filetoudp.log 2>&1 &
nohup java -jar FileToUDP/FileToUDP.jar FileToUDP/08052016.meteo.raw  3102 1 > ~/filetoudp.log 2>&1 &
nohup java -jar FileToUDP/FileToUDP.jar FileToUDP/09052016.termosal.raw 3103 1 > ~/filetoudp.log 2>&1 &
```

Inspect this actually is received by the acqusion module by reading the log output of docker for it:

```
sudo docker logs ears-server_acquisition
```

The data is also saved as NetCDF files. These can be found in the netcdf/ directory for nav, met and tss. Please note that a full day of navigation from the above fake datagram would take about 2 GB of data. So in some scenarios you might want to disable the creation of these files. However, for the 2020 Eurofleets+ campaigns, the Principal Investigator must report these NetCDF files in the EMODnet Ingestion Portal together with his other campaign data. So please keep this enabled and send him these files, as he will need them for his data submission!

To disable EARS from creating these NetCDF files, comment out the following lines in the file Acquisition\_System/bin/conf/application.properties:

```
acquisition.archiving.netcdf.file=./log/netcdf/{sensor}/{sensor}-{frame}-{date,yyyy-Mmdd-HH}.nc
```

After this, kill the three docker containers, rebuild and restart them:

```
sudo docker kill ears-server_acquisition
ears-server_tomcat ears-server_mysql
sudo docker-compose build
sudo docker-compose up -d
```

## Data volumes

In order to persist the crucial information in the database and the ontology and to safeguard it for when the docker container would be restarted or even deleted, the data is persisted in a directory outside of the docker container. These are &#39;ears\_mysql\_data&#39; and &#39;ontologies&#39;. Do not delete these directories.

## Troubleshooting

You can read the logs of the individual modules like so:

The database: `sudo docker logs ears-server_mysql`

The web applications: `sudo docker logs ears-server_tomcat`

The acquisition module: `sudo docker logs ears-server_acquisition`

If you need to kill the docker images, for instance if you make a change in the Dockerfile, enter the following command:

```
sudo docker kill ears-server_acquisition
ears-server_tomcat ears-server_mysql
```

The Dockerfile should not be changed, only to change the access password for the vessel ontology, see higher.

## Coping with updates

If a new version of any web application (ears2.war, ears2Nav.war) would need a replacement (of which you will be informed by email) please follow this procedure:

- Ensure you have a stable and fast internet connection
- ssh to the server
- cd to the ears-server directory
```
sudo docker kill ears-server_acquisition
ears-server_tomcat ears-server_mysql
git pull origin master
sudo docker-compose build
sudo docker-compose up -d
```

The build command is smart enough to start rebuilding only the steps that are not affected by the file change (so this is faster than the original build).
