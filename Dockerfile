FROM rails:4.2.5
MAINTAINER lennart.heim@rwth-aachen.de

RUN apt-get update
RUN apt-get install -y libuhd-dev libuhd003 uhd-host
RUN git clone https://github.com/lheim/dosh

WORKDIR /dosh

ENV RAILS_ENV development

RUN bundle install

RUN rake assets:precompile

RUN rake db:migrate
RUN rake db:seed

EXPOSE 3000
CMD rails s -b 0.0.0.0
