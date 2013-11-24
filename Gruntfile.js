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
            PORT: '3000'
          , NODE_ENV: 'development'
          }
        , exec: 'iced'
        }
      }
    },
    // coffee: {
    //   production: {
    //     options: {
    //       bare: true
    //     },
    //     files: [{
    //       expand: true,
    //       cwd: 'src',
    //       src: '*.coffee',
    //       dest: 'server',
    //       ext: '.js'
    //     }]
    //   },
    //   development: {
    //     options: {
    //       bare: true
    //     , sourceMap: true
    //     },
    //     files: [{
    //       expand: true,
    //       cwd: 'src',
    //       src: '*.coffee',
    //       dest: 'server',
    //       ext: '.js'
    //     }]
    //   }
    // },
    // clean: {
    //   all: {
    //     src: ['server/**/*.map']
    //   }
    // }
    mochaTest: {
      test: {
        options: {
          reporter: 'spec'
        , require: 'iced-coffee-script'
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
    'mochaTest',
    // 'coffee:production'
  ]);
  grunt.registerTask('t', ['test']);


  grunt.registerTask('development', [
    // 'clean',
    // 'coffee:development',
    'nodemon',
    // 'watch'
  ]);
  grunt.registerTask('d', ['development']);
  grunt.registerTask('default', ['development']);

};
