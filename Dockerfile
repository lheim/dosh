FROM lheim/rails_uhd:latest
MAINTAINER lennart.heim@rwth-aachen.de

# RUN apt-get update
# RUN apt-get install -y libboost-all-dev libusb-1.0-0-dev python-mako doxygen python-docutils cmake build-essential
# RUN git clone git://github.com/EttusResearch/uhd.git && cd uhd && git checkout maint
# RUN cd uhd/host && mkdir build
# WORKDIR /uhd/host/build
# RUN cmake ../
# RUN make
# RUN make test
# RUN make install
# RUN ldconfig


RUN git clone https://github.com/lheim/dosh

WORKDIR /dosh

ENV RAILS_ENV development

RUN bundle install

RUN rake assets:precompile

RUN rake db:migrate
RUN rake db:seed

EXPOSE 3000
CMD rails s -b 0.0.0.0
