# detect environment
NODE_ENV = process.env.NODE_ENV || 'production'

# requires
fs = require 'fs'


if NODE_ENV is 'development'
  # output to console
  log = (messages...)->
    if messages.length is 1
      console.log Date.now(), messages[0]
    else
      console.log Date.now(), messages
else if NODE_ENV is 'production'
  # save in file
  log = (messages...)->
    fs.open __dirname + '/../../logs/logs.txt', 'a', '0644', (error, fileHanldler)->
      if error
        console.log? Date.now(), 'error while opening log file'
      else
        text = Date.now() + "\n"
        text += '  ' + message + "\n" for message in messages
        fs.write fileHanldler, text, null, 'utf8', (error, written)->
          if error
            console.log? Date.now(), 'error writing to log file'
          else fs.close fileHanldler

exports.log = log
