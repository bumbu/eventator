console.log? 'try to run'

express = require 'express'
app = express()

app.get '/', (req, res)->
  body = 'Hello World'
  res.setHeader 'Content-Type', 'text/plain'
  res.setHeader 'Content-Length', body.length
  res.end body

app.get '/test/', (req, res)->
  res.send 'Hello Test 2' + process.env.PORT

app.listen 3000

console.log? 'app listening now'
