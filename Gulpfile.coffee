G = require 'gulp'
pug = require 'gulp-pug'
coffee = require 'gulp-coffee'

G.task 'default', (done) ->
  G
    .src 'index.jade'
    .pipe pug()
    .pipe G.dest 'dist'
  G
    .src 'dashboard.coffee'
    .pipe coffee(bare: true)
    .pipe G.dest 'dist'

  G
    .src 'vendor/**'
    .pipe G.dest 'dist'
  G
    .src 'assets/**'
    .pipe G.dest 'dist/assets'


G
  .watch ['dashboard.coffee', 'index.jade'], ['default']
