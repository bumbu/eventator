config = require('./config')()

# requires
express = require 'express'
MongoStore = require('connect-mongo')(express)
mongoose = require 'mongoose'
_package = require('./../package.json')
log = require('./common/logging.coffee').log
routerAPI = require('./api/router.coffee')
authentication = require('./common/authentication.coffee')

# Do not use creatConnection as it creates private connection http://stackoverflow.com/a/10200999/1194327
# db = mongoose.createConnection('localhost', config.db)
mongoose.connect('mongodb://localhost/'+config.db)
db = mongoose.connection

db.on 'error', ()->
  log 'failing connecting to database'

# when connection to database established
db.once 'open', ()->
  # instantiate app
  app = express()

  # set handlers order
  app.use express.static __dirname + '/../public'
  app.use express.cookieParser()
  app.use express.session
    store: new MongoStore
      url: 'mongodb://localhost/'+config.dbSession
    secret: config.secretSession
  app.use express.bodyParser()
  app.use express.methodOverride()
  # check for authentication
  app.use (req, res, next)->
    if routerAPI.doesRequireAuthentication(req.url, req.method)
      authentication.check req, res, next
    else
      next()
  # mixin params
  app.use (req, res, next)->
    req._params = req.params || {}
    for key, value of req.query
      req._params[key] = value if req._params[key] is undefined
    for key, value of req.body
      req._params[key] = value if req._params[key] is undefined
    next()
  app.use app.router
  app.use (err, req, res, next)->
    log err.stack
    res.json 500,
      error_description: 'Something got broken on the server side'

  # add routes
  routerAPI.bindRoutes app

  # start listening
  app.listen config.port

  log 'App listening on port ' + config.port
  log 'Mode ' + config.mode
  log 'Database ' + config.db
