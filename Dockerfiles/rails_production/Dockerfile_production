FROM rails:4.2.5
MAINTAINER lennart.heim@rwth-aachen.de


RUN git clone https://github.com/lheim/dosh

WORKDIR /dosh

ENV RAILS_ENV production

RUN bundle install
RUN rake db:migrate
RUN rake db:seed
RUN rake assets:precompile

EXPOSE 3000
CMD rails s -b 0.0.0.0 -e production
