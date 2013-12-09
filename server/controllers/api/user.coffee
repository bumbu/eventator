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
# Get authenticated user data
exports.get = (req, res)->
  res.json
    success: true
    user: req.session_user.getPublicData()

# Create new user
exports.create = (req, res)->
  user = new User req._params

  await user.save defer(error)

  if error
    return errorHandler.json res, 400, '',
      error_message: error.message + ': ' + (error.errors[_error].message for _error of error.errors).join('; ')

  # Save into session
  req.session.userId = user.id

  res.json
    success: true

# Update authenticated user
exports.update = (req, res)->
  User.findById req.session_user._id, (error, user)->
    # Update only allowed fields
    for key, val of User.getOverridableParams()
      if req._params[key]? and val.type is 'String'
        user[key] = req._params[key]

    user.save (_error)->
      if error
        return errorHandler.json res, 400, '',
          error_message: error.message + ': ' + (error.errors[_error].message for _error of error.errors).join('; ')
      else
        res.json
          success: true


# Delete authenticated user
exports.delete = (req, res)->
  await User.findOneAndRemove {email: req.session_user.email}, defer(error)

  return errorHandler.json 504, 'Database error while deleting user' if error

  # Clean session
  req.session.userId = null

  res.json
    success: true

# app.get '/api/user/:id', (req, res)->
