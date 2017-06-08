<template>
  <div class="cutter">
    <video class='cutter--player' loop preload v-bind:data-playing="playing"></video>
    <div class='cutter--navbar'>
      <ul class='cutter--previews'>
        <li class='cutter--previews--item' v-for="image in videoImages">
          <img class='cutter--previews--item--image' v-bind:src="image" />
        </li>
      </ul>
      <div class='cutter--handles'>
        <div class='cutter--handles--left-bar'></div>
        <div class='cutter--handles--right-bar'></div>
        <div class='cutter--handles--left'></div>
        <div class='cutter--handles--right'></div>
        <div class='cutter--handles--position'></div>
      </div>
      <div class="o-grid o-grid--no-gutter cutter--navbar--buttons">
        <div class="o-grid__cell o-grid__cell--width-20">
          <router-link to="/" class="cutter--navbar--back">
            &lt;&lt; {{ $t('Back') }}
          </router-link>
        </div>
        <div class="o-grid__cell o-grid__cell--width-60">
          <div v-if="playing" class="cutter--navbar--pause">
            <i class="fa fa-pause-circle-o" aria-label="Pause" v-on:click="pauseRecording"></i>
          </div>
          <div v-if="!playing" class="cutter--navbar--play">
            <i class="fa fa-play-circle-o" aria-label="Play" v-on:click="playRecording"></i>
          </div>
        </div>
        <div class="o-grid__cell o-grid__cell--width-20">
          <router-link to="/" class="cutter--navbar--next">
            {{ $t('Next') }} &gt;&gt;
          </router-link>
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

let cuttingStart = 0;
let cuttingEnd   = 0;
let currentHandle = null;
let dragging = false;
let framesExtracted = false;

function resetCutterHandles() {
  let height        = getCutterPreviews().clientHeight + "px";
  getCutterElement().style.height  = height;
  getHandleLeft().style.height     = height;
  getHandleRight().style.height    = height;
  getHandleLeftBar().style.height  = height;
  getHandleRightBar().style.height = height;
  getHandlePosition().style.height = height;
  repositionHandles();
}

function timeToPixel(time) {
  let cutter         = getCutterPreviews();
  let rect           = cutter.getBoundingClientRect();
  let computedStyles = window.getComputedStyle(cutter);
  let minPos         = rect.left + parseFloat(computedStyles.paddingLeft);
  let maxPos         = rect.right  - parseFloat(computedStyles.paddingRight);
  let duration       = getVideoElement().duration;

  return minPos + (maxPos - minPos) / duration * time
}

