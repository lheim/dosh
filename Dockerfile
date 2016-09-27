FROM rails:4.2.5
MAINTAINER lennart.heim@rwth-aachen.de

RUN apt-get update

RUN apt-get install -y python-pip python-dev build-essential
RUN pip install PyBOMBS
RUN pybombs prefix init /usr/local -a usrlocal
RUN pybombs config default_prefix /usr/local
RUN pybombs recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git
RUN pybombs recipes add gr-etcetera git+https://github.com/gnuradio/gr-etcetera.git
RUN pybombs install uhd

#RUN apt-get install -y libuhd-dev libuhd003 uhd-host

RUN git clone https://github.com/lheim/dosh

WORKDIR /dosh

ENV RAILS_ENV development

RUN bundle install

RUN rake assets:precompile

RUN rake db:migrate
RUN rake db:seed

EXPOSE 3000
CMD rails s -b 0.0.0.0
