// Import the CSS so webpack emits it as css/app.css.
import '../css/app.scss';

import 'phoenix_html';
import 'babel-polyfill';

if (window.Element && !Element.prototype.closest) {
  Element.prototype.closest = function (s) {
    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
      i,
      el = this;
    do {
      i = matches.length;
      while (--i >= 0 && matches.item(i) !== el) {}
    } while (i < 0 && (el = el.parentElement));
    return el;
  };
}

import * as Turbo from '@hotwired/turbo';
// Like Turbolinks, only handle link navigation: forms submit normally, so
// controllers can keep re-rendering them with a 200 on validation errors.
Turbo.config.forms.mode = 'off';

import {detect} from 'detect-browser';
window.browser = detect();

import Player from './classes/player.js';
new Player();

import {Application} from 'stimulus';
import {definitionsFromContext} from 'stimulus/webpack-helpers';

const application = Application.start();
const context = require.context('./controllers', true, /\.js$/);
application.load(definitionsFromContext(context));

// Set autofocus to search bar on non-mobile devices
window.onload = function () {
  var em = parseFloat(getComputedStyle(document.documentElement).fontSize);

  // Breakpoint is 48em, the same as in the CSS
  if (window.innerWidth > 48 * em) {
    // There is never more than one element with one of these classes, therefore this works
    var searchbar_classes = ['so-searchbar--input--inner', 'so-landing--search--input'];
    searchbar_classes.map((classname) => {
      var searchbars = document.getElementsByClassName(classname);
      if (searchbars[0]) {
        searchbars[0].focus();
      }
    });
  }
};
