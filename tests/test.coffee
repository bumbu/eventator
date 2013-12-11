'''
Requires
'''
should = require('chai').should()
supertest = require('supertest')
api = supertest('http://localhost:3000')
_package = require('./../package.json')

'''
Variables
'''
usersBones =
  client: 'client'
  client2: 'client'
  manager: 'manager'
  manager2: 'manager'
  admin: 'admin'
  admin2: 'admin'
users = {}
for user, role of usersBones
  users[user] =
    email: user + '@bumbu.ru'
    password: user
    firstName: user.substr(0,1).toUpperCase() + user.substr(1) + 'u'
    lastName: 'Do' + user
    role: role
    cookie: ''
    id: ''
slaughterer =
  email: 'slaughterer@bumbu.ru'
  password: 'sword'
  firstName: 'Iane'
  lastName: 'Miladrj'
  role: 'admin'
  cookie: ''
  id: ''


'''
Helpers
'''
deleteUserById = (id, done, callback)->
  return done(new Error('Id for deleting not defined')) if not id
  api.del('/api/user/' + id)
    .set('Cookie', slaughterer.cookie)
    .type('form')
    .expect(200)
    .end (err, res)->
      return done(err) if err
      res.body.should.have.property('success').equal(true)
      callback()

deleteUser = (user, done, callback)->
  # if user has id, delete by id
  if user.id? and user.id
    deleteUserById user.id, done, callback
  # else try to find it's id
  else
    api.post('/api/authentication/')
      .type('form')
      .send(user)
      .end (err, res)->
        return done(err) if err
        return callback() if not res.body.success

        res.body.should.have.property('user')
        res.body.user.should.have.property('id')

        deleteUserById res.body.user.id, done, callback

createUser = (user, done, callback)->
  deleteUser user, done, ()->
    api.post('/api/user/')
      .send(user)
      .end (err, res)->
        return done(err) if err
        callback()


'''
Before starting
'''
before (done)->
  # Try to authenticate
  checkAndRetrieve = (res)->
    res.body.should.have.property('success').equal(true)
    res.body.should.have.property('user')
    res.body.user.should.have.property('id')
    res.header.should.have.property('set-cookie')
    res.header['set-cookie'].should.have.length.above(0)

    # get session cookie
    if res.header['set-cookie'][0]
      slaughterer.cookie = res.header['set-cookie'][0].split(';')[0]
    # get user id
    slaughterer.id = res.body.user.id

  api.post('/api/authentication/')
    .type('form')
    .send(slaughterer)
    .end (err, res)->
      if res.status is 403
        # create user
        api.post('/api/user/')
          .send(slaughterer)
          .end (err, res)->
            return done(err) if err
            checkAndRetrieve(res)
            done()
      else
        return done(err) if err
        checkAndRetrieve(res)
        done()

'''
Test API
'''
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

'''
Test Authentication
'''
describe 'Authentication', (done)->
  # Create an random email
  # _email = Math.floor(Math.random()*99999 + 1) + '@bumbu.ru'
  cookie = ''

  # Create new user
  before (done)->
    createUser users.client, done, done

  it 'successful authentication', (done)->
    api.post('/api/authentication/')
      .type('form')
      .send(users.client)
      .expect(200)
      .expect('Content-Type', /json/)
      .expect('Set-Cookie', /connect\.sid/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(true)

        done()

  it 'unsuccessful authentication', (done)->
    api.post('/api/authentication/')
      .send
        email: 'none@bumbu.ru'
        password: '123456'
      .expect(403)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.not.have.property('sessionid')
        res.body.should.have.property('error_message')

        done()

  it 'unsuccessful authentication due to unexistance of such user', (done)->
    api.post('/api/authentication/')
      .send
        email: 'this is not an email'
        password: '123456'
      .expect(403)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)
        res.body.should.not.have.property('sessionid')
        res.body.should.have.property('error_message')

        done()

