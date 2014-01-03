config =
  production:
    mode: 'production'
    port: 3000
    db: 'eventator'
    dbSession: 'session-eventator'
    secretSession: '1234567890QWERTY'
  development:
    mode: 'development'
    port: 3000
    db: 'eventator-dev'
    dbSession: 'session-eventator-dev'
    secretSession: '1234567890QWERTY'
  test:
    mode: 'test'
    port: 3000
    db: 'eventator-test'
    dbSession: 'session-eventator-test'
    secretSession: '1234567890QWERTY'

module.exports = (mode)->
  return config[mode || process.env.NODE_ENV || 'local'] || config.production;
