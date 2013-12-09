'''
Requires
'''
# Routers
ApiIndex = require('./controllers/api/index.coffee')
ApiAuthentication = require('./controllers/api/authentication.coffee')
ApiUser = require('./controllers/api/user.coffee')
# Libs
errorHandler = require('./libs/error.coffee')

'''
Check if need authentication
'''
exports.doesRequireAuthentication = (url, method)->
  # Do not check non api requests
  return false if url.substr(0, 5) is not '/api/'
  # DO not check main api path
  return false if url is '/api/'
  # Registration
  return false if url is '/api/user/' and method.toUpperCase() is 'POST'
  # Authentication
  return false if url is '/api/authentication/' and method.toUpperCase() is 'POST'
  # Else path require authentication

  return true

'''
Bind Routes
'''
exports.bindRoutes = (app)->
  app.get '/api/', (req, res)-> ApiIndex.root req, res

  # Authentication
  app.post '/api/authentication/', (req, res)-> ApiAuthentication.authenticate req, res

  # User
  app.get '/api/user/', (req, res)-> ApiUser.get req, res
  app.post '/api/user/', (req, res)-> ApiUser.create req, res
  app.put '/api/user/', (req, res)-> ApiUser.update req, res
  app.delete '/api/user/', (req, res)-> ApiUser.delete req, res
  app.get '/api/user/:id', (req, res)-> ApiUser.getById req, res
  app.put '/api/user/:id', (req, res)-> ApiUser.updateById req, res
  app.delete '/api/user/:id', (req, res)-> ApiUser.deleteById req, res
