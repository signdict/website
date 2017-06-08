import Vue       from 'vue/dist/vue.common.js'
import Vuex      from 'vuex'
Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    recordedBlobs: [],
    recordedDuration: 0
  },
  mutations: {
    setRecordedBlobs: function(state, blobs) {
      state.recordedBlobs = blobs;
    },
    setRecordedDuration: function(state, duration) {
      state.recordedDuration = duration;
    }
  }
});

export default store;
