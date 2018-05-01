import "phoenix_html"
import "babel-polyfill"

if (window.Element && !Element.prototype.closest) {
  Element.prototype.closest = function(s) {
    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
      i,
      el = this;
    do {
      i = matches.length;
      while (--i >= 0 && matches.item(i) !== el) {};
    } while ((i < 0) && (el = el.parentElement));
    return el;
  };
}

import Turbolinks from "turbolinks"
Turbolinks.start();

import browser from 'detect-browser';
window.browser = browser;

import Player from "./classes/player.js";
new Player().init();
