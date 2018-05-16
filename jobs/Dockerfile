FROM ruby:2.5.1

RUN mkdir /app && gem install --no-ri --no-rdoc sinatra

ADD sinatra_app.ru /app

WORKDIR /app

EXPOSE 3000

CMD ruby sinatra_app.ru -p 3000
