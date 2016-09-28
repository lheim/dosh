#dosh
docker dashboard on rails

##description
dosh is a simple web dashboard built with ruby on rails. it is still under development and part of my bachelor thesis **'Network Virtualization for Automatic Deployment of SDR-Based Wireless Experiments'** at the Institute for Networked Systems, RWTH Aachen University.
it is made to work within a docker swarm setup.

###branches
####master and docker-usrp:
as you can read in the title of my thesis, part of my setup are the 'SDR-Based Experiments'. this branch got more features which are necessary to discover USRPs (UHD driver) and allow the assignment of USRPs to containers.
####docker-normal:
normal docker web dashboard with all basic features. none additional features to set up SDR experiments.


##installation
running the rails application in a docker container is the easiest setup. just pull the image and run it with the given settings.

###using hub.docker.com
example usage for a linux system where you mount the docker socket from the host machine:
```bash
docker pull lheim/dosh-automated:usrp
docker run --name dosh -d -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock lheim/dosh-automated:usrp
```
or using the DOCKER_HOST environment variable (necessary for docker swarm):

```bash
docker pull lheim/dosh-automated:usrp
docker run --name dosh -d -p 3000:3000 --net=host -e "DOCKER_HOST=tcp://192.168.1.100:3376" lheim/dosh-automated:usrp
```

if needed mount the usb devices to avoid UHD errors:

```bash
docker pull lheim/dosh-automated:usrp
docker run --name dosh -d -p 3000:3000 --net=host -v /dev/bus/usb:/dev/bus/usb -e "DOCKER_HOST=tcp://192.168.1.100:3376" lheim/dosh-automated:usrp
```


###latest version
the container https://hub.docker/com/r/lheim/dosh-automated is always up to date and is being rebuild every time this repo is updated.


###example usage for macOS
when you run the project on a macOS or windows machine make sure that the environment variable 'DOCKER_HOST' is set to the ip of your VM and is passed as environment variable to the container.

```bash
docker pull lheim/dosh-automated:usrp
docker run --name dosh -d -p 3000:3000 -e "DOCKER_HOST=$(DOCKER_HOST)" lheim/dosh-automated:usrp
```

##usage
you can access the server via http://localhost:3000 or http://CONTAINER_IP:3000.
the rest is pretty straight forward.
