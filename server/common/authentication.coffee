User = require('../models/user.coffee')
errorHandler = require('../common/error.coffee')

exports.check = (req, res, next)->
  if req.session.userId?
    User.findOne
      _id: req.session.userId
      , (error, user)->
        if error
          errorHandler.json res, 504, 'Database error while searching for user'
        else
          if not user
            errorHandler.json res, 403, 'Something happened and authenticated user was not found'
          else
            # keep user in req
            req.session_user = user
            next()
  else
    next()
