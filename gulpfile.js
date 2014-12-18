var gulp = require('gulp');
var coffee = require('gulp-coffee');
var del = require('del');
var rename = require('gulp-rename');

gulp.task('clean', function(cb) {
  return del(['.bin'], cb);
});

gulp.task('default', ['clean'], function() {
  return gulp.src('src/index.coffee')
    .pipe(coffee())
    .pipe(rename('swagged-angular-resource.js'))
    .pipe(gulp.dest('.bin/'));
});
