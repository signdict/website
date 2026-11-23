const path = require('path');

// CSS parsing, extraction and minification as well as copying static files
// and JS minification are all built into webpack 5 (>= 5.111), so no
// css-loader, mini-css-extract-plugin, copy-webpack-plugin or minimizer
// plugins are needed.
module.exports = (env, options) => ({
  devtool: 'source-map',
  experiments: {
    css: true,
  },
  entry: {
    app: './js/app.js',
    backend: './js/backend.js',
  },
  output: {
    path: path.resolve(__dirname, '../priv/static'),
    filename: 'js/[name].js',
    cssFilename: 'css/[name].css',
    copy: 'static',
  },
  resolve: {
    // Resolve Phoenix's JS packages (e.g. phoenix_html) from the Elixir deps,
    // so they always match the hex versions in mix.lock.
    modules: ['node_modules', path.resolve(__dirname, '../deps')],
  },
  module: {
    parser: {
      'css/auto': {
        // Leave url() references untouched; fonts and images are copied
        // from static/ and referenced by their final path.
        url: false,
      },
    },
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
      {
        // Plain .css files (e.g. plyr's stylesheet) are handled by webpack's
        // built-in css/auto rule; only Sass needs a loader.
        test: /\.scss$/,
        use: ['sass-loader'],
        type: 'css/auto',
      },
    ],
  },
});
