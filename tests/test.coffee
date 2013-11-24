should = require('chai').should()
supertest = require('supertest')
api = supertest('http://localhost:3000')

describe 'Authentication', ()->

  it 'hello world', (done)->
    api.get('/')
      .expect(200)
      .end((err, res)->
        return done(err) if err
        res.text.should.equal("Hello World")
        done()
      )

  it 'errors if wrong basic auth', (done)->
    api.get('/')
      .set('x-api-key', '123myapikey')
      .auth('incorrect', 'credentials')
      .expect(401, done)

  it 'errors if bad x-api-key header', (done)->
    api.get('/')
      .auth('correct', 'credentials')
      .expect(401)
      .expect({error:"Bad or missing app identification header"}, done)

