<template>
  <div class="recorder">
    <video class="recorder--video recorder--video_flip" autoplay muted></video>
    <div class="recorder--navbar">
      <button v-on:click="startRecording">Start Recording!</button>
      <button v-on:click="stopRecording">Stop Recording!</button>
    </div>
  </div>
</template>

<script>
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
  navigator.mediaDevices.getUserMedia({audio: false, video: true}).
    then(handleSuccess).catch(handleError);
}

function handleStop(event) {
  console.log("this is the router");
  console.log(router);
  console.log('Recorder stopped: ',  event);

  streamHandle.getTracks()[0].stop();
  router.push({path: "/cutter"});
}

function handleDataAvailable(event) {
  console.log("getting data!");
  if (event.data && event.data.size > 0) {
    recordedBlobs.push(event.data);
    store.commit('setRecordedBlobs', recordedBlobs);
  }
}

function startRecording() {
  recordedBlobs = []
  try {
    mediaRecorder = new MediaRecorder(streamHandle, {mimeType: "video/webm"});
  } catch (e) {
    console.error('Exception while creating MediaRecorder: ' + e);
    alert('Exception while creating MediaRecorder: '
      + e + '. mimeType: ' + options.mimeType);
    return;
  }
  mediaRecorder.onstop = handleStop;
  mediaRecorder.ondataavailable = handleDataAvailable;
  mediaRecorder.start(100);
  console.log("Media recording started!");
}

function stopRecording() {
  mediaRecorder.stop();
  console.log("Media recording stopped!");
  console.log(router);
}

export default {
  created: function() {
    console.log("calling method!");
    initRecorder();
    console.log("done!");
    router = this.$router;
    store  = this.$store;
  },

  methods: {
    startRecording: function(event) {
      startRecording();
    },

    stopRecording: function(event) {
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
}

.recorder--video {
  display: block;
  margin-left: auto;
  margin-right: auto;
  object-fit: contain;
  width: 100%;
  height: 100%;
}

.recorder--video_flip {
  -moz-transform: scale(-1, 1) !important;
  -webkit-transform: scale(-1, 1) !important;
  -o-transform: scale(-1, 1) !important;
  transform: scale(-1, 1) !important;
}
</style>
