G = require 'gulp'
pug = require 'gulp-pug'

G.task 'default', (done) ->
  G
    .src 'index.jade'
    .pipe pug()
    .pipe G.dest 'dist'

  G
    .src 'vendor/**'
    .pipe G.dest 'dist'
  G
    .src 'assets/**'
    .pipe G.dest 'dist/assets'


G
  .watch 'index.jade', ['default']
