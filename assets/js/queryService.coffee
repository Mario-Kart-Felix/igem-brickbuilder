# Client-side script for querying data from partsregistry.org. queryService posts to our server,
# where there is another service that will make the actual request to partsregistry.org.
# This is because making a cross-domain request from the client side throws an error.. but seems to work
# from the node server.

brickUrl = 'api/v1/brick/'

# a map of form ids to search URLS
searches =
    '#form-text-search': '/api/v1/search/text'
    '#form-thousand-search': '/api/v1/search/thousand'
    '#form-subpart-search': '/api/v1/search/subparts'
    '#form-superpart-search': '/api/v1/search/superparts'

# Attach event handlers
Bricklayer.HomeView.afterRender = ->
    for searchId, url of searches
        # this is a closure around url.
        $(searchId).submit do (searchId, url) ->
            (e) ->
                e.preventDefault()
                Bricklayer.search url, $(searchId + " :text").val()
Bricklayer.HomeView.render {}

Bricklayer.BioBrick =
class BioBrick
    constructor: (xml) ->
        @xml = $($.parseXML xml)
        @name          = @getContent "part_name"
        @description   = @getContent "part_short_desc"
        @type          = @getContent("part_type").toLowerCase()
        @releaseStatus = @getContent "release_status"
        @partResults   = @getContent "part_results"
        @partUrl       = @getContent "part_url"
        @rating        = @getContent "part_rating"
        @dateEntered   = @getContent "part_entered"
        @author        = @getContent "part_author"
        @sequence      = @getContent "seq_data"
        @availability = @getContent "sample_status"

        @length = @sequence.length

        @compatibility = {}
        for RFC in Bricklayer.RFCs
            if @type == "plasmid_backbone"
                @compatibility[RFC] = 'yes'
            else
                @compatibility[RFC] = if Bricklayer.RFCService[RFC].isCompatible @sequence then 'yes' else 'no'

    getContent: (tagName) ->
        @xml.find(tagName).contents()[0]?.data

    getContents: (tagName) ->
        content.data for content in @xml.find(tagName).contents()

Bricklayer.lastSearchTerm = "" # keep track of the last search for displaying purposes

Bricklayer.search = (url, searchTerms) ->
    Bricklayer.lastSearchTerm = searchTerms
    console.log "Doing search for #{searchTerms}!"
    $.ajax
        type: "GET"
        url: url
        data:
            searchTerms: searchTerms
        success: (data) ->
            # The data here is an array of biobrick names
            console.log "Parts list received from server\n #{data}.\n Displaying..."
            displayBricks data
        error: (error) ->
            console.log error

Bricklayer.BrickRowResultView =
BrickRowResultView = new Bricklayer.AppendView '#results', '#templateResultsRow'

# Step 1: Start rendering of a table
# Step 2: Fetch full information for each brick, one by one
displayBricks = (brickList) ->

    Bricklayer.ResultsView.render {
        searchTerm: "'" + Bricklayer.lastSearchTerm + "'" # ugly way to get quotes to show up
        numResults: brickList.length
    }

    
    table = $('#searchResultsTable').dataTable(
                "autoWidth": false,
                "searching": false,
                "columnDefs": ["targets": 'nosort', "orderable": false]
            ).DataTable()
    

    for brick in brickList
        $.ajax
            type: "GET"
            url: brickUrl + brick
            success: do (brick) ->
                (data) ->
                    brick = new BioBrick data
                    brick.inBin = (Bricklayer.bin.indexOf(brick.name) != -1)
                    addRow brick, table
            error: (error) ->
                console.log error

# DataTable add row with style
addRow = (brick, table) ->

    # Initialize row data with style
    nameCell        = "<a class='extend part-header toggle-#{brick.name}' style='cursor:pointer'>
                        <i class='icon-right-open resultIcon'></i>#{brick.name}"
    typeCell        = "<span class='label #{brick.type}'>#{brick.type}"
    lengthCell      = "<span>#{brick.length}"
    assemblyCell    = "<span>"
    buttonCell      = "<a style='cursor:pointer' id='toggle-bin-#{brick.name}' class='text-large'"
    reviewsCell     = "<span><i class='icon-star'></i><i class='icon-heart'> /5</i>"
    
    childRow = "<p class='description'>| #{brick.description}</p>
                <p class='remarks'>| Submitted #{brick.dateEntered}</p>
                <a href='#{brick.partUrl}'>#{brick.availability}</a>"

    for key, value of brick.compatibility
        assemblyCell += "<span class='rfc-#{value}'>#{key}</span>"

    if brick.inBin
        buttonCell += "onclick=\"Bricklayer.bin.removeBrick('#{brick.name}', this)\">remove"
    else
        buttonCell += "onclick=\"Bricklayer.bin.addBrick('#{brick.name}', this)\">add"

    # Add data to a new row with child and then draw the table
    rowNode = table.row.add([nameCell, typeCell, lengthCell, assemblyCell, reviewsCell, buttonCell])
                       .child(childRow).hide().draw(false).nodes().toJQuery()
    rowNode.on 'click', 'a.extend', (e) ->
                        tr      = $(e.currentTarget).closest('tr')
                        icon    = $(e.currentTarget).find ".resultIcon"
                        row     = table.row(tr)

                        if row.child.isShown()
                            row.child.hide()
                            tr.removeClass('shown')
                            icon.toggleClass("icon-right-open").toggleClass "icon-down-open"
                        else
                            row.child.show()
                            tr.addClass('shown')
                            icon.toggleClass("icon-right-open").toggleClass "icon-down-open"
