# Parse HTML pages
cheerio = require 'cheerio'

exports.parseListFromPage =
parseListFromPage = (html) ->
    $ = cheerio.load html
    console.log "constructed DOM from html. Parsing for biobricks..."
    parts = []
    $('A[href^="view.cgi"]').each (index, element) ->
        parts.push $(element).text()
    parts
