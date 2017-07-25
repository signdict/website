import plyr from "plyr"

class Player {
  init() {
    document.addEventListener("turbolinks:load", function() {
      let videos = document.getElementsByTagName('video');
      var controls = ["<div class='plyr__controls'>",
        "<button type='button' data-plyr='play'>",
            "<svg><use xlink:href='#plyr-play'></use></svg>",
            "<span class='plyr__sr-only'>Play</span>",
        "</button>",
        "<button type='button' data-plyr='pause'>",
            "<svg><use xlink:href='#plyr-pause'></use></svg>",
            "<span class='plyr__sr-only'>Pause</span>",
        "</button>",
        "<span class='plyr__progress'>",
            "<label for='seek{id}' class='plyr__sr-only'>Seek</label>",
            "<input id='seek{id}' class='plyr__progress--seek' type='range' min='0' max='100' step='0.1' value='0' data-plyr='seek'>",
            "<progress class='plyr__progress--played' max='100' value='0' role='presentation'></progress>",
            "<progress class='plyr__progress--buffer' max='100' value='0'>",
                "<span>0</span>% buffered",
            "</progress>",
            "<span class='plyr__tooltip'>00:00</span>",
        "</span>",
        "<span class='plyr__time'>",
            "<span class='plyr__sr-only'>Current time</span>",
            "<span class='plyr__time--current'>00:00</span>",
        "</span>",
        "<button class='plyr_playrate' type='button' data-plyr='playrate'>",
            "<i style='font-size: 1.6em' class='fa fa-tachometer' aria-hidden='true'></i>",
            "<span class='plyr__sr-only'>Change playback rate</span>",
        "</button>",
        "<button type='button' data-plyr='fullscreen'>",
            "<svg class='icon--exit-fullscreen'><use xlink:href='#plyr-exit-fullscreen'></use></svg>",
            "<svg><use xlink:href='#plyr-enter-fullscreen'></use></svg>",
            "<span class='plyr__sr-only'>Toggle Fullscreen</span>",
        "</button>",
      "</div>"].join("");
      plyr.setup(videos, {
        debug: true,
        html: controls
      });
      if (videos.length > 0 ) {
        addSpaceListener(videos[0]);
      }
    });
  }
}

const INGORED_ELEMENTS = [
  "INPUT", "A", "BUTTON", "TEXTAREA"
]

function addSpaceListener(video) {
  window.onkeydown = function(e) {
    if (e.key == " " && INGORED_ELEMENTS.indexOf(e.target.nodeName) == -1) {
      if (video.paused) {
        video.play();
      } else {
        video.pause();
      }
      e.preventDefault();
    }
  }
}

export default Player;
