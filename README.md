# dosh
docker dashboard on rails
by lennart.heim@rwth-aachen.de

## description

dosh is a simple web dashboard built with ruby on rails. it is still under development and part of my bachelor thesis **'Network Virtualization for Automatic Deployment of SDR-Based Wireless Experiments'** at the Institute for Networked Systems, RWTH Aachen University.


## installation

running the rails application in a docker container is the easiest setup. just pull the image and run it with the given settings.
###using docker.io
example usage for a linux system where you mount the docker socket from the host machine
```bash
docker pull lheim/dosh:latest
docker run --name dosh -d -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock lheim/dosh:latest
```
###latest version
to run the latest version you can also clone the project and build the docker image with the given dockerfile.

```bash
git clone https://github.com/lheim/dosh
cd dosh
docker build . -t lheim/dosh
docker run --name dosh -d -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock lheim/dosh:latest
```

###example usage for macOS
when you run the project on a macOS or windows machine make sure that environment variable 'DOCKER_HOST' is set to the ip of your VM. mounting the docker socket is not necessary.

```bash
docker-machine start default
eval $(docker-machine env)
[...]
```



##usage

pretty straight forward.
