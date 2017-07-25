import "phoenix_html"

import Turbolinks from "turbolinks"
Turbolinks.start();

import browser from 'detect-browser';
window.browser = browser;

import Player from "./classes/player.js";
new Player().init();
