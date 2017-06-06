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
        <div class='cutter-handles--left'>
        </div>
        <div class='cutter-handles--right'>
        </div>
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

var extractFramePosition = 1;
var extractVideoContext = null;

function drawVideoInCanvas(canvas, context, video) {
  var imageAspectRatio = video.videoWidth / video.videoHeight;
  var canvasAspectRatio = canvas.width / canvas.height;
  var renderableHeight, renderableWidth, xStart, yStart;

  // If image's aspect ratio is less than canvas's we fit on height
  // and place the image centrally along width
  if(imageAspectRatio < canvasAspectRatio) {
    renderableHeight = canvas.height;
    renderableWidth = video.videoWidth * (renderableHeight / video.videoHeight);
    xStart = (canvas.width - renderableWidth) / 2;
    yStart = 0;
  }

  // If image's aspect ratio is greater than canvas's we fit on width
  // and place the image centrally along height
  else if(imageAspectRatio > canvasAspectRatio) {
    renderableWidth = canvas.width
    renderableHeight = video.videoHeight * (renderableWidth / video.videoWidth);
    xStart = 0;
    yStart = (canvas.height - renderableHeight) / 2;
  }

   //Happy path - keep aspect ratio
  else {
    renderableHeight = canvas.height;
    renderableWidth = canvas.width;
    xStart = 0;
    yStart = 0;
  }
  context.drawImage(video, xStart, yStart, renderableWidth, renderableHeight);
}

function extractFrame(video) {
  let canvas = document.createElement('canvas');
  let ctx    = canvas.getContext('2d');
  canvas.width = 320;
  canvas.height = 240;
  ctx.fillStyle="#000000";
  ctx.fillRect(0, 0, 320, 240);
  drawVideoInCanvas(canvas, ctx, video);

  let dataURI = canvas.toDataURL('image/jpeg');
  let image = document.createElement("img");
  extractVideoContext.videoImages.push(dataURI);
}

function jumpToNextPosition(video) {
  extractFramePosition += 1;
  let seekDistance = video.duration / 10.0;
  let jumpTo = extractFramePosition * seekDistance;
  if (jumpTo < video.duration) {
    video.currentTime = jumpTo;
  } else {
    video.currentTime = video.duration - 0.1;
  }
}

function seekForThumbnail(event){
  let video  = event.target;
  extractFrame(video);
  if (extractFramePosition < 10) {
    jumpToNextPosition(video);
  } else {
    video.removeEventListener("seeked", seekForThumbnail);
    video.playbackRate = 1
    video.play();
  }
}

function createThumbnails(video, context) {
  extractVideoContext = context;
  context.videoImages = []
  video.pause();
  video.addEventListener("seeked", seekForThumbnail);
  extractFramePosition = 0;
  jumpToNextPosition(video);
}

function resetVideoplayerHeight() {
  let videoElement = document.getElementsByClassName("cutter--player")[0];
  let navbar       = document.getElementsByClassName("cutter--navbar")[0];
  videoElement.style.height = window.innerHeight - navbar.clientHeight + "px";
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
      let superBuffer = new Blob(this.$store.state.recordedBlobs);
      let videoElement = document.getElementsByClassName("cutter--player")[0];
      let context = this;
      videoElement.src = window.URL.createObjectURL(superBuffer);
      videoElement.play();
      videoElement.playbackRate = 1000.0
      videoElement.addEventListener('durationchange',function(){
        if (!context.framesExtracted && Number.isFinite(videoElement.duration) && videoElement.duration > 0) {
          console.log("extracting frames!");
          context.framesExtracted = true;
          window.setTimeout(function() {
            createThumbnails(videoElement, context);
          });
        }
      });

      window.onresize = resetVideoplayerHeight;
      resetVideoplayerHeight();
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
}

.cutter--previews--item {
  display: inline;
  vertical-align: top;
}

.cutter--previews--item--image {
  width: 10%;
}

</style>
