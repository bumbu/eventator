_package = require('./../../package.json')
User = require('../models/user.coffee')
errorHandler = require('../common/error.coffee')
ObjectId = require('mongoose').Schema.ObjectId

exports.doesRequireAuthentication = (url, method)->
  # Do not check non api requests
  return false if url.substr(0, 5) is not '/api/'
  # Registration
  return false if url is '/api/user/' and method.toUpperCase() is 'POST'
  # Else path require authentication
  return true

exports.bindRoutes = (app)->
  app.get '/api/', (req, res)->
    res.json
      version: _package.version

  # Authenticate
  app.post '/api/authentication/', (req, res)->
    if req.session_user?
      return errorHandler.json res, 200, 'You are already authenticated',
        user: req.session_user.getPublicData()

    await User.findOne {email: req._params.email} , defer(error, user)

    return errorHandler.json res, 504, 'Database error while searching for user' if error
    return errorHandler.json res, 403, 'User with given email was not found' if not user
    return errorHandler.json res, 403, 'Email or password is wrong' if not user.authenticate req._params.password

    # Save into session
    req.session.userId = user.id
    res.json
      success: true
      user: user.getPublicData()

  # TODO move to user file

  # Get authenticated user data
  app.get '/api/user/', (req, res)->
    res.json
      success: true
      user: req.session_user.getPublicData()

  # Create new user
  app.post '/api/user/', (req, res)->
    user = new User req._params

    user.save (error)->
      if error
        res.json 400,
          success: false
          error_message: error.message + ': ' + (error.errors[_error].message for _error of error.errors).join('; ')
      else
        res.json
          success: true

  # Update authenticated user
  app.put '/api/user/', (req, res)->
    # User = new User()
    console.log req._params
    res.json
      success: true

  # Delete authenticated user
  app.delete '/api/user/', (req, res)->
    # await User.findOneAndRemove {email: req.session_user.email}, defer(error)

    # return errorHandler.json 504, 'Database error while deleting user' if error

    res.json
      success: true

