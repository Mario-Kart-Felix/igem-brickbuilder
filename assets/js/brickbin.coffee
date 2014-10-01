brickUrl = 'api/v1/brick/'

Bricklayer.BrickBin =
class BrickBin
    constructor: ->
        @bricks = new Array()
        @construct = new Array()

    addBrick: (brickName, link) ->
        if this.indexOf(brickName) != -1
            if(link != undefined)
                $('#toggle-bin-' + brickName).text("remove")
                $('#toggle-bin-' + brickName).on('click', ( ->
                    Bricklayer.bin.removeBrick(brickName, link)
                ))
            return

        $.ajax
            type: "GET"
            url: brickUrl + brickName
            success: (brick) =>

                mybrick = new Bricklayer.BioBrick brick
                mybrick.inBin = true
                @bricks.push mybrick

                this.save()

                if(link != undefined)
                    $('#toggle-bin-' + brickName).text("remove")
                    $('#toggle-bin-' + brickName).on('click', ( ->
                        Bricklayer.bin.removeBrick(brickName, link)
                    ))

                error: (error) ->
                    console.log error


    # addBrick: (brickName) =>
    #   addBrick(brickName, null)


    removeBrick: (brickName, link) =>
        index = this.indexOf(brickName)

        if index != -1
            @bricks.splice(index, 1)
            this.save()

        if(link != undefined)
            $('#toggle-bin-' + brickName).text("add")
            $('#toggle-bin-' + brickName).on('click', ( ->
                    Bricklayer.bin.addBrick(brickName, link)
                ))

    indexOf: (brick) ->
        index = -1

        for selBrick, i in @bricks
            if brick == selBrick.name
                index = i
                break

        return index


    save: ->
        partNames = ""

        for brick in @bricks
            partNames += brick.name + "|"

        $.cookie("storedBin", partNames, {expires: 10000})


    load: ->
        cookie = $.cookie("storedBin")

        if cookie == undefined
            return

        partNames = cookie.split "|"

        for part in partNames
            if part == ""
                continue

            this.addBrick(part)


Bricklayer.manualAdd = ->
    # Store part name
    partName = $('#brickName').val()

    # Check if already in bin
    $.ajax
            type: "GET"
            url: brickUrl + partName
            success: (brick) =>
                newBrick = new Bricklayer.BioBrick brick
                if Bricklayer.bin.indexOf(newBrick.name) == -1
                    # Add part
                    Bricklayer.bin.addBrick(newBrick.name)
                # Clear entry
                $('#brickName').val("")

                error:  (error) ->
                    console.log error
# Run at startup
Bricklayer.bin = new Bricklayer.BrickBin();
Bricklayer.bin.load()
