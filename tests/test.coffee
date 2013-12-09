should = require('chai').should()
supertest = require('supertest')
api = supertest('http://localhost:3000')
_package = require('./../package.json')

deleteUser = (email, password, done, callback)->
  _cookie = ''

  # try to login
  api.post('/api/authentication/')
    .type('form')
    .send
      email: email
      password: password
    .end (err, res)->
      return done(err) if err

      return callback() if not res.body.success

      # get session cookie
      if res.header['set-cookie']?[0]?
        _cookie = res.header['set-cookie'][0].split(';')[0]

      # ensure unexistent user
      api.del('/api/user/')
        .set('Cookie', _cookie)
        .expect(200)
        .end (err, res)->
          return done(err) if err
          callback()


describe 'API', ()->

  it 'main path', (done)->
    api.get('/api/')
      .expect(200)
      .expect('Content-Type', /json/)
      .end((err, res)->
        return done(err) if err
        res.body.should.have.property('version').equal(_package.version)
        done()
      )

describe 'User', (done)->
  cookie = ''
  userId = ''

  # Ensure me@bumbu.ru exists
  # Ensure test@bumbu.ru doesn't exist
  # Ensure test2@bumbu.ru doesn't exist
  before (done)->
    # ensure existent user
    api.post('/api/user/')
      .send
        email: 'me@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .end (err, res)->
        return done(err) if err

        # delete test user
        deleteUser 'test@bumbu.ru', '123456', done, ()->
          deleteUser 'test2@bumbu.ru', '123456', done, done


  it 'register user, empty email address', (done)->
    api.post('/api/user/')
      .send
        email: ''
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/Email cannot be blank/)

        done()

  it 'register user, bad email address', (done)->
    api.post('/api/user/')
      .send
        email: 'not an email address'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/Email seems to be wrong/)

        done()

  it 'register user, email address exists', (done)->
    api.post('/api/user/')
      .send
        email: 'me@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/Email already exists/)

        done()

  it 'register user, blank password', (done)->
    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: ''
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/Password cannot be blank/)

        done()

  it 'register user, blank firstName', (done)->
    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
        firstName: ''
        lastName: 'Bumbu'
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/First name cannot be blank/)

        done()

  it 'register user, blank lastName', (done)->
    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: ''
      .expect(400)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.have.property('error_message').match(/Validation failed/)
        res.body.should.have.property('error_message').match(/Last name cannot be blank/)

        done()

  # + retrieves cookie
  it 'successfully register an user', (done)->
    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        # get session cookie
        if res.header['set-cookie']?[0]?
          cookie = res.header['set-cookie'][0].split(';')[0]

        done()

  # + retrieves userID
  it 'retrieve registered and authenticated user data', (done)->
    cookie.should.have.length.above(0)
    api.get('/api/user/')
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)
        res.body.should.have.property('user')
        res.body.user.should.have.property('firstName').equal('Alex')
        res.body.user.should.have.property('lastName').equal('Bumbu')
        res.body.user.should.have.property('id')

        userId = res.body.user.id

        done()

  it 'try to get authenticated user data while being not authenticated', (done)->
    api.get('/api/user/')
      .expect(401)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)

        done()

  it 'update authenticated user data', (done)->
    cookie.should.have.length.above(0)
    api.put('/api/user/')
      .set('Cookie', cookie)
      .send
        firstName: 'Alexandr'
        lastName: 'Bumbus'
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

  it 'check if updated user data is right', (done)->
    cookie.should.have.length.above(0)
    api.get('/api/user/')
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)
        res.body.should.have.property('user')
        res.body.user.should.have.property('firstName').equal('Alexandr')
        res.body.user.should.have.property('lastName').equal('Bumbus')

        done()

  it 'create new user for user testing by id', (done)->
    api.post('/api/user/')
      .set('Cookie', cookie)
      .send
        email: 'test2@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

  it 'get user by id', (done)->
    cookie.should.have.length.above(0)
    userId.should.have.length.above(0)
    api.get('/api/user/'+userId)
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)
        res.body.should.have.property('user')
        res.body.user.should.have.property('id').equal(userId)

        done()

  it 'update user by id', (done)->
    cookie.should.have.length.above(0)
    userId.should.have.length.above(0)
    api.put('/api/user/'+userId)
      .set('Cookie', cookie)
      .send
        firstName: 'Alexandru'
        lastName: 'Bumbum'
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

  it 'check if updated user data is right', (done)->
    cookie.should.have.length.above(0)
    userId.should.have.length.above(0)
    api.get('/api/user/'+userId)
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)
        res.body.should.have.property('user')
        res.body.user.should.have.property('firstName').equal('Alexandru')
        res.body.user.should.have.property('lastName').equal('Bumbum')
        res.body.user.should.have.property('id').equal(userId)

        done()

  it 'delete user by id', (done)->
    api.del('/api/user/'+userId)
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

  it 'self delete user', (done)->
    api.del('/api/user/')
      .set('Cookie', cookie)
      .expect(200)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

describe 'Authentication', (done)->
  # Create an random email
  # _email = Math.floor(Math.random()*99999 + 1) + '@bumbu.ru'
  cookie = ''

  # Create new user
  before (done)->
    deleteUser 'test@bumbu.ru', '123456', done, done

    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .end (err, res)->
        return done(err) if err

        done()

  it 'successful authentication', (done)->
    api.post('/api/authentication/')
      .type('form')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
      .expect(200)
      .expect('Content-Type', /json/)
      .expect('Set-Cookie', /connect\.sid/)
      .end((err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        # get session cookie
        if res.header['set-cookie']?[0]?
          cookie = res.header['set-cookie'][0].split(';')[0]

        done()
      )

  it 'unsuccessful authentication', (done)->
    api.post('/api/authentication/')
      .send
        email: 'none@bumbu.ru'
        password: '123456'
      .expect(403)
      .expect('Content-Type', /json/)
      .end((err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.not.have.property('sessionid')
        res.body.should.have.property('error_message')

        done()
      )

  it 'unsuccessful authentication due to unexistance of such user', (done)->
    api.post('/api/authentication/')
      .send
        email: 'this is not an email'
        password: '123456'
      .expect(403)
      .expect('Content-Type', /json/)
      .end((err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.not.have.property('sessionid')
        res.body.should.have.property('error_message')

        done()
      )
