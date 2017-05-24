import Vue from 'vue'
import MyApp from "./components/my-app.vue"

document.onreadystatechange = function () {
  if (document.readyState == "complete") {
    // Import "globally" used libraries -- importing them from Vue components alone
    // seems to trip up brunch at the moment (they won't be included in the final
    // app.js file)

    // import "lodash"

    // Create the main component

    Vue.component('my-app', MyApp)

    // And create the top-level view model:

    new Vue({
      el: '#app',
      data() {
        return {
          // state for the top level component, e.g
          currentMessage: "Hello World"
        }
      },
      render: function (createElement) {
        return createElement(MyApp, {
          props: {
            // props for the top level component, e.g.
            message: this.currentMessage
          }
        })
      }
    });
  }
}
