<template>
  <div class="cutter">
    Here we cut!
    <router-link to="/">Back to recording</router-link>
  </div>
</template>

<script>
export default {
  created: function() {
    console.log("created cutter");
  },
}
</script>

<style lang="sass">
</style>
