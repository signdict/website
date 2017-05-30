<template>
  <div class="cutter">
    Here we cut!
    <video class='cutter-player' loop></video>
    <button v-on:click="download">download</button>
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
  methods: {
    download: function() {
      var blob = new Blob(this.$store.state.recordedBlobs, {
        type: 'video/webm'
      });
      var url = URL.createObjectURL(blob);
      var a = document.createElement('a');
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
