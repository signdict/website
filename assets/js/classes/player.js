import plyr from "plyr"
import translate from "./translate";

class Player {
  init() {
    document.addEventListener("turbolinks:load", function() {
      let videos = document.getElementsByTagName('video');
      if (videos.length > 0 ) {
        addPlyr(videos);
        addKeyListener(videos[0]);
      }
    });
  }
}

function addPlyr(videos) {
  var controls = ["<div class='plyr__controls'>",
    "<button type='button' data-plyr='play'>",
        "<svg><use xlink:href='#plyr-play'></use></svg>",
        `<span class='plyr__sr-only'>${translate("Play")}</span>`,
    "</button>",
    "<button type='button' data-plyr='pause'>",
        "<svg><use xlink:href='#plyr-pause'></use></svg>",
        `<span class='plyr__sr-only'>${translate("Pause")}</span>`,
    "</button>",
    "<span class='plyr__progress'>",
        "<label for='seek{id}' class='plyr__sr-only'>Seek</label>",
        "<input id='seek{id}' class='plyr__progress--seek' type='range' min='0' max='100' step='0.1' value='0' data-plyr='seek'>",
        "<progress class='plyr__progress--played' max='100' value='0' role='presentation'></progress>",
        "<progress class='plyr__progress--buffer' max='100' value='0'>",
            `<span>0</span>% ${translate("buffered")}`,
        "</progress>",
        "<span class='plyr__tooltip'>00:00</span>",
    "</span>",
    "<span class='plyr__time'>",
        `<span class='plyr__sr-only'>${translate("Current time")}</span>`,
        "<span class='plyr__time--current'>00:00</span>",
    "</span>",
    "<button class='plyr_playrate' type='button' data-plyr='playrate'>",
        "<i style='font-size: 1.6em' class='fa fa-tachometer' aria-hidden='true'></i>",
        `<span class='plyr__sr-only'>${translate("Change playback rate")}</span>`,
    "</button>",
    "<button type='button' data-plyr='fullscreen'>",
        "<svg class='icon--exit-fullscreen'><use xlink:href='#plyr-exit-fullscreen'></use></svg>",
        "<svg><use xlink:href='#plyr-enter-fullscreen'></use></svg>",
        `<span class='plyr__sr-only'>${translate("Toggle Fullscreen")}</span>`,
    "</button>",
  "</div>"].join("");
  plyr.setup(videos, {
    html: controls
  });
  let playrateButtons = document.getElementsByClassName("plyr_playrate");
  for (let element of playrateButtons) {
    element.onclick = togglePlayrateMenu;
  }
}

function togglePlayrateMenu(event) {
  let plyr   = event.target.closest(".plyr");
  let video  = plyr.getElementsByTagName("video");
  let menu   = plyr.getElementsByClassName("playrate-menu")
  let button = event.target.closest("button");
  if (menu.length == 0) {
    showPlayrateMenu(plyr, button);
  } else {
    hidePlayrateMenu(menu[0], button);
  }
}

function showPlayrateMenu(plyr, button) {
  let menu = document.createElement("div");
  menu.setAttribute("class", "playrate-menu plyr__tooltip plyr__tooltip--visible");
  menu.innerHTML =
    "<ul class='playrate-menu--list'>" +
      "<li><a class='playrate-menu--link' href='#' data-speed='0.25'>0.25x</a></li>" +
      "<li><a class='playrate-menu--link' href='#' data-speed='0.5'>0.50x</a></li>" +
      "<li><a class='playrate-menu--link' href='#' data-speed='0.75'>0.75x</a></li>" +
      "<li><a class='playrate-menu--link' href='#' data-speed='1'>1.00x</a></li>" +
    "</ul>"
  plyr.appendChild(menu);
  let plyrPosition = plyr.getBoundingClientRect().left;
  let position = button.getBoundingClientRect().left -
                 plyrPosition + button.clientWidth / 2;
  menu.setAttribute("style", `left: ${position}px`);
  toggleClass(button, 'playrate-menu--active', true)
  linkPlayrateSpeedButton(plyr);
  highlightCurrentPlayrate(plyr, menu);
}

function linkPlayrateSpeedButton(plyr) {
  let playrateButtons = plyr.getElementsByClassName("playrate-menu--link");
  for (let element of playrateButtons) {
    element.onclick = function(event) {
      updatePlaybackRate(plyr, event);
    }
    element.onkeyup = function(event) {
      if (getKeyCode(event) == 13) {
        updatePlaybackRate(plyr, event);
      }
    }
  }
}

function updatePlaybackRate(plyr, event) {
  let video  = plyr.getElementsByTagName("video")[0];
  let menu   = plyr.getElementsByClassName("playrate-menu")[0];
  let button = plyr.getElementsByClassName("plyr_playrate")[0];
  let speed  = parseFloat(event.target.getAttribute("data-speed"));
  hidePlayrateMenu(menu, button);
  video.playbackRate = speed;
  event.preventDefault();
}

function highlightCurrentPlayrate(plyr, menu) {
  let video  = plyr.getElementsByTagName("video")[0];
  let playrateButtons = plyr.getElementsByClassName("playrate-menu--link");
  for (let element of playrateButtons) {
    let speed = parseFloat(element.getAttribute("data-speed"));
    if (video.playbackRate == speed) {
      toggleClass(element, 'playrate-menu--link--selected', true);
      setTimeout(function() {
        element.focus();
      }, 100);
    }
  };
}

function hidePlayrateMenu(menu, button) {
  menu.parentElement.removeChild(menu);
  toggleClass(button, 'playrate-menu--active', false)
}

const INGORED_ELEMENTS = [
  "INPUT", "A", "BUTTON", "TEXTAREA"
]

function addKeyListener(video) {
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
  window.onkeyup = function(e) {
    if (getKeyCode(e) == 9) {
      let playrateButtons = document.getElementsByClassName("plyr_playrate");
      for (let element of playrateButtons) {
        toggleClass(element, 'tab-focus', element == getFocusElement())
      }
    }
  }
}

function toggleClass(element, className, state) {
  if (element) {
    if (element.classList) {
      element.classList[state ? 'add' : 'remove'](className);
    } else {
      var name = (' ' + element.className + ' ').replace(/\s+/g, ' ').replace(' ' + className + ' ', '');
      element.className = name + (state ? ' ' + className : '');
    }
  }
}

function getKeyCode(event) {
  return event.keyCode ? event.keyCode : event.which;
}

function getFocusElement() {
  let focused = document.activeElement;

  if (!focused || focused === document.body) {
    focused = null;
  } else {
    focused = document.querySelector(':focus');
  }

  return focused;
}

export default Player;
