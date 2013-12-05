exports.json = (res, code, message, parameters)->
  json =
    success: false
    error_message: message

  # Extend response
  for key, val of parameters
    json[key] = val

  res.json code, json
