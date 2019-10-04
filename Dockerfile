FROM elixir:1.9-slim

RUN apt-get update && \
    apt-get install -y git build-essential inotify-tools curl

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash
RUN apt-get install -y nodejs
RUN npm install -g yarn

RUN mkdir signdict

COPY . /signdict

EXPOSE 4000
CMD sh -c "/signdict/docker-entrypoint.sh"
