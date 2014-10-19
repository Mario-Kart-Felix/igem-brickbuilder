# Generates primers to link different parts (biobricks) together.
# It's pretty simple. Lets say we have three parts, and the user sorts them A-B-C. The app needs to make:
# 1) A regular forward primer for A (20+ bp, 55-60 degree Tm)

# 2) Primers to 'link' each part. In this case, A-B and B-C; so the app would take ~20bp from the end of part A (~55 degree Tm) and ~20bp from the beginning of part B (~55 degree Tm), and that would be one primer. In exactly the same way, it would take ~20bp from the end of part B and ~20bp from the beginning of part C.

# 3) Finally, a regular reverse primer for C (complementary, ~20bp, 55-60 degree Tm)

# So for example (using short parts for simplicity) say you're linking parts
# A = ACTTTG
# B = CTAGCC

# Then the primer is just
# Primer = TTGCTA  (Tm for TTG is 55 and for CTA is 55)

# In step (3), is it like this example (using short parts again):

# C = CCTAGAGATC
# Reverse = CTAGAGATCC
# ComplimentOfReverse = GATCTCTAGG
# Primer = GATCT

# namespace
Bricklayer.Primers = {}

reverse = (s) -> s.split("").reverse().join("")

# List of Forward Primers for RFC Methods 10, 12, 21, 23, 25
rfcTenFp = ""
rfcTenRp = "CTGCAGCGGCCGCTACTAGTA"

# Figures out the primer needed to combine two DNA parts
# The primer is a sequence that has the ending of partA and the beginning of partB.
# The first part of the primer (the head) is made from the end of the sequence from partA.
# the last part of the primer (the tail) is made from the beginning of the sequence from partB.
# Each part of the primer, the head and tail, needs to have a melting temperature in the range of 50-60 degrees celsius.
# The ideal temperature is the midpoint, so we want primers with a melting temperature of 55 degrees celsius.
# The melting temperature of the primer changes as you make the primer longer.

Bricklayer.Primers.getPrimer =
getPrimer = (part, minTemp=50, maxTemp=60) ->
    # Using RFC Method 10 for now...
    # Measure melting temperature starting from beginning of part
    # Then return forward primer appended with subsequence of part
    lengthOfPrimerPart = getLengthOfSubsequenceByTemp part, minTemp, maxTemp
    primerPart = part.substring(part.length - lengthOfPrimerPart)
    return rfcTenFp + primerPart

###
Bricklayer.Primers.getPrimerBetween =
getPrimerBetween = (partA, partB, minTemp=50, maxTemp=60) ->
    # The head of the primer is the ending of partA.
    # Start from the end of the partA and go backwards until the melting temperature is right.
    lengthOfPrimerHead = getLengthOfSubsequenceByTemp reverse(partA), minTemp, maxTemp
    lengthOfPrimerTail = getLengthOfSubsequenceByTemp partB, minTemp, maxTemp
    primerHead = partA.substring(partA.length - lengthOfPrimerHead)
    primerTail = partB.substring(0, lengthOfPrimerTail)
    return primerHead + primerTail
###

# Takes a sequence and returns the length of a subsequence, starting from the beginning,
# whose melting temperature is closest to the midpoint of the minimum and maximum given melting temperatures.
# I think this function needs a better name
getLengthOfSubsequenceByTemp = (sequence, minTemp, maxTemp) ->
    return -1 if minTemp > maxTemp
    sequence = sequence.toUpperCase()
    idealTemp = (minTemp + maxTemp) / 2
    lastDifference = null

    for _, i in sequence
        subsequence = sequence.substring(0, i+1)
        meltingTemp = getMeltingTemperature subsequence
        differenceFromIdeal = Math.abs(meltingTemp - idealTemp)
        # Realize that the difference will get smaller until you reach the ideal temperature. Then it will get bigger.
        # The previous length is the one with the ideal melting temperature for the given range.
        if lastDifference and differenceFromIdeal > lastDifference
            return subsequence.length - 1 # because we want the length of the previous subsequence, which is one less.
        else
            lastDifference = differenceFromIdeal
    # return the whole sequence if we run out of subsequences.
    # This will probably cause a bug. Should return -1 or an error like "The sequence is too short for PCR!"
    return sequence.length

