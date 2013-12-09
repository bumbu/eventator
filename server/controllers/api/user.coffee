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

exports.getById = (req, res)->
  await User.findById req.params.id, defer(error, user)

  return errorHandler.json res, 504, 'Database error while searching for user by id' if error
  return errorHandler.json res, 403, 'User with given id was not found' if not user

  res.json
    success: true
    user: user.getPublicData()

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

userUpdateById = (req, res, id)->
  User.findById id, (error, user)->
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

# Update authenticated user
exports.update = (req, res)->
  userUpdateById req, res, req.session_user._id

# Update user by id
exports.updateById = (req, res)->
  userUpdateById req, res, req.params.id

userDeleteById = (req, res, id, unset_session = false)->
  await User.findOneAndRemove {_id: id}, defer(error)

  return errorHandler.json 504, 'Database error while deleting user' if error

  # Clean session
  req.session.userId = null if unset_session

  res.json
    success: true

# Delete authenticated user
exports.delete = (req, res)->
  userDeleteById req, res, req.session_user._id.toString(), true

exports.deleteById = (req, res)->
  userDeleteById req, res, req.params.id
