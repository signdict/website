# SignDict.org

A crowdsourced sign language dictionary.

[![Build Status](https://github.com/signdict/website/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/signdict/website/actions/workflows/elixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/signdict/website/badge.svg?branch=main)](https://coveralls.io/github/signdict/website?branch=main)

Here we will work on SignDict. A sign language dictionary
where registered users can add new signs using their webcam.
With the crowdsourcing approach we can create the most accurate
and largest German sign language dictionary together.

**You want to help?** Awesome. Scroll through the issues, open a new one, join our [Gitter Community](https://gitter.im/signdict/Lobby) or just send
a short notice using the [contact form](https://signdict.org/contact). We are happy about every person who wants to help.

We also offer an [API](https://github.com/signdict/website/wiki/API).

## Development setup

SignDict uses Elixir and Phoenix. Information on how
to install Elixir can be found [here](http://elixir-lang.org/install.html).

For the video transcoding it uses [redis](http://redis.io). On
mac, install it via `brew install --cask redis`, or `sudo apt install redis-server` for Linux and start it.

As database it uses [PostgreSQL](http://postgresql.org).

After you installed everything, the setup is as follows:

### Mac instructions

```bash
mix ua_inspector.download
mix deps.get
mix ecto.setup
cd assets/ && yarn install && cd ..
mix phx.server
```

### Linux instructions

Note: If you run into postgres password authentication errors, check out [this blogpost for help](https://juwondaniel.wordpress.com/2016/09/23/solve-mix-ecto-create-postgresql-password-issue-with-phoenix/).

```bash
mix deps.get
mix ecto.setup
sudo apt install npm
sudo npm install -g yarn
cd assets/ && yarn install && cd ..
mix phx.server
```

### How to run the suite

```bash
mix test
```

## Deployment

The server is configured using [ansible](https://www.ansible.com/) with [this playbook](/ansible/playbook.yml) and can be updated with:

```bash
ansible-playbook ansible/playbook.yml -i ansible/hosts --extra-vars '{"username": "******"}'
```

The system is currently using [bootleg](https://github.com/labzero/bootleg) to
deploy the app. Simply call `bootleg_user=USERNAME mix bootleg.update` to
deploy it to the production environment.

## Importing files manually

You can import a file using a json file with `mix importer file.json`. The json should have [this](test/fixtures/videos/Zug.json) format.

## Funding

This project is government funded by the [German Federal Ministry of Education and Research](http://bmbf.de)
and is part of the 1st batch of the [prototype fund](http://prototypefund.de).

![Logo of the German Federal Ministry of Education and Research](images/support-bmbf.png)
![Prototype Fund Logo](images/support-prototype.png)