'''
Test User
'''
describe 'User', (done)->
  # Ensure client@bumbu.ru exists
  before (done)->
    createUser users.client, done, done

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
      .send(users.client)
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
        email: 'client@bumbu.ru'
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
        email: 'client@bumbu.ru'
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
        email: 'client@bumbu.ru'
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

  it 'try to get authenticated user data while being not authenticated', (done)->
    api.get('/api/user/')
      .expect(401)
      .expect('Content-Type', /json/)
      .end (err, res)->
        return done(err) if err

        res.body.should.have.property('success').equal(false)

        done()

  for username, user of users
    # Namespase user
    ((user)->

      # + retrieves cookie
      it user.role + ': successfully register', (done)->
        deleteUser user, done, ()->
          api.post('/api/user/')
            .send(user)
            .expect(200)
            .expect('Content-Type', /json/)
            .end (err, res)->
              return done(err) if err

              res.body.should.have.property('success').equal(true)
              res.header.should.have.property('set-cookie')
              res.header['set-cookie'].should.have.length.above(0)

              # get session cookie
              if res.header['set-cookie'][0]
                user.cookie = res.header['set-cookie'][0].split(';')[0]

              done()

      # + retrieves userID
      it user.role + ': retrieve authenticated user data', (done)->
        user.cookie.should.have.length.above(0)
        api.get('/api/user/')
          .set('Cookie', user.cookie)
          .expect(200)
          .expect('Content-Type', /json/)
          .end (err, res)->
            return done(err) if err

            res.body.should.have.property('success').equal(true)
            res.body.should.have.property('user')
            res.body.user.should.have.property('firstName').equal(user.firstName)
            res.body.user.should.have.property('lastName').equal(user.lastName)
            res.body.user.should.have.property('id')
            res.body.user.should.have.property('role').equal(user.role)

            user.id = res.body.user.id

            done()

      it user.role + ': update authenticated user data', (done)->
        user.cookie.should.have.length.above(0)
        user.firstName += 'os'
        user.lastName += 'un'
        api.put('/api/user/')
          .set('Cookie', user.cookie)
          .send(user)
          .expect(200)
          .expect('Content-Type', /json/)
          .end (err, res)->
            return done(err) if err

            res.body.should.have.property('success').equal(true)

            done()

      it user.role + ': check if updated user data is right', (done)->
        user.cookie.should.have.length.above(0)
        api.get('/api/user/')
          .set('Cookie', user.cookie)
          .expect(200)
          .expect('Content-Type', /json/)
          .end (err, res)->
            return done(err) if err

            res.body.should.have.property('success').equal(true)
            res.body.should.have.property('user')
            res.body.user.should.have.property('firstName').equal(user.firstName)
            res.body.user.should.have.property('lastName').equal(user.lastName)

            done()

    # End Namespacing user
    )(user)

  '''
  foreach [client, manager, admin]
    get self by id
    get client by id
    get manager by id
    get admin by id
    update self by id + check
    update client by id + check if 200 expected
    update manager by id + check if 200 expected
    update admin by id + check if 200 expected
    delete self + create back if 200 expected
    delete client + create back if 200 expected
    delete manager + create back if 200 expected
    delete admin + create back if 200 expected
  '''
  scenarios = [
    user: users.client
    acts: [
      action: 'get'
      what: users.client
      expect: 200
    ,
      action: 'get'
      what: users.client2
      expect: 200
    ,
      action: 'get'
      what: users.manager
      expect: 200
    ,
      action: 'get'
      what: users.admin
      expect: 200
    ,
      action: 'update'
      what: users.client
      expect: 200
    ,
      action: 'check'
      what: users.client
      expect: 200
    ,
      action: 'update'
      what: users.client2
      expect: 405
    ,
      action: 'update'
      what: users.manager
      expect: 405
    ,
      action: 'update'
      what: users.admin
      expect: 405
    ,
      action: 'delete'
      what: users.client
      expect: 405
    ,
      action: 'delete'
      what: users.client2
      expect: 405
    ,
      action: 'delete'
      what: users.manager
      expect: 405
    ,
      action: 'delete'
      what: users.admin
      expect: 405
    ]
  ,
    user: users.manager
    acts: [
      action: 'get'
      what: users.client
      expect: 200
    ,
      action: 'get'
      what: users.manager
      expect: 200
    ,
      action: 'get'
      what: users.manager2
      expect: 200
    ,
      action: 'get'
      what: users.admin
      expect: 200
    ,
      action: 'update'
      what: users.client
      expect: 405
    ,
      action: 'update'
      what: users.manager
      expect: 200
    ,
      action: 'check'
      what: users.manager
      expect: 200
    ,
      action: 'update'
      what: users.manager2
      expect: 405
    ,
      action: 'update'
      what: users.admin
      expect: 405
    ,
      action: 'delete'
      what: users.client
      expect: 405
    ,
      action: 'delete'
      what: users.manager
      expect: 405
    ,
      action: 'delete'
      what: users.manager2
      expect: 405
    ,
      action: 'delete'
      what: users.admin
      expect: 405
    ]
  ,
    user: users.admin
    acts: [
      action: 'get'
      what: users.client
      expect: 200
    ,
      action: 'get'
      what: users.manager
      expect: 200
    ,
      action: 'get'
      what: users.admin
      expect: 200
    ,
      action: 'get'
      what: users.admin2
      expect: 200
    ,
      action: 'update'
      what: users.client
      expect: 200
    ,
      action: 'check'
      what: users.client
      expect: 200
    ,
      action: 'update'
      what: users.manager
      expect: 200
    ,
      action: 'check'
      what: users.manager
      expect: 200
    ,
      action: 'update'
      what: users.admin
      expect: 200
    ,
      action: 'check'
      what: users.admin
      expect: 200
    ,
      action: 'update'
      what: users.admin2
      expect: 200
    ,
      action: 'check'
      what: users.admin2
      expect: 200
    ,
      action: 'delete'
      what: users.client
      expect: 200
    ,
      action: 'create'
      what: users.client
      expect: 200
    ,
      action: 'delete'
      what: users.manager
      expect: 200
    ,
      action: 'create'
      what: users.manager
      expect: 200
    ,
      action: 'delete'
      what: users.admin
      expect: 200
    ,
      action: 'create'
      what: users.admin
      expect: 200
    ,
      action: 'delete'
      what: users.admin2
      expect: 200
    ,
      action: 'create'
      what: users.admin2
      expect: 200
    ]
  ]

  methods =
    get: 'get'
    update: 'put'
    delete: 'del'
    check: 'get'
    create: 'post'

  for scenario in scenarios
    ((user)->
      for act in scenario.acts
        ((act)->
          title = user.role + ': '
          switch act.action
            when 'get', 'update', 'delete'
              title += act.action + " #{if user.email is act.what.email then 'self' else act.what.role} by id"
            when 'check'
              title += "check if updating #{if user.email is act.what.email then 'self' else act.what.role} by id worked"
            when 'create'
              title += 'create ' + act.what.role
            else
              title += 'no title'

          it title, (done)->
            if not (act.action is 'create')
              user.cookie.should.have.length.above(0)
              act.what.id.should.have.length.above(0)

            set = {}
            if not (act.action is 'create')
              set = {Cookie: user.cookie}

            send = {}
            if act.action is 'update'
              if act.expect is 200
                send.firstName = act.what.firstName += '_x'
                send.lastName = act.what.lastName += '_y'
              else
                send.firstName = act.what.firstName + '_x'
                send.lastName = act.what.lastName + '_y'
            else if act.action is 'create'
              send = act.what

            url = '/api/user/'
            url += act.what.id if not (act.action is 'create')

            api[methods[act.action]](url)
              .set(set)
              .send(send)
              .expect(act.expect)
              .expect('Content-Type', /json/)
              .end (err, res)->
                return done(err) if err

                if act.expect is 200
                  res.body.should.have.property('success').equal(true)
                  if act.action in ['get', 'check']
                    res.body.should.have.property('user')
                    res.body.user.should.have.property('id').equal(act.what.id)
                  if act.action is 'check'
                    res.body.user.should.have.property('firstName').equal(act.what.firstName)
                    res.body.user.should.have.property('lastName').equal(act.what.lastName)
                  if act.action is 'delete'
                    # Remove cookie and id from cache
                    act.what.cookie = ''
                    act.what.id = ''
                  if act.action is 'create'
                    res.body.should.have.property('user')
                    res.body.user.should.have.property('id')
                    res.header.should.have.property['set-cookie']
                    res.header['set-cookie'].should.have.length.above(0)

                    # get session cookie
                    act.what.cookie = res.header['set-cookie'][0].split(';')[0]
                    # get user id
                    act.what.id = res.body.user.id
                else
                  res.body.should.have.property('success').equal(false)

                done()

        )(act)
    )(scenario.user)
