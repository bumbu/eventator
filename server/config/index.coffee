config =
  production:
    mode: 'production'
    port: 3000
    db: 'xploro'
    dbSession: 'session-xploro'
    secretSession: '1234567890QWERTY'
  development:
    mode: 'development'
    port: 3000
    db: 'xploro-dev'
    dbSession: 'session-xploro-dev'
    secretSession: '1234567890QWERTY'
  test:
    mode: 'test'
    port: 3000
    db: 'xploro-test'
    dbSession: 'session-xploro-test'
    secretSession: '1234567890QWERTY'

module.exports = (mode)->
  return config[mode || process.env.NODE_ENV || 'local'] || config.production;
