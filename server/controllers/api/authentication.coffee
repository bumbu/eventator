'''
Requires
'''
# Libs
errorHandler = require('../../libs/error.coffee')
# Models
User = require('../../models/user.coffee')

'''
Exports
'''
exports.authenticate = (req, res)->
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
