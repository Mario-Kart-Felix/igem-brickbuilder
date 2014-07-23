brickSearch = require '../services/brickSearchService.coffee'

# GET '/'
index = (req, res) ->
    res.render 'index'

exports.initRoutes = (app) ->
    # page GETs
    app.get '/', index

    # API GETs
    app.get '/api/v1/search', (req, res) -> res.send 200, "Stop it!"
    app.get brickSearch.routes.text, brickSearch.search
    app.get brickSearch.routes.thousand, brickSearch.search
    app.get brickSearch.routes.subparts, brickSearch.search
    app.get brickSearch.routes.superparts, brickSearch.search

    app.get '/api/v1/brick/:brick', brickSearch.getBrick
