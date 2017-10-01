class FrameExtractor {
  constructor(videoElement, duration, targetArray) {
    let self = this;
    this.targetArray  = targetArray;
    this.videoElement = videoElement;
    this.duration = duration;
    this.seekEvent = function(event) {
      seekForThumbnail(self, event);
    }
    this.videoElement.addEventListener("seeked", this.seekEvent);
  }

  extractFrames(callback) {
    this.targetArray.length = 0;
    this.extractFramePosition = 0;
    this.videoElement.pause();
    this.callback     = callback;
    jumpToNextPosition(this);
  }
}

function drawVideoInCanvas(props, canvas, context) {
  let video = props.videoElement;
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

function extractFrame(props) {
  let canvas = document.createElement('canvas');
  let ctx    = canvas.getContext('2d');
  canvas.width  = 320;
  canvas.height = 240;
  ctx.fillStyle = "#000000";
  ctx.fillRect(0, 0, 320, 240);
  drawVideoInCanvas(props, canvas, ctx);

  let dataURI = canvas.toDataURL('image/jpeg');
  let image = document.createElement("img");
  props.targetArray.push(dataURI);
}

function jumpToNextPosition(props) {
  props.extractFramePosition += 1;
  let seekDistance = props.duration / 10.0;
  let jumpTo = props.extractFramePosition * seekDistance;
  if (jumpTo < props.duration) {
    props.videoElement.currentTime = jumpTo;
  } else {
    props.videoElement.currentTime = props.duration - 0.1;
  }
}

function seekForThumbnail(props, event){
  extractFrame(props);
  if (props.extractFramePosition < 10) {
    jumpToNextPosition(props);
  } else {
    props.videoElement.removeEventListener("seeked", props.seekEvent);
    props.videoElement.play();
    props.callback();
  }
}

export default FrameExtractor;
