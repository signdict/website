# Contributing

**Please note that this project is released with a Contributor [Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to
abide by its terms.**

## Contributing Code aka. The Pamphlet

* If you need help setting this project up, check out the [README](README.md).
  If you run into problems setting up the project for development don't
  hesitate to [open an issue](https://github.com/signdict/website/issues/new).
* Pick a Ticket
* Leave a comment that you want to work on this you ticket
* We will assign it to you and assist if you have any questions
* Start hacking
* If you change text on the website, make sure to use gettext and
  call `mix gettext.extract --merge` to update the i18n files. You
  don't have to add all translations yourself, we will take care of
  all languages you are not fluent in :wink:
* Open a pull-request and work on a feature branch. During the work on your branch:
    * [Credo](https://github.com/rrrene/credo) will check for common code quality problems
    * A CI server provides feedback for your branch. We're using [Travis CI](http://travis-ci.org) to help us with this job.
* As soon as your feature is ready to be merged, you rebase the branch onto master and clean up your commit history
    * When you're ready, create a pull request.
    * We will review your branch and signal its readiness with a :shipit: or a
      GIF of our choosing. If there's feedback, we will discuss it with you.
      Don't worry - the worst thing that could happen to you, is being
      overwhelmed by a bunch of animated GIFs.
    * If you're good to go, we will click the shiny green 'Merge' button, and
      your ticket will be closed automatically.
* Welcome aboard! (You get extra points for deleting your old feature branch!)

_This contributing guide is a modified version of the guide by [hacken_in](https://github.com/hacken-in/hacken-in/blob/master/CONTRIBUTING.md)_