# Takes a DNA sequence and counts the number of each nucleotide. Returns an hash of nucleotide: count
getNucleotideCounts = (sequence) ->
    sequence = sequence.toUpperCase()
    counts =
        'A': 0
        'T': 0
        'C': 0
        'G': 0
    for nucleotide, count in sequence
        counts[nucleotide]++
    counts

# returns the complement of the DNA sequence
# The complement of A is T (and vice-versa)
# The complement of G is C (and vice-versa)
getComplement = (sequence) ->
    sequence = sequence.toUpperCase()
    sequence = sequence.replace(/A/g,"X");
    sequence = sequence.replace(/T/g,"A");
    sequence = sequence.replace(/X/g,"T");
    sequence = sequence.replace(/G/g,"X");
    sequence = sequence.replace(/C/g,"G");
    sequence = sequence.replace(/X/g,"C");
    return sequence

# Returns the melting temperature (in Celsius) of a DNA sequence.
# This formula sometimes spits out negative if the sequence is too short. I dunno
# valid for 17 bp to 50bp
getMeltingTemperature = (sequence) ->
    sequence = sequence.toUpperCase()
    nucleotides = getNucleotideCounts sequence
    return (64.9 + (41 * (nucleotides.G + nucleotides.C - 16.4) / sequence.length))



Bricklayer.Primers.getPrimersForConstruct =
getPrimersForConstruct = (construct, minTemp, maxTemp) ->
    primers = []
    for sequence, i in construct
        if sequence != null

            # get forward primer
            length = getLengthOfSubsequenceByTemp sequence, minTemp, maxTemp
            checkForCoding(sequence)
            primers.push rfcTenFp + sequence.substring(0, length)

            # get reverse primer
            endingSequence = getComplement reverse(sequence)
            length = getLengthOfSubsequenceByTemp endingSequence, minTemp, maxTemp
            primers.push rfcTenRp + endingSequence.substring(0, length)

        # Push 2 null elems to fill for convenience
        else
            primers.push null
            primers.push null

    primers


# For RFC Method 10,
# Forward primers differ for coding and non-coding parts
# Mainly if sequence starts with ATG
checkForCoding = (sequence) ->
    if sequence.slice(0,3) == "ATG"
        rfcTenFp = "GAATTCGCGGCCGCTTCTAG"
    else
        rfcTenFp = "GAATTCGCGGCCGCTTCTAGAG"

Bricklayer.SequenceEntryView =
SequenceEntryView = new Bricklayer.AppendView '#sequenceEntries', '#templateSequenceEntry'

addSequence = (context) ->
    SequenceEntryView.render context

displayPrimers = (primers) ->
    console.log "Displaying primers..."

    # Getting rid of previous primers
    $('#displayPrimers').empty()
    $('#displayPrimers').append("<h3>Primers</h3><br>")

    for primer, i in primers
        if primer != null

            if i%2 == 0

                # Display Brick name
                $('#displayPrimers').append("#{Bricklayer.bin.construct[i/2].name}<br>")

                # Display forward primer
                $('#displayPrimers').append("fp: #{primer}<br>")

            else
                # Display reverse primer
                $('#displayPrimers').append("rp: #{primer}<br><br>")

# temporarily skip the home page and go to the generate page. this is a reason for routes
# Bricklayer.PrimerView.render()

# #######
# Example of Primer between two parts

# partA = 'ACTATCGTAGCTATATAGCTATATACGATCGATGCTAGCTAGCTAGCTAGCTAGCTATCGCTAGCTAGCATGCTAGCTAGCTAGCTATATATAGTTCGATGACTTTC'
# partB = 'CTAGCTACTAGCTAGCTAGTCGGCGCGTAGCTAGCTAGCTAGCTATATGCTACGAGCGATCGATCGTAGCTAGCTACGTAGCTGACTGATCGTAGCTAGCTAGCAT'

# console.log "Part A: #{partA}"
# console.log "Part B: #{partB}"
# console.log "Primer to link A and B: #{getPrimerBetween(partA, partB)}"
# #######

# #######
# Example of generating primers for construct
# construct = [
#     'ATCTGTATACTGTATGCTACTATATCGATGAATGCGCT',
#     'GGTCATCCGCTAGTCGATGTCAGTTAGATAGCACACGCTAA',
#     'AGTCAAGGACTAGCCATGAAACACAGAGTATACATGACATTAGGTA',
#     'AGTGTCACAGTGTCAGTGTAGTCGTGACACCCGGATA',
#     'ACGAGTGTGTAGCTGGGTCAGGATTTATACGGCTAAT',
#     'GGCACGGCCTATTAGCGCTACTACGACGACGACGGGCATCATCATTAACAGAATC'
# ]

