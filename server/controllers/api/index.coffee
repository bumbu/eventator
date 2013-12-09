_package = require('./../../../package.json')

exports.root = (req, res)->
  res.json
    version: _package.version
