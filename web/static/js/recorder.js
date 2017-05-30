import Vue       from 'vue/dist/vue.common.js'
import VueRouter from 'vue-router'
import Recorder  from "./components/recorder.vue"
import Cutter    from "./components/cutter.vue"

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    const routes = [
      { path: '/', component: Recorder },
      { path: '/cutter', component: Cutter }
    ]

    const router = new VueRouter({
      routes
    })

    Vue.use(VueRouter)

    new Vue({
      el: '#app',
      router
    })
  }
}
