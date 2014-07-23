# Retrieve data from partsregistry.org. For how this works see partsRegistrySearchFormat.md
request = require 'request'
parser = require './parserService'

### Search parts.igem.org ###
exports.routes = routes =
    text: "/api/v1/search/text"
    thousand: "/api/v1/search/thousand"
    subparts: "/api/v1/search/subparts"
    superparts: "/api/v1/search/superparts"

searchConfig =
    baseSearchUrl: "http://parts.igem.org/cgi/partsdb/search.cgi?"
    baseApiUrl: "http://parts.igem.org/cgi/xml/part.cgi?part="
    text:
        nameTextInput: "searchfor1"
        nameSubmitButton: "searchfor"
    thousand:
        nameTextInput: "fist_part"
        nameSubmitButton: "search_from_to"
    subparts:
        nameTextInput: "part_list"
        nameSubmitButton: "search_subparts"
    superparts:
        nameTextInput: "super_part_list"
        nameSubmitButton: "search_superparts"

# Construct the url needed to submit a search on partsregistry.org
# http://parts.igem.org/cgi/partsdb/search.cgi?[nameTextInput]=[STRING];[nameSubmitButton]=Search`
# * `textInput`: The name of the text input. Should come from searchConfig
# * `submitButton`: The name of the submit button. Should come from searchConfig
# * `searchString`: The string to search for.
getQueryUrl = (textInput, submitButton, searchString) ->
    searchConfig.baseSearchUrl + textInput + "=" + searchString + ";" + submitButton + "=Search"

search = (req, res) ->
    path = req.route.path
    searchTerms = req.query.searchTerms
    console.log "Searching..."
    console.log "path: " + path
    console.log "searchTerms: " + searchTerms
    # callback
    done = (error, response, body) ->
        if error then res.send 404, error
        # The response from partsregistry is the full HTML page.
        # Parse the page and get a list of parts.
        console.log "Recieved page response length: #{body.length} from partsregistry, parsing for biobricks..."
        parts = parser.parseListFromPage body
        console.log "Parsed parts! There are #{parts.length} parts:\n#{parts}"
        res.send 200, parts

    if path is routes.text
        searchText searchTerms, done
    else if path is routes.thousand
        searchThousand searchTerms, done
    else if path is routes.subparts
        searchSubparts searchTerms, done
    else if path is routes.superparts
        searchSuperparts searchTerms, done

searchText = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.text.nameTextInput,
        searchConfig.text.nameSubmitButton,
        searchTerms
        )
    request url, done

searchThousand = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.thousand.nameTextInput,
        searchConfig.thousand.nameSubmitButton,
        searchTerms
        )
    request url, done

searchSubparts = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.subparts.nameTextInput,
        searchConfig.subparts.nameSubmitButton,
        searchTerms
        )
    request url, done

searchSuperparts = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.superparts.nameTextInput,
        searchConfig.superparts.nameSubmitButton,
        searchTerms
        )
    request url, done

### Get Individiual Parts ###

getBrick = (req, res) ->
    console.log searchConfig.baseApiUrl + req.params.brick
    request searchConfig.baseApiUrl + req.params.brick, (error, response, body) ->
        if error then res.send 404, error
        res.send 200, body

# Exports
exports.search = search
exports.getBrick = getBrick
