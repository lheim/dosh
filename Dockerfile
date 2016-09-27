FROM lheim/rails_uhd:0.1
MAINTAINER lennart.heim@rwth-aachen.de


RUN git clone https://github.com/lheim/dosh

WORKDIR dosh

ENV RAILS_ENV development
ENV DOCKER_HOST tcp://192.168.99.100:3376

RUN bundle install

RUN rake assets:precompile

RUN rake db:migrate
RUN rake db:seed

EXPOSE 3000
CMD rails s -b 0.0.0.0
