import plyr from "plyr"

class Player {
  init() {
    document.addEventListener("turbolinks:load", function() {
      let videos = document.getElementsByTagName('video');
      plyr.setup(videos, {
        controls: [
          'play-large', 'play', 'progress', 'current-time', 'fullscreen'
        ]
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
