import "phoenix_html"

import Turbolinks from "turbolinks"
Turbolinks.start();

import plyr from "plyr"
document.addEventListener("turbolinks:load", function() {
  plyr.setup(document.getElementsByTagName('video'), {
    controls: [
      'play-large', 'play', 'progress', 'current-time', 'fullscreen'
    ]
  });
});

