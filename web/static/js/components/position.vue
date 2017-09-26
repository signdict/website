<template>
  <div class="position">
    <img class="position--body" src="/images/body.svg" alt="the optimal body position">
    <video class="position--video position--video_flip" autoplay muted></video>

    <div class="o-modal u-higher position--modal" v-if="explainModal">
      <div class="c-card">
        <header class="c-card__header">
          <button type="button" class="c-button c-button--close" v-on:click="closeModal">×</button>
          <h2 class="c-heading">{{ $t('Check your position') }}</h2>
        </header>
        <div class="c-card__body">
          {{ $t('Please make sure that you are as close to the body outline as possible. If you think everything looks perfect, click on the "Start recording" on the lower right.') }}
        </div>
        <footer class="c-card__footer">
          <button type="button" class="c-button c-button--brand" v-on:click="closeModal">{{ $t('Okay') }}</button>
        </footer>
      </div>
    </div>
    <div class="position--navbar">
      <div class="o-grid o-grid--no-gutter">
        <div class="o-grid__cell o-grid__cell--width-20">
          <div class="position--navbar--back">
            <a :href="'/recorder/' + entryId">
              &lt;&lt; {{ $t('Back') }}
            </a>
          </div>
        </div>
        <div class="o-grid__cell o-grid__cell--width-60">
        </div>
        <div class="o-grid__cell o-grid__cell--width-20">
          <router-link to="/recorder" class="cutter--navbar--next">
            {{ $t('Start recording') }} &gt;&gt;
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import browser from 'detect-browser';
import { getMediaConstraint } from './media_device.js';

function handleSuccess(stream) {
  var previewVideo = document.getElementsByClassName("position--video")[0];
  if (window.URL) {
    previewVideo.src = window.URL.createObjectURL(stream);
  } else {
    previewVideo.src = stream;
  }
}

function handleError(error) {
  console.log("nope, not working!");
  console.log(error);
}

function initRecorder() {
  navigator.mediaDevices.getUserMedia(getMediaConstraint()).
    then(handleSuccess).catch(handleError);
}

function checkBrowser() {
  if (browser.name == "chrome" && parseInt(browser.version) >= 59 ||
    browser.name == "firefox" && parseInt(browser.version) >= 55) {
    return true;
  } else {
    return false;
  }
}

export default {
  data() {
    return {
      countdown: 5,
      recording: false,
      recordingStartedAt: 0,
      entryId: 0,
      explainModal: true,
    }
  },
  mounted() {
    this.entryId = document.getElementById("app").getAttribute("data-entry-id");
    if (checkBrowser()) {
      initRecorder();
    } else {
      window.location = "/notsupported"
    }
  },
  methods: {
    closeModal: function() {
      this.explainModal = false;
    }
  }
}
</script>

<style lang="sass">
html, body {
  height: 100%;
}

#app {
  height: 100%;
}

.position {
  width: 100%;
  height: 100%;
  padding-bottom: 5em;
  background-color: #000;
  overflow: hidden;
  position: relative;
}

.position--modal {
  max-width: 30em;
}

.position--video {
  display: block;
  margin-left: auto;
  margin-right: auto;
  object-fit: contain;
  width: 100%;
  height: 100%;
}

.position--navbar {
  border-top: 1px solid #222;
  background-color: #333;
  height: 5em;
  position: relative;
}

.position--navbar--back {
  margin-left: 1em;
  margin-top: 2em;
}

.position--video_flip {
  -moz-transform: scale(-1, 1) !important;
  -webkit-transform: scale(-1, 1) !important;
  -o-transform: scale(-1, 1) !important;
  transform: scale(-1, 1) !important;
}

.position--body {
  display: block;
  position: absolute;
  height: 100%;
  margin-left: auto;
  margin-right: auto;
  z-index: 2;
  padding-bottom: 5em;
  padding-top: 1em;
  text-align: center;
  left: 0;
  right: 0;
}
</style>
