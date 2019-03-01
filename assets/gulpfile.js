var fs = require("fs"),
  gulp = require("gulp"),
  del = require("del"),
  rsync = require("gulp-rsync"),
  postcss = require("gulp-postcss"),
  autoprefixer = require("autoprefixer"),
  cssnano = require("cssnano"),
  rollup = require("rollup-stream"),
  sourcemaps = require("gulp-sourcemaps"),
  source = require("vinyl-source-stream"),
  buffer = require("vinyl-buffer"),
  resolve = require("rollup-plugin-node-resolve"),
  commonjs = require("rollup-plugin-commonjs"),
  babel = require("rollup-plugin-babel"),
  replace = require("rollup-plugin-replace"),
  vue = require("rollup-plugin-vue"),
  merge = require("merge-stream");

function swallowError(error) {
  console.log(error.toString());
  console.log(error);
  this.emit("end");
}

gulp.task("clean", function() {
  return del(["../priv/static"], { force: true });
});

gulp.task("static", function() {
  return gulp
    .src("static/**")
    .on("error", swallowError)
    .pipe(
      rsync({
        root: "static/",
        destination: "../priv/static/",
        silent: true
      })
    );
});

gulp.task("css", function() {
  var plugins = [
    require("postcss-partial-import"),
    require("postcss-advanced-variables"),
    autoprefixer({ browsers: ["last 3 versions"] }),
    cssnano()
  ];
  return gulp
    .src("css/*.css")
    .on("error", swallowError)
    .pipe(sourcemaps.init())
    .pipe(postcss(plugins))
    .pipe(sourcemaps.write("."))
    .pipe(gulp.dest("../priv/static/css/"));
});

gulp.task("js", function() {
  files = fs.readdirSync("js/").filter(function(file) {
    return fs.statSync(`js/${file}`).isFile();
  });

  stream = merge();

  files.forEach(function(file) {
    stream.add(
      rollup({
        input: `js/${file}`,
        format: "iife",
        sourcemap: "inline",
        plugins: [
          resolve({
            jsnext: true,
            main: true,
            browser: true
          }),
          vue({
            compileTemplate: true
          }),
          replace({
            "process.env.NODE_ENV": JSON.stringify(
              process.env.NODE_ENV || "development"
            )
          }),
          commonjs(),
          babel({
            exclude: "node_modules/**"
          })
        ]
      })
        .on("error", swallowError)
        .pipe(source(file, "js"))
        .pipe(buffer())
        .pipe(sourcemaps.init({ loadMaps: true }))
        .pipe(sourcemaps.write("."))
        .pipe(gulp.dest("../priv/static/js/"))
    );
  });
  return stream;
});

gulp.task("watch", function() {
  gulp.series(["static", "css", "js"]);
  gulp.watch("static/**/*", gulp.series("static"));
  gulp.watch("css/**/*", gulp.series("css"));
  gulp.watch("js/**/*", gulp.series("js"));
});

gulp.task("build", gulp.series(["static", "css", "js"]));

gulp.task("build-watch", gulp.series(["build", "watch"]));

gulp.task("default", gulp.series(["clean", "build"]));
