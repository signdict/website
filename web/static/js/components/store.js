import Vue       from 'vue/dist/vue.common.js'
import Vuex      from 'vuex'
Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    recordedBlobs: []
  },
  mutations: {
    setRecordedBlobs: function(state, blobs) {
      state.recordedBlobs = blobs;
    }
  }
});

export default store;
