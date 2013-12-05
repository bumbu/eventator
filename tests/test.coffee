should = require('chai').should()
supertest = require('supertest')
api = supertest('http://localhost:3000')
_package = require('./../package.json')

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
  before (done)->
    api.post('/api/user/')
      .send
        email: 'me@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .end (err, res)->
        return done(err) if err
        done()

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

  it 'successfully register an user', (done)->
    done()

  'retrieve registered and authenticated user data'

  'try to get authenticated user data while being not authenticated'

  'update authenticated user data'

  'check if updated user data is right'

  'self delete user'

describe 'Authentication', (done)->
  # Create an random email
  # _email = Math.floor(Math.random()*99999 + 1) + '@bumbu.ru'

  # Register new user
  before (done)->
    api.post('/api/user/')
      .send
        email: 'test@bumbu.ru'
        password: '123456'
        firstName: 'Alex'
        lastName: 'Bumbu'
      .end (err, res)->
        return done(err) if err

        done()

  # delete previously created user user
  after (done)->
    api.del('/api/user/')
      .send
        email: 'test@bumbu.ru'
      .expect(200)
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
