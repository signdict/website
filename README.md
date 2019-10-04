# SignDict.org

A crowdsourced sign language dictionary.

[![Build Status](https://travis-ci.com/signdict/website.svg?branch=master)](https://travis-ci.com/signdict/website)
[![Coverage Status](https://coveralls.io/repos/github/signdict/website/badge.svg?branch=master)](https://coveralls.io/github/signdict/website?branch=master)
[![Join the chat at https://gitter.im/signdict/lobby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/signdict/lobby)

Here we will work on SignDict. A sign language dictionary
where everyone can add new signs using their webcam. With
this unique crowdsourcing approach we together can create
the most accurate sign language dictionary there is.

**You want to help?** Awesome. Scroll through the issues, open a new one, join our [Gitter Community](https://gitter.im/signdict/Lobby) or just send
a short notice using the [contact form](https://signdict.org/contact). We are happy about every person who wants to help.

We also offer an [API](https://github.com/signdict/website/wiki/API).

## Development setup

SignDict uses Elixir and Phoenix. Information on how
to install Elixir can be found [here](http://elixir-lang.org/install.html).

For the video transcoding it uses [redis](http://redis.io). On
mac, install it via `brew install redis-server`, or `sudo apt install redis-server` for Linux and start it.

As database it uses [PostgreSQL](http://postgresql.org).

After you installed everything, the setup is as follows:

### Mac instructions:

```bash
mix deps.get
mix ecto.setup
cd assets/ && yarn install && cd ..
mix phx.server
```

### Linux instructions:

Note: If you run into postgres password authentication errors, check out [this blogpost for help](https://juwondaniel.wordpress.com/2016/09/23/solve-mix-ecto-create-postgresql-password-issue-with-phoenix/).

```bash
mix deps.get
mix ecto.setup
sudo apt install npm
sudo npm install -g yarn
cd assets/ && yarn install && cd..
mix phx.server
```

### Docker instructions:

First, make the PostgreSQL and redis servers point to the docker services. Change `hostname: "localhost"` to `hostname: "db"` in `config/dev.exs`, and add `host: "redis"` to the `:exq` section in `config/config.exs`.

Then run

```bash
docker-compose up
```

to install all dependencies and start the PostgreSQL, redis and web server services (including code reloading). The website is available at http://localhost:4000.

With that you have a running system and a default admin user called
`admin@example.com` with the password `thepasswordisalie`.

Before you contribute code, please make sure to read the [CONTRIBUTING.md](CONTRIBUTING.md)

In development mode `Bamboo` will not sent emails. Instead you can see what
would have been sent out here: `http://localhost:4000/sent_emails`

This project is using [yarn](http://yarnjs.com/) for javascript dependency management.

You can also use the included `Procfile` to start redis and the phoenix server at
the same time. Install `foreman` with `gem install foreman` and execute `foreman start`
to have both started automatically.

### How to run the suite

```bash
mix test
```

## Deployment

The system is currently using [bootleg](https://github.com/labzero/bootleg) to
deploy the app. Simply call `bootleg_user=USERNAME mix bootleg.update` to
deploy it to the production environment.

## Funding

This project is government funded by the [German Federal Ministry of Education and Research](http://bmbf.de)
and is part of the 1st batch of the [prototype fund](http://prototypefund.de).

![Logo of the German Federal Ministry of Education and Research](images/support-bmbf.png)
![Prototype Fund Logo](images/support-prototype.png)

