import Vue       from 'vue/dist/vue.common.js'
import VueRouter from 'vue-router'
import Vuex      from 'vuex'

Vue.use(VueRouter)
Vue.use(Vuex)

import Recorder  from "./components/recorder.vue"
import Cutter    from "./components/cutter.vue"
import store     from "./components/store.js"

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    const routes = [
      { path: '/', component: Recorder },
      { path: '/cutter', component: Cutter }
    ]

    const router = new VueRouter({
      routes
    })

    new Vue({
      el: '#app',
      router,
      store
    })
  }
}
