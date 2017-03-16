# SignDict.org

A crowdsourced sign language dictionary.

[![Build Status](https://travis-ci.org/signdict/website.svg?branch=master)](https://travis-ci.org/signdict/website)
[![Coverage Status](https://coveralls.io/repos/github/signdict/website/badge.svg?branch=master)](https://coveralls.io/github/signdict/website?branch=master)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/signdict/website.svg)](https://beta.hexfaktor.org/github/signdict/website)
[![Slack invite](https://img.shields.io/badge/Slack-Invite-green.svg)](https://signdict-slack-invite.herokuapp.com/)

Here we will work on SignDict. A sign language dictionary
where everyone can add new signs using their webcam. With
this unique crowdsourcing approach we together can create
the most accurate sign language dictionary there is.

**You want to help?** Awesome. [Please read this](https://github.com/signdict/website/wiki/Help-needed).

## Development setup

SignDict uses Elixir and Phoenix. If you are used to both, the setup is as
you would expect it to be:

```
mix deps.get
mix ecto.setup
mix phoenix.server
```

After that you have a running system with a default admin user called
`admin@example.com` with the password `thepasswordisalie`.

Before you contribute code, please make sure to read the [CONTRIBUTING.md](CONTRIBUTING.md)

In development mode `Bamboo` will not sent emails. Instead you can see what
would have been sent out here: `http://localhost:4000/sent_emails`

## Funding

This project is government funded by the [German Federal Ministry of Education and Research](http://bmbf.de)
and is part of the 1st batch of the [prototype fund](http://prototypefund.de).

![Logo of the German Federal Ministry of Education and Research](images/support-bmbf.png)
![Prototype Fund Logo](images/support-prototype.png)
