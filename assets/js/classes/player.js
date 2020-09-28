import Plyr from 'plyr';
import translate from './translate';

const INGORED_ELEMENTS = ['INPUT', 'A', 'BUTTON', 'TEXTAREA'];

class Player {
  playerInstance = null;
  videoElement = null;
  manualLoopCounter = 0;
  playPressed = false;

  constructor() {
    document.addEventListener('turbolinks:load', () => {
      const videos = document.getElementsByTagName('video');
      if (videos.length > 0) {
        this.addPlyr(videos[0]);
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
    if (this.getKeyCode(e) == 9) {
      let playrateButtons = document.getElementsByClassName('plyr_playrate');
      for (let element of playrateButtons) {
        this.toggleClass(element, 'tab-focus', element == this.getFocusElement());
      }
    }
  };

  addPlyr = (video) => {
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

    this.playerInstance = new Plyr(video, {
      controls,
      muted: true,
    });
    let playrateButtons = document.getElementsByClassName('plyr_playrate');
    for (let element of playrateButtons) {
      element.onclick = this.togglePlayrateMenu;
    }

    if (video.getAttribute('data-plyr-manual-loop') == 'true') {
      this.initManualLoop();
    }
  };

  togglePlayrateMenu = (event) => {
    let plyr = event.target.closest('.plyr');
    let menu = plyr.getElementsByClassName('playrate-menu');
    let button = event.target.closest('button');
    if (menu.length == 0) {
      this.showPlayrateMenu(plyr, button);
    } else {
      this.hidePlayrateMenu(menu[0], button);
    }
  };

  showPlayrateMenu = (plyr, button) => {
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
    this.toggleClass(button, 'playrate-menu--active', true);
    this.linkPlayrateSpeedButton(plyr);
    this.highlightCurrentPlayrate(plyr, menu);
  };

  linkPlayrateSpeedButton = (plyr) => {
    let playrateButtons = plyr.getElementsByClassName('playrate-menu--link');
    for (let element of playrateButtons) {
      element.onclick = (event) => {
        this.updatePlaybackRate(plyr, event);
      };
      element.onkeyup = (event) => {
        if (this.getKeyCode(event) == 13) {
          this.updatePlaybackRate(plyr, event);
        }
      };
    }
  };

  updatePlaybackRate = (plyr, event) => {
    let video = plyr.getElementsByTagName('video')[0];
    let menu = plyr.getElementsByClassName('playrate-menu')[0];
    let button = plyr.getElementsByClassName('plyr_playrate')[0];
    let speed = parseFloat(event.target.getAttribute('data-speed'));
    this.hidePlayrateMenu(menu, button);
    video.playbackRate = speed;
    event.preventDefault();
  };

  highlightCurrentPlayrate = (plyr, menu) => {
    let video = plyr.getElementsByTagName('video')[0];
    let playrateButtons = plyr.getElementsByClassName('playrate-menu--link');
    for (let element of playrateButtons) {
      let speed = parseFloat(element.getAttribute('data-speed'));
      if (video.playbackRate == speed) {
        this.toggleClass(element, 'playrate-menu--link--selected', true);
        setTimeout(() => {
          element.focus();
        }, 100);
      }
    }
  };

  hidePlayrateMenu = (menu, button) => {
    menu.parentElement.removeChild(menu);
    this.toggleClass(button, 'playrate-menu--active', false);
  };

  toggleClass = (element, className, state) => {
    if (element) {
      if (element.classList) {
        element.classList[state ? 'add' : 'remove'](className);
      } else {
        var name = (' ' + element.className + ' ').replace(/\s+/g, ' ').replace(' ' + className + ' ', '');
        element.className = name + (state ? ' ' + className : '');
      }
    }
  };

  getKeyCode = (event) => {
    return event.keyCode ? event.keyCode : event.which;
  };

  getFocusElement = () => {
    let focused = document.activeElement;

    if (!focused || focused === document.body) {
      focused = null;
    } else {
      focused = document.querySelector(':focus');
    }

    return focused;
  };

  initManualLoop = () => {
    this.manualLoopCounter = 0;
    this.playerInstance.on('ended', () => {
      this.manualLoopCounter += 1;
      if (this.manualLoopCounter < 3) {
        this.playPressed = false;
        this.playerInstance.play();
      }
    });
    this.playerInstance.on('play', () => {
      if (this.playPressed) {
        this.playerInstance.loop = true;
      }
      this.playPressed = true;
    });
  };
}

export default Player;
