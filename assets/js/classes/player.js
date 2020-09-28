import Plyr from 'plyr';
import translate from './translate';

class Player {
  playerInstance = null;
  videoElement = null;

  constructor() {
    document.addEventListener('turbolinks:load', () => {
      const videos = document.getElementsByTagName('video');
      if (videos.length > 0) {
        this.playerInstance = addPlyr(videos[0]);
        this.videoElement = videos[0];
        this.addKeyListener(videos[0]);
      }
    });
    document.addEventListener('turbolinks:before-visit', () => {
      this.playerInstance && this.playerInstance.destroy();
      this.removeKeyListener();
    });
  }

  addKeyListener() {
    document.addEventListener('keydown', this.playPause);
    document.addEventListener('keyup', this.tabPlayrate);
  }

  removeKeyListener() {
    document.removeEventListener('keydown', this.playPause);
    document.removeEventListener('keyup', this.tabPlayrate);
  }

  playPause = (e) => {
    if (e.key == ' ' && INGORED_ELEMENTS.indexOf(e.target.nodeName) == -1) {
      if (this.videoElement.paused) {
        this.videoElement.play();
      } else {
        this.videoElement.pause();
      }
      e.preventDefault();
    }
  };

  tabPlayrate = (e) => {
    if (getKeyCode(e) == 9) {
      let playrateButtons = document.getElementsByClassName('plyr_playrate');
      for (let element of playrateButtons) {
        toggleClass(element, 'tab-focus', element == getFocusElement());
      }
    }
  };
}

function addPlyr(video) {
  const controls = `
  <div class="plyr__controls">
    <button type="button" class="plyr__control" aria-label="Play, {title}" data-plyr="play">
        <svg class="icon--pressed" role="presentation"><use xlink:href="#plyr-pause"></use></svg>
        <svg class="icon--not-pressed" role="presentation"><use xlink:href="#plyr-play"></use></svg>
        <span class="label--pressed plyr__tooltip" role="tooltip">Pause</span>
        <span class="label--not-pressed plyr__tooltip" role="tooltip">Play</span>
    </button>
    <div class="plyr__progress">
        <input data-plyr="seek" type="range" min="0" max="100" step="0.01" value="0" aria-label="Seek">
        <progress class="plyr__progress__buffer" min="0" max="100" value="0">% buffered</progress>
        <span role="tooltip" class="plyr__tooltip">00:00</span>
    </div>
    <div class="plyr__time plyr__time--current" aria-label="Current time">00:00</div>

    <button class='plyr_playrate plyr__control' type='button' data-plyr='playrate'>
      <i style='font-size: 1.6em' class='fa fa-tachometer' aria-hidden='true'></i>
      <span class='plyr__sr-only'>${translate('Change playback rate')}</span>
    </button>
  
    <button type="button" class="plyr__control" data-plyr="fullscreen">
        <svg class="icon--pressed" role="presentation"><use xlink:href="#plyr-exit-fullscreen"></use></svg>
        <svg class="icon--not-pressed" role="presentation"><use xlink:href="#plyr-enter-fullscreen"></use></svg>
        <span class="label--pressed plyr__tooltip" role="tooltip">Exit fullscreen</span>
        <span class="label--not-pressed plyr__tooltip" role="tooltip">Enter fullscreen</span>
    </button>
  </div>`;

  const player = new Plyr(video, {
    controls,
    muted: true,
  });
  let playrateButtons = document.getElementsByClassName('plyr_playrate');
  for (let element of playrateButtons) {
    element.onclick = togglePlayrateMenu;
  }
  return player;
}

function togglePlayrateMenu(event) {
  let plyr = event.target.closest('.plyr');
  let menu = plyr.getElementsByClassName('playrate-menu');
  let button = event.target.closest('button');
  if (menu.length == 0) {
    showPlayrateMenu(plyr, button);
  } else {
    hidePlayrateMenu(menu[0], button);
  }
}

function showPlayrateMenu(plyr, button) {
  let menu = document.createElement('div');
  menu.setAttribute('class', 'playrate-menu plyr__tooltip plyr__tooltip--visible');
  menu.innerHTML =
    "<ul class='playrate-menu--list'>" +
    "<li><a class='playrate-menu--link' href='#' data-speed='0.25'>0.25x</a></li>" +
    "<li><a class='playrate-menu--link' href='#' data-speed='0.5'>0.50x</a></li>" +
    "<li><a class='playrate-menu--link' href='#' data-speed='0.75'>0.75x</a></li>" +
    "<li><a class='playrate-menu--link' href='#' data-speed='1'>1.00x</a></li>" +
    '</ul>';
  plyr.appendChild(menu);
  let plyrPosition = plyr.getBoundingClientRect().left;
  let position = button.getBoundingClientRect().left - plyrPosition + button.clientWidth / 2;
  menu.setAttribute('style', `left: ${position}px`);
  toggleClass(button, 'playrate-menu--active', true);
  linkPlayrateSpeedButton(plyr);
  highlightCurrentPlayrate(plyr, menu);
}

function linkPlayrateSpeedButton(plyr) {
  let playrateButtons = plyr.getElementsByClassName('playrate-menu--link');
  for (let element of playrateButtons) {
    element.onclick = function (event) {
      updatePlaybackRate(plyr, event);
    };
    element.onkeyup = function (event) {
      if (getKeyCode(event) == 13) {
        updatePlaybackRate(plyr, event);
      }
    };
  }
}

function updatePlaybackRate(plyr, event) {
  let video = plyr.getElementsByTagName('video')[0];
  let menu = plyr.getElementsByClassName('playrate-menu')[0];
  let button = plyr.getElementsByClassName('plyr_playrate')[0];
  let speed = parseFloat(event.target.getAttribute('data-speed'));
  hidePlayrateMenu(menu, button);
  video.playbackRate = speed;
  event.preventDefault();
}

function highlightCurrentPlayrate(plyr, menu) {
  let video = plyr.getElementsByTagName('video')[0];
  let playrateButtons = plyr.getElementsByClassName('playrate-menu--link');
  for (let element of playrateButtons) {
    let speed = parseFloat(element.getAttribute('data-speed'));
    if (video.playbackRate == speed) {
      toggleClass(element, 'playrate-menu--link--selected', true);
      setTimeout(function () {
        element.focus();
      }, 100);
    }
  }
}

function hidePlayrateMenu(menu, button) {
  menu.parentElement.removeChild(menu);
  toggleClass(button, 'playrate-menu--active', false);
}

const INGORED_ELEMENTS = ['INPUT', 'A', 'BUTTON', 'TEXTAREA'];

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
