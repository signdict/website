<template>
  <div class="upload">
    Hello
  </div>
</template>

<script>
export default {
  data() {
    return {
    }
  },
  mounted() {
    console.log("mounted!!");
    console.log(this.$store.startTime);
    console.log(this.$store.endTime);
  },
  methods: {
  }
}
</script>

<style lang="sass">
</style>
