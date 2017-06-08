import Vue       from 'vue/dist/vue.common.js'
import Vuex      from 'vuex'
Vue.use(Vuex);

const store = new Vuex.Store({
  state: {
    recordedBlobs: [],
    recordedDuration: 0,
    startTime: 0,
    endTime:   0,
  },
  mutations: {
    setRecordedBlobs: function(state, blobs) {
      state.recordedBlobs = blobs;
    },
    setRecordedDuration: function(state, duration) {
      state.recordedDuration = duration;
    },
    setStartTime: function(state, time) {
      console.log("start time " + time);
      state.startTime = time;
    },
    setEndTime: function(state, time) {
      console.log("end time " + time);
      state.endTime = time;
    }
  }
});

export default store;
