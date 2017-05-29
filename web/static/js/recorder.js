import Vue from 'vue'
import Recorder from "./components/recorder.vue"

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    Vue.component('recorder', Recorder)

    new Vue({
      el: '#app',
      data() {
        return {
        }
      },
      render: function (createElement) {
        return createElement(Recorder, {})
      }
    });
  }
}
