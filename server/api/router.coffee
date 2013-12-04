_package = require('./../../package.json')
User = require('../models/user.coffee')
ObjectId = require('mongoose').Schema.ObjectId

exports.bindRoutes = (app)->
  app.get '/api/', (req, res)->
    res.json
      version: _package.version

  app.post '/api/authentication/', (req, res)->
    if req.session.userId?
      User.findOne
        _id: req.session.userId
        , (error, user)->
          if error
            res.json 504,
              success: false
              error_message: 'Database error while searching for user'
          else
            if not user
              res.json 403,
                success: false
                errror_message: 'Something happened and authenticated user was not found'
            else
              res.json
                success: false
                error_message: 'You are already authenticated'
                user: user.getPublicData()
    else
      User.findOne
        email: req.body.email
        , (error, user)->
          if error
            res.json 504,
              success: false
              error_message: 'Database error while searching for user'
          else
            if not user
              res.json 403,
                success: false
                error_message: 'User with given email was not found' + req.body.email
            else
              if user.authenticate req.body.password
                # Save into session
                req.session.userId = user.id
                res.json
                  success: true
                  user: user.getPublicData()
              else
                res.json 403,
                  success: false
                  error_message: 'Email or password are wrong. Please check them and try one more time'

  # req.query.email
  # req.body.email

  # app.get '/api/user/', (req, res)->
  #   res.json
  #     email


  # TODO move to user file
  app.post '/api/user/', (req, res)->
    user = new User
      password: req.query.password || req.body.password
      email: req.query.email || req.body.email
      firstName: req.query.firstName || req.body.firstName
      lastName: req.query.lastName || req.query.lastName

    user.save (error)->
      if error
        #TODO remove console log
        # console.log error
        #TODO we need different response types for different errors
        res.json
          success: false
          error_message: error.message
          # email: req.query.email
          errors: error.errors
      else
        res.json
          success: true

  app.delete '/api/user/', (req, res)->
    User.findOneAndRemove
      email: req.query.email || req.body.email
      , (error)->
        if error
          res.json 504,
            success: false
            error_message: 'Database error while findOneAndRemove user'
        else
          res.json
            success: true

  app.put '/api/user/', (req, res)->
    User = new User()
    console.log req.body.password
    res.json
      success: true
