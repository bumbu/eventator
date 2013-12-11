'use strict';

module.exports = function(grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  // Project configuration
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    config: {
      base: '.',
      src: 'src',
    },
    // watch: {
    //   coffee: {
    //     files: ['src/**/*.coffee'],
    //     tasks: ['coffee:development']
    //   }
    // },
    nodemon: {
      development: {
        options: {
          file: 'server/server.coffee'
        , watchedFolders: ['server/']
        // , nodeArgs: ['--debug']
        , env: {
            NODE_ENV: 'development'
          // , PORT: '3000'
          }
        , exec: 'iced'
        }
      }
    },
    coffee: {
      // production: {
      //   options: {
      //     bare: true
      //   },
      //   files: [{
      //     expand: true,
      //     cwd: 'src',
      //     src: '*.coffee',
      //     dest: 'server',
      //     ext: '.js'
      //   }]
      // },
      development: {
        options: {
          bare: true
        // , sourceMap: true
        },
        files: [{
          expand: true,
          cwd: 'server',
          src: '**/*.coffee',
          dest: '.compiled',
          ext: '.js'
        }]
      }
    , test: {
        options: {
          bare: true
        // , sourceMap: true
        },
        files: [{
          expand: true,
          cwd: 'tests',
          src: '**/*.coffee',
          dest: '.compiled/tests',
          ext: '.js'
        }]
      }
    },
    clean: {
      all: {
        src: ['.compiled/**/*']
      }
    },
    mochaTest: {
      test: {
        options: {
          // reporter: 'nyan'
          reporter: 'spec' // may use nyan when having many tests
        , require: 'iced-coffee-script'
        , timeout: 2000
        , colors: true
        },
        src: ['tests/**/*.coffee']
      }
    },
  });

  grunt.registerTask('build', [
    // 'clean',
    // 'coffee:production'
  ]);
  grunt.registerTask('b', ['build']);

  grunt.registerTask('test', [
    'coffee:test'         // compile coffee to JS version into .compiled
  , 'mochaTest',
    // 'coffee:production'
  ]);
  grunt.registerTask('t', ['test']);


  grunt.registerTask('development', [
    'clean'               // clean .compiled
  , 'coffee:development'  // compile coffee to JS version into .compiled
  , 'nodemon'
    // 'watch'
  ]);
  grunt.registerTask('d', ['development']);
  grunt.registerTask('default', ['development']);

};
