# SignDict.org

A crowdsourced sign language dictionary.

[![Build Status](https://travis-ci.org/signdict/website.svg?branch=master)](https://travis-ci.org/signdict/website)
[![Coverage Status](https://coveralls.io/repos/github/signdict/website/badge.svg?branch=master)](https://coveralls.io/github/signdict/website?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/signdict/website.svg)](https://beta.hexfaktor.org/github/signdict/website)
[![Join the chat at https://gitter.im/signdict/lobby](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/signdict/lobby)

Here we will work on SignDict. A sign language dictionary
where everyone can add new signs using their webcam. With
this unique crowdsourcing approach we together can create
the most accurate sign language dictionary there is.

**You want to help?** Awesome. [Please read this](https://github.com/signdict/website/wiki/Help-needed).

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
yarn
mix phoenix.server
```

### Linux instructions:

Note: If you run into postgres password authentication errors, check out [this blogpost for help](https://juwondaniel.wordpress.com/2016/09/23/solve-mix-ecto-create-postgresql-password-issue-with-phoenix/).

```bash
mix deps.get
mix ecto.setup
sudo apt install npm
sudo npm install -g yarn
yarn
mix phoenix.server
```

With that you have a running system and a default admin user called
`admin@example.com` with the password `thepasswordisalie`.

Before you contribute code, please make sure to read the [CONTRIBUTING.md](CONTRIBUTING.md)

In development mode `Bamboo` will not sent emails. Instead you can see what
would have been sent out here: `http://localhost:4000/sent_emails`

This project is using [yarn](http://yarnjs.com/) for javascript dependency management.

You can also use the included `Procfile` to start redis and the phoenix server at
the same time. Install `foreman` with `gem install foreman` and execute `foreman start`
to have both started automatically.

## Deployment

The system is currently deployed using [gatling](https://github.com/hashrocket/gatling).
Simply execute `git push production master` to push to the repository on the server.
The rest should be automated.

## Funding

This project is government funded by the [German Federal Ministry of Education and Research](http://bmbf.de)
and is part of the 1st batch of the [prototype fund](http://prototypefund.de).

![Logo of the German Federal Ministry of Education and Research](images/support-bmbf.png)
![Prototype Fund Logo](images/support-prototype.png)

