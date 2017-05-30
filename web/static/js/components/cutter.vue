<template>
  <div class="cutter">
    Here we cut!
    <video class='cutter-player' loop></video>
    <router-link to="/">Back to recording</router-link>
  </div>
</template>

<script>

export default {
  mounted: function() {
    console.log("created cutter");
    var superBuffer = new Blob(this.$store.state.recordedBlobs);
    let videoElement = document.getElementsByClassName("cutter-player")[0];
    console.log(videoElement);
    videoElement.src =
      window.URL.createObjectURL(superBuffer);
    videoElement.play();
  },
}
</script>

<style lang="sass">
</style>
