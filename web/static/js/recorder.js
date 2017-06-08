import Vue          from 'vue/dist/vue.common.js'
import VueRouter    from 'vue-router'
import Vuex         from 'vuex'
import i18n         from 'voo-i18n'
import translations from './i18n/map'

Vue.use(i18n, translations)
Vue.use(VueRouter)
Vue.use(Vuex)

import Recorder  from "./components/recorder.vue"
import Cutter    from "./components/cutter.vue"
import Upload    from "./components/upload.vue"
import store     from "./components/store.js"

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    const routes = [
      { path: '/', component: Recorder },
      { path: '/cutter', component: Cutter },
      { path: '/upload', component: Upload }
    ]

    const router = new VueRouter({
      routes
    })

    new Vue({
      el: '#app',
      router,
      store,
      i18n,
      data() {
        return {
          locale: document.documentElement.lang
        }
      },
    })
  }
}