# minTemp = 50
# maxTemp = 60

# console.log getPrimersForConstruct construct, minTemp, maxTemp
# #######

# --------------------------------------------------------------------------

focusedRef = "" # Brick ref. String corresponds to bricks from Brick Bin and number corresponds to bricks from Construct Bin.
focusedBrick = "" # Brick clicked in bin

Bricklayer.showInfo = (brickRef) ->
    focusedRef = brickRef
    if typeof brickRef == "string"
        focusedBrick = Bricklayer.bin.bricks[Bricklayer.bin.indexOf(brickRef)]
    else
        focusedBrick = Bricklayer.bin.construct[brickRef]

    $('#brick-name').text(focusedBrick.name)
    $('#brick-description').text(focusedBrick.description)

constructCount = 0

Bricklayer.addConstruct = ->
    if focusedBrick != "" && typeof focusedRef != "number"
        Bricklayer.bin.construct.push focusedBrick
        i = constructCount
        $('#constructBin select').append("<option id='construct-#{i}' onclick=Bricklayer.showInfo(#{i})>#{focusedBrick.name}</option>")
        constructCount++

Bricklayer.deleteConstruct = ->
    if typeof focusedRef == "number"
        $('#construct-' + focusedRef).remove()
        Bricklayer.bin.construct[focusedRef] = null

Bricklayer.deleteAll = ->
    Bricklayer.bin.construct = new Array()
    $('#constructBin select').empty()

Bricklayer.moveDown = ->
    lastElem = Bricklayer.bin.construct.length-1
    if typeof focusedRef == "number" && focusedRef != lastElem

        # Defining variables for clarity of parts
        for i in [focusedRef+1..Bricklayer.bin.construct.length] by 1
            if Bricklayer.bin.construct[i] != null
                indexBelow = i
                break
        partBelow = Bricklayer.bin.construct[indexBelow]

        # Since a copy of the focused part has already been made, assign new part to current selected index
        Bricklayer.bin.construct[focusedRef] = partBelow
        Bricklayer.bin.construct[indexBelow] = focusedBrick

        # Change name of option elems to its correspondent
        $('#construct-' + focusedRef).text("#{partBelow.name}")
        $('#construct-' + indexBelow).text("#{focusedBrick.name}")

        # Change selected element to index below, maintaining focus on previous selected part
        $('#construct-' + focusedRef).removeAttr("selected")
        $('#construct-' + indexBelow).attr("selected","")
        focusedRef = indexBelow

Bricklayer.moveUp = ->
    if typeof focusedRef == "number" && focusedRef != 0

        # Defining variables for clarity of part
        for i in [focusedRef-1..0] by -1
            if Bricklayer.bin.construct[i] != null
                indexAbove = i
                break
        partAbove = Bricklayer.bin.construct[indexAbove]

        # Since a copy of the focused part has already been made, assign new part to current selected index
        Bricklayer.bin.construct[indexAbove] = focusedBrick
        Bricklayer.bin.construct[focusedRef] = partAbove

        # Change name of option elems to its correspondent
        $('#construct-' + indexAbove).text("#{focusedBrick.name}")
        $('#construct-' + focusedRef).text("#{partAbove.name}")

        # Change selected element to index above, maintaining focus on previous selected part
        $('#construct-' + focusedRef).removeAttr("selected")
        $('#construct-' + indexAbove).attr("selected","")
        focusedRef = indexAbove

Bricklayer.primeItUp = ->
    readyForPrime = []
    for brick in Bricklayer.bin.construct
        if brick != null
            readyForPrime.push brick.sequence.toUpperCase()
        else
            readyForPrime.push null
    primers = getPrimersForConstruct readyForPrime, 55, 60
    displayPrimers primers

Bricklayer.rfcTen = (option) ->
    rfcTenFp = switch
        when option == "nonCoding" then rfcTenFp = "GAATTCGCGGCCGCTTCTAGAG"
        when option == "coding" then rfcTenFp = "GAATTCGCGGCCGCTTCTAG"