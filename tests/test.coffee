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
      .expect(200)
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
