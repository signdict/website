import Vue          from 'vue/dist/vue.common.js'
import VueRouter    from 'vue-router'
import VueResource  from 'vue-resource'
import Vuex         from 'vuex'
import i18n         from 'voo-i18n'
import translations from './i18n/map'

Vue.use(i18n, {translations})
Vue.use(VueRouter)
Vue.use(Vuex)
Vue.use(VueResource)

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

    vue = new Vue({
      el: '#app',
      router,
      store,
      i18n,
      locale: document.documentElement.lang,
      http: {
        root: '/api',
      },
    })
  }
}
