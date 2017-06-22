<template>
  <div class="recorder">
    <video class="recorder--video recorder--video_flip" autoplay muted></video>
    <div v-if="!recording" class="recorder--countdown">
      <div class="recorder--countdown--number">
        {{ countdown }}
      </div>
    </div>
    <div v-if="recording" class="recorder--rec">
      REC
    </div>
    <div class="recorder--navbar">
      <div class="o-grid o-grid--no-gutter">
        <div class="o-grid__cell o-grid__cell--width-20">
          <div class="recorder--navbar--back">
            <a href='/recorder'>
              &lt;&lt; {{ $t('Back') }}
            </a>
          </div>
        </div>
        <div class="o-grid__cell o-grid__cell--width-60">
          <div v-if="recording" class="recorder--navbar--stop">
            <i class="fa fa-stop-circle-o" aria-label="Stop" v-on:click="stopRecording"></i>
          </div>
        </div>
        <div class="o-grid__cell o-grid__cell--width-20">
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import browser from 'detect-browser';

var streamHandle;
var mediaRecorder;
var recordedBlobs;
var router;
var store;

function handleSuccess(stream) {
  var previewVideo = document.getElementsByClassName("recorder--video")[0];
  streamHandle = stream;
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
  let constraints = {audio: true, video: true};

  if (browser.name == "firefox") {
    constraints = {
      video: {
        height: { min: 240, ideal: 720, max: 720 },
        width: { min: 320, ideal: 1280, max: 1280 },
      },
      audio: false
    };
  } else if (browser.name == "chrome") {
    constraints = {
      video: {
        mandatory: {
          maxHeight: 720,
          maxWidth: 1280
        },
        optional: [
          {minWidth: 320},
          {minWidth: 640},
          {minWidth: 960},
          {minWidth: 1024},
          {minWidth: 1280}
        ]
      },
      audio: false
    }
  }

  navigator.mediaDevices.getUserMedia(constraints).
    then(handleSuccess).catch(handleError);
}

function handleStop(event) {
  streamHandle.getTracks()[0].stop();
  store.commit('setRecordedBlobs', recordedBlobs);
  router.push({path: "/cutter"});
}

function handleDataAvailable(event) {
  if (event.data && event.data.size > 0) {
    recordedBlobs.push(event.data);
  }
}

function detectCodec() {
  return ['video/webm;codecs=vp9',
    'video/webm;codecs=vp8',
    'video/webm'].find(function(codec) {
      return MediaRecorder.isTypeSupported(codec);
    });
}

function startRecording(context) {
  context.recording = true;
  context.recordingStartedAt = new Date();
  recordedBlobs = []
  try {
    mediaRecorder = new MediaRecorder(streamHandle, {mimeType: detectCodec()});
  } catch (e) {
    console.error('Exception while creating MediaRecorder: ' + e);
    alert('Exception while creating MediaRecorder: '
      + e + '. mimeType: ' + options.mimeType);
    return;
  }
  mediaRecorder.onstop = handleStop;
  mediaRecorder.ondataavailable = handleDataAvailable;
  mediaRecorder.start(50);
}

function stopRecording() {
  mediaRecorder.stop();
}

function startCountdown(context) {
  setTimeout(function() {
    context.countdown -= 1;
    if (context.countdown > 0) {
      startCountdown(context);
    } else {
      startRecording(context);
    }
  }, 1000);
}

export default {
  data() {
    return {
      countdown: 5,
      recording: false,
      recordingStartedAt: 0
    }
  },
  mounted() {
    initRecorder();
    router = this.$router;
    store  = this.$store;
    startCountdown(this);
  },

  methods: {
    startRecording: function(event) {
      startRecording();
    },

    stopRecording: function(event) {
      this.recording = false;
      let duration = (new Date() - this.recordingStartedAt) / 1000;
      this.$store.commit('setRecordedDuration', duration);
      this.$store.commit('setEndTime', duration);
      this.$store.commit('setStartTime', 0);
      stopRecording();
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

.recorder {
  width: 100%;
  height: 100%;
  padding-bottom: 5em;
  background-color: #000;
  overflow: hidden;
  position: relative;
}

.recorder--video {
  display: block;
  margin-left: auto;
  margin-right: auto;
  object-fit: contain;
  width: 100%;
  height: 100%;
}

.recorder--countdown {
  position: absolute;
  top: 50%;
  transform: translate(0, -50%);
  width: 100%;
  opacity: 0.8;
}

.recorder--countdown--number {
  border-radius: 50%;
  font-size: 6em;

  width: 2em;
  height: 2em;
  padding: 0.4em;

  background: #666;
  border: 2px solid #666;
  color: #fff;
  text-align: center;

  margin-left: auto;
  margin-right: auto;
}

.recorder--rec {
  position: absolute;
  top: 1em;
  right: 3em;
  color: #fff;
  font-weight: 800;
  text-shadow: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
}
.recorder--rec:before {
  animation: blinker 1s linear infinite;
  position: absolute;
  margin-left: -1.3em;
  margin-top: 0.05em;
  content: '';
  background-color:#FF0000;
  border-radius:50%;
  opacity:0.8;
  width: 1em;
  height: 1em;
  pointer-events: none;
}
@keyframes blinker {
  50% { opacity: 0; }
}

.recorder--navbar {
  border-top: 1px solid #222;
  background-color: #333;
  height: 5em;
  position: relative;
}

.recorder--navbar--back {
  margin-left: 1em;
  margin-top: 2em;
}

.recorder--navbar--stop {
  text-align: center;
  font-size: 4em;
  color: #e30d25;
}

.recorder--navbar--stop i {
  cursor: pointer;
}

.recorder--video_flip {
  -moz-transform: scale(-1, 1) !important;
  -webkit-transform: scale(-1, 1) !important;
  -o-transform: scale(-1, 1) !important;
  transform: scale(-1, 1) !important;
}
</style>
