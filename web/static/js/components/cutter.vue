<template>
  <div class="cutter">
    <video class='cutter-player' loop></video>
    <p>
      <button v-on:click="download">download</button>
      <router-link to="/">Back to recording</router-link>
    </p>

    <ul>
      <li v-for="image in videoImages">
        <img v-bind:src="image" />
      </li>
    </ul>
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

  // Happy path - keep aspect ratio
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
  if (extractFramePosition <= 10) {
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

export default {
  data () {
    return {
      framesExtracted: false,
      videoImages: []
    }
  },
  mounted () {
    let superBuffer = new Blob(this.$store.state.recordedBlobs);
    let videoElement = document.getElementsByClassName("cutter-player")[0];
    let context = this;
    videoElement.src =
      window.URL.createObjectURL(superBuffer);
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
</style>
