mongoose = require 'mongoose'
crypto = require 'crypto'
log = require('../common/logging.coffee').log

'''
Schema
'''
UserSchema = new mongoose.Schema
  type:
    type: String
    default: 'client'
    enum: 'client manager'.split(' ')
  email:
    type: String
    default: ''
  hashedPassword:
    type: String
    default: ''
  salt:
    type: String
    default: ''
  firstName:
    type: String
    default: ''
  lastName:
    type: String
    default: ''
  # interests: Array
  picture:
    type: String
    default: 'default.jpg'

'''
Virtuals
'''
UserSchema
  .virtual('password')
  .set((password)->
    @_password = password
    @salt = @generateSalt()
    @hashedPassword = @encryptPassword password, @salt
  )
  .get ()->
    @_password

'''
Validations
'''
UserSchema.path('firstName').validate((name)->
  name?.length
, 'First name cannot be blank')

UserSchema.path('lastName').validate((name)->
  name?.length
, 'Last name cannot be blank')

UserSchema.path('email').validate((email)->
  email?.length
, 'Email cannot be blank')

UserSchema.path('email').validate((email)->
  re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test email
, 'Email seems to be wrong')

UserSchema.path('email').validate((email, fn)->
  User = mongoose.model('User')

  if not @itNew and not @isModified('email')
    fn(true)
  else
    User.find({email: email}).exec (error, users)->
      fn(!error && users.length is 0)

, 'Email already exists')

UserSchema.path('hashedPassword').validate((password)->
  password?.length
, 'Password cannot be blank')

'''
Pre-save hooks
'''
UserSchema.pre 'save', (next)->
  return next() if not @isNew

  if not @password
    next(new Error('Invalid password'))
  else
    next()

'''
Methods
'''
UserSchema.methods =
  authenticate: (password)->
    @encryptPassword(password, @salt) is @hashedPassword
  generateSalt: ()->
    '' + Math.round(Date.now() * Math.random())
  encryptPassword: (password, salt)->
    return '' if not password or not salt

    try
      encrypred = crypto.createHmac('sha1', salt).update(password).digest('hex')
      return encrypred
    catch error
      log 'Error while encripting password'
      return ''
  getPublicData: ->
    firstName: @firstName
    lastName: @lastName
    type: @type
    picture: @picture


module.exports = mongoose.model 'User', UserSchema
