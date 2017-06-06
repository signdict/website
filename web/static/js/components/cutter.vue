<template>
  <div class="cutter">
    <video class='cutter--player' loop></video>
    <div class='cutter--navbar'>
      <ul class='cutter--previews'>
        <li class='cutter--previews--item' v-for="image in videoImages">
          <img class='cutter--previews--item--image' v-bind:src="image" />
        </li>
      </ul>
      <div class='cutter--handles'>
        <div class='cutter--handles--left'></div>
        <div class='cutter--handles--right'></div>
      </div>
      <div class="o-grid o-grid--no-gutter cutter--navbar--buttons">
        <div class="o-grid__cell o-grid__cell--width-20">
          <router-link to="/" class="cutter--navbar--back">
            &lt;&lt; {{ $t('Back') }}
          </router-link>
        </div>
        <div class="o-grid__cell o-grid__cell--width-60">
        </div>
        <div class="o-grid__cell o-grid__cell--width-20">
          <button v-on:click="download">download</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import FrameExtractor from "./frame_extractor.js";
function createThumbnails(video, context) {
  new FrameExtractor(video, context.videoImages).extractFrames(function() {
    resetVideoplayerHeight();
  });
}

function updateCutterHandles() {
  let videoPreviews = document.getElementsByClassName("cutter--previews")[0];
  let handles       = document.getElementsByClassName("cutter--handles")[0];
  let handleLeft    = document.getElementsByClassName("cutter--handles--left")[0];
  let handleRight   = document.getElementsByClassName("cutter--handles--right")[0];
  console.log(handles);
  console.log(handleLeft);
  console.log(handleRight);
  handles.style.height = videoPreviews.clientHeight + "px";
  handleLeft.style.height = videoPreviews.clientHeight + "px";
  handleRight.style.height = videoPreviews.clientHeight + "px";
}

function getVideoElement() {
  return document.getElementsByClassName("cutter--player")[0];
}

function getCutterElement() {
  return document.getElementsByClassName("cutter--handles")[0];
}

function getCutterPreviews() {
  return document.getElementsByClassName("cutter--previews")[0];
}

function resetVideoplayerHeight() {
  let navbar       = document.getElementsByClassName("cutter--navbar")[0];
  getVideoElement().style.height = window.innerHeight - navbar.clientHeight + "px";
  updateCutterHandles();
}

function initVideoPlayer(context, blobs) {
  let videoElement = getVideoElement();
  videoElement.src = window.URL.createObjectURL(new Blob(blobs));
  videoElement.play();
  videoElement.playbackRate = 1000.0
  videoElement.addEventListener('durationchange',function(){
    if (!context.framesExtracted && Number.isFinite(videoElement.duration) && videoElement.duration > 0) {
      context.framesExtracted = true;
      window.setTimeout(function() {
        createThumbnails(videoElement, context);
      });
    }
  });

  window.onresize = resetVideoplayerHeight;
  resetVideoplayerHeight();
}

let dragging = false;

function dragStart(event) {
  dragging = true;
  console.log("drag start");
  console.log(event);
  event.stopImmediatePropagation();

  getVideoElement().pause();
  dragMove(event);

  document.body.style.cursor = "move";
  document.body.style.cursor = "grabbing";
  document.body.style.cursor = "-moz-grabbing";
  document.body.style.cursor = "-webkit-grabbing";
}

function dragMove(event) {
  if (dragging) {
    let cutter         = getCutterPreviews();
    let rect           = cutter.getBoundingClientRect();
    let computedStyles = window.getComputedStyle(cutter);
    let minPos         = rect.left + parseFloat(computedStyles.paddingLeft);
    let maxPos         = rect.right  - parseFloat(computedStyles.paddingRight);
    let currentPos     = 0;

    if (event.clientX < minPos) {
      currentPos = 0;
    } else if (event.clientX > maxPos) {
      currentPos = maxPos - minPos;
    } else {
      currentPos = event.clientX - minPos;
    }

    let percent = currentPos / ((maxPos - minPos) / 100.0)
    let video = getVideoElement();
    let jumpTo = video.duration / 100 * percent;
    video.currentTime = jumpTo;

    event.stopImmediatePropagation();
  }
}

function dragEnd(event) {
  dragging = false;
  document.body.style.cursor = "";
  console.log("drag end");
  console.log(event);
  event.stopImmediatePropagation();
  getVideoElement().play();
}

function dragCancel(event) {
  console.log("drag cancel");
  console.log(event);
  event.stopImmediatePropagation();
}

function initCutter() {
  let cutter = getCutterElement();
  cutter.addEventListener("mousedown", dragStart);
  window.addEventListener("mousemove", dragMove);
  window.addEventListener("mouseup", dragEnd);
}

export default {
  data () {
    return {
      framesExtracted: false,
      videoImages: []
    }
  },
  mounted () {
    let blobs = this.$store.state.recordedBlobs;
    if (blobs.length == 0) {
      this.$router.replace("/");
    } else {
      initVideoPlayer(this, blobs);
      initCutter();
    }
  },
  methods: {
    download: function() {
      let blob = new Blob(this.$store.state.recordedBlobs, {
        type: 'video/webm'
      });
      let url = URL.createObjectURL(blob);
      let a = document.createElement('a');
      document.body.appendChild(a);
      a.style = 'display: none';
      a.href = url;
      a.download = 'test.webm';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  }
}
</script>

<style lang="sass">

.cutter {
  width: 100%;
  height: 100%;
  padding-bottom: 13em;
  background-color: #000;
  overflow: hidden;
  position: relative;
}

.cutter--player {
  display: block;
  margin-left: auto;
  margin-right: auto;
  object-fit: contain;
  width: 100%;
  height: 100%;
}

.cutter--navbar {
  border-top: 1px solid #222;
  background-color: #333;
  position: absolute;
  bottom: 0px;
  width: 100%;
}

.cutter--navbar--buttons {
  height: 3em;
  margin-top: 1.5em;
}

.cutter--navbar--back {
  margin-left: 1em;
  margin-top: 2em;
}

.cutter--previews {
  background-color: #000;
  list-style: none;
  width: 100%;
  vertical-align: top;
  margin: 0px auto;
  padding: 0px 2%;
  -moz-user-select: none;
  -ms-user-select: none;
  -webkit-user-select: none;
  user-select: none;
}

.cutter--previews--item {
  display: inline;
  vertical-align: top;
}

.cutter--previews--item--image {
  width: 10%;
}

.cutter--handles {
  position: absolute;
  left: 0px;
  top: 0px;
  height: 3em;
  width: 100%;
}

.cutter--handles--left {
  position: absolute;
  left: 100px;
  top: 0px;
  height: 3em;
  width: 4px;
  background-color: #fdd100;
  cursor: move;
  cursor: grab;
  cursor: -moz-grab;
  cursor: -webkit-grab;
}

.cutter--handles--right {
  position: absolute;
  right: 100px;
  top: 0px;
  height: 3em;
  width: 4px;
  background-color: #fdd100;
  cursor: move;
  cursor: grab;
  cursor: -moz-grab;
  cursor: -webkit-grab;
}


</style>
