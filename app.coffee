# Module Dependencies

express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'

# define and configure app
app = express()
app.configure () ->
    app.set 'port', process.env.PORT || 3000
    app.set 'views', __dirname + '/views'
    app.set 'view engine', 'jade'
    app.use express.favicon()
    app.use express.logger 'dev'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use require('connect-assets')()
    app.use express.static path.join __dirname, 'assets'

app.configure 'development', () ->
    app.use express.errorHandler()

# route GET requests to the proper place
routes.initRoutes app

# start listening
port = app.get 'port'
app.listen port
console.log "Express server listening on port " + port
