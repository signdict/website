<template>
  <div class="upload">
    Hello
    <router-link to="/cutter" class="cutter--navbar--next">
      {{ $t('Back') }}
    </router-link>
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
    console.log(this.$store.state.startTime);
    console.log(this.$store.state.endTime);
  },
  methods: {
  }
}
</script>

<style lang="sass">
</style>
