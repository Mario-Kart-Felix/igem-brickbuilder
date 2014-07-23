# Declare a Bricklayer object for scripts to attach things to.
root = this
Bricklayer = root.Bricklayer = {}

###
# Construct a view with:
# * `selector`: the selector for the element to insert rendered templates into
# * `template`: the id of the script tag containing the template to manage
###
Bricklayer.View =
class View
    constructor: (@selector, @template) ->

    # `context` is an object that defines the variables in the handlebars template
    render: (context) ->
        raw = $(@template).html()
        compiled = Handlebars.compile raw
        $(@selector).html compiled context
        @afterRender()

    afterRender: -> # called after rendering is complete

Bricklayer.AppendView =
class AppendView extends View
    render: (context) ->
        raw = $(@template).html()
        compiled = Handlebars.compile raw
        $(@selector).append compiled context
        @afterRender()

Bricklayer.HeaderView =
HeaderView = new View '.header', '#templateUserHeader'

Bricklayer.HomeView =
HomeView = new View '.content', '#templateSearchFields'

Bricklayer.ResultsView =
ResultsView = new View '.content', '#templateSearchResults'

Bricklayer.BinView =
BinView = new View '.content', '#templateBrickBin'

Bricklayer.PrimerView =
PrimerView = new View '.content', '#templatePrimers'

HeaderView.render {}