function pixelToTime(clientX) {
  let cutter         = getCutterPreviews();
  let rect           = cutter.getBoundingClientRect();
  let computedStyles = window.getComputedStyle(cutter);
  let minPos         = rect.left + parseFloat(computedStyles.paddingLeft);
  let maxPos         = rect.right  - parseFloat(computedStyles.paddingRight);
  let duration       = getVideoElement().duration;
  let currentPos     = 0;

  if (clientX < minPos) {
    currentPos = 0;
  } else if (clientX > maxPos) {
    currentPos = maxPos - minPos;
  } else {
    currentPos = clientX - minPos;
  }

  return duration / (maxPos - minPos) * currentPos;
  if (time >= video.duration) {
    time = video.duration - 0.01;
  }
  return time;
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

function getHandleLeft() {
  return document.getElementsByClassName("cutter--handles--left")[0];
}

function getHandleRight() {
  return document.getElementsByClassName("cutter--handles--right")[0];
}

function getHandleLeftBar() {
  return document.getElementsByClassName("cutter--handles--left-bar")[0];
}

function getHandleRightBar() {
  return document.getElementsByClassName("cutter--handles--right-bar")[0];
}

function getHandlePosition() {
  return document.getElementsByClassName("cutter--handles--position")[0];
}

function resetVideoplayerHeight() {
  let navbar       = document.getElementsByClassName("cutter--navbar")[0];
  getVideoElement().style.height = window.innerHeight - navbar.clientHeight + "px";
  resetCutterHandles();
}

function updateVideoPosition() {
  if (!dragging) {
    let currentTime = getVideoElement().currentTime;
    if (framesExtracted) {
      if (currentTime + 0.2 < cuttingStart) {
        currentTime = cuttingStart;
        getVideoElement().currentTime = cuttingStart;
      } else if (currentTime > cuttingEnd) {
        currentTime = cuttingEnd;
        getVideoElement().currentTime = cuttingStart;
      }
    }
    getHandlePosition().style.left = timeToPixel(getVideoElement().currentTime) + "px";
  }
  window.requestAnimationFrame(updateVideoPosition);
}

function initVideoPlayer(context, blobs) {
  let videoElement = getVideoElement();
  videoElement.src = window.URL.createObjectURL(new Blob(blobs));
  videoElement.play();
  videoElement.playbackRate = 1000.0
  videoElement.addEventListener('durationchange',function(){
    if (!framesExtracted && Number.isFinite(videoElement.duration) && videoElement.duration > 0) {
      framesExtracted = true;
      window.setTimeout(function() {
        createThumbnails(videoElement, context);
        cuttingEnd = videoElement.duration;
        window.requestAnimationFrame(updateVideoPosition);
      });
    }
  });

  window.onresize = resetVideoplayerHeight;
  resetVideoplayerHeight();
}

function setCursor(element, cursor) {
  if (element != null) {
    element.style.cursor = "move";
    element.style.cursor = cursor;
    element.style.cursor = `-moz-${cursor}`;
    element.style.cursor = `-webkit-${cursor}`;
  }
}

function nearestHandle(left, right, clientX) {
  let leftPos  = parseFloat(window.getComputedStyle(left).left);
  let rightPos = parseFloat(window.getComputedStyle(right).left);

  if (Math.abs(leftPos - clientX) < Math.abs(rightPos - clientX)) {
    return "left";
  } else {
    return "right";
  }
}

function repositionHandles() {
  let startPosition = timeToPixel(cuttingStart);
  let endPosition = timeToPixel(cuttingEnd);

  getHandleLeft().style.left  = startPosition + "px";
  getHandleRight().style.left = endPosition + "px";
  getHandleLeftBar().style.width  = startPosition + "px";
  getHandleRightBar().style.left  = endPosition + "px";
  getHandleRightBar().style.width = window.innerWidth - endPosition + "px";
}

function updateCurrentHandle(clientX) {
  let currentTime = pixelToTime(clientX);
  getVideoElement().currentTime = currentTime;
  if (currentHandle == "left") {
    if (currentTime < cuttingEnd) {
      cuttingStart = currentTime;
    } else {
      cuttingStart = cuttingEnd;
    }
  } else if (currentHandle == "right") {
    if (currentTime > cuttingStart) {
      cuttingEnd = currentTime;
    } else {
      cuttingEnd = cuttingStart;
    }
  }
  repositionHandles();
}

function resetDragging() {
  document.body.style.cursor = "";
  setCursor(getHandleLeft(), "grab");
  setCursor(getHandleRight(), "grab");

  dragging = false;
  if (getVideoElement().dataset.playing == "true") {
    getVideoElement().play();
  }
}

function dragStart(event) {
  event.stopImmediatePropagation();
  dragging = true;

  let handleLeft    = getHandleLeft();
  let handleRight   = getHandleRight();

  setCursor(document.body, "grabbing");
  setCursor(handleLeft, "grabbing");
  setCursor(handleRight, "grabbing");

  currentHandle = nearestHandle(handleLeft, handleRight, event.clientX);

  getVideoElement().pause();
  updateCurrentHandle(event.clientX);
}

function dragMove(event) {
  if (dragging) {
    updateCurrentHandle(event.clientX);
    event.stopImmediatePropagation();
  }
}

function dragEnd(event) {
  resetDragging();
  event.stopImmediatePropagation();
}

function dragCancel(event) {
  resetDragging();
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
      playing: true,
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
    pauseRecording: function() {
      let player = getVideoElement();
      player.pause();
      this.playing = false;
    },
    playRecording: function() {
      let player = getVideoElement();
      player.play();
      this.playing = true;
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
  height: 5em;
}

.cutter--navbar--back {
  padding-left: 1em;
  margin-top: 2em;
  display: inline-block;
}

.cutter--navbar--next {
  padding-right: 1em;
  margin-top: 2em;
  display: inline-block;
  text-align: right;
  width: 100%;
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

.cutter--handles--right-bar,
.cutter--handles--left-bar {
  position: absolute;
  top: 0px;
  height: 3em;
  width: 4px;
  background-color: rgba(100, 100, 100, 0.6);
}

.cutter--handles--left {
  position: absolute;
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
  top: 0px;
  height: 3em;
  width: 4px;
  background-color: #fdd100;
  cursor: move;
  cursor: grab;
  cursor: -moz-grab;
  cursor: -webkit-grab;
}

.cutter--handles--position {
  position: absolute;
  top: 0px;
  height: 3em;
  width: 2px;
  background-color: #e30d25;
}

.cutter--navbar--pause {
  text-align: center;
  font-size: 4em;
  color: #46B472;
}
.cutter--navbar--pause i {
  cursor: pointer;
}

.cutter--navbar--play {
  text-align: center;
  font-size: 4em;
  color: #46B472;
}
.cutter--navbar--play i {
  cursor: pointer;
}

</style>
