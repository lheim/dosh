FROM rails:4.2.5
MAINTAINER lennart.heim@rwth-aachen.de

RUN apt-get update
RUN apt-get install -y libboost-all-dev libusb-1.0-0-dev python-mako doxygen python-docutils cmake build-essential
RUN git clone git://github.com/EttusResearch/uhd.git && cd uhd && git checkout maint
RUN cd uhd/host && mkdir build
RUN cd /uhd/host/build && cmake ../ && make && make test && make install && ldconfig
WORKDIR /
