User = require('../models/user.coffee')
errorHandler = require('../libs/error.coffee')

exports.check = (req, res, next)->
  return errorHandler.json res, 401, 'User not authenticated' if not req.session.userId? or not req.session.userId

  # load user
  await User.findOne {_id: req.session.userId}, defer(error, user)

  return errorHandler.json res, 504, 'Database error while searching for user' if error
  return errorHandler.json res, 403, 'Something happened and authenticated user was not found' if not user

  # keep user in req
  req.session_user = user

  next()
