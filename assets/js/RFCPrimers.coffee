# namespace
Bricklayer.RFCPrimers = {}

# ------------ Get Primer Functions -----------

Bricklayer.RFCPrimers.tenFp = 
tenFp = (sequence) ->

    # For coding sequences, use a different prefix than the norm.
    # Also, test to see whether the given sequence has a stop codon.
    # Recommmended that the stop codon is replaed with TAATAA

    if sequence.slice(0,3) == "ATG"
        l = sequence.length
        stopCodon = sequence.slice(l-3,l)
        if stopCodon == "TGA" || stopCodon == "TAG"
            fp = "GAATTCGCGGCCGCTTCTAG" + sequence.slice(0,l-3) + "TAATAA"
        else
            fp = "GAATTCGCGGCCGCTTCTAG" + sequence + "TAATAA"

    # The normal prefix

    else
        fp = "GAATTCGCGGCCGCTTCTAGAG" + sequence
    fp

Bricklayer.RFCPrimers.tenRp =
tenRp = (sequence) -> return "CTGCAGCGGCCGCTACTAGTA" + sequence

Bricklayer.RFCPrimers.twelveFp =
twelveFp = (sequence) -> return "GAATTCGCGGCCGCACTAGT" + sequence

Bricklayer.RFCPrimers.twelveRp =
twelveRp = (sequence) -> return "CTGCAGCGGCCGCGCTAGC" + sequence

Bricklayer.RFCPrimers.twentyOneFp =
twentyOneFp = (sequence) -> return null

Bricklayer.RFCPrimers.twentyOneRp =
twentyOneRp = (sequence) -> return null

Bricklayer.RFCPrimers.twentyThreeFp =
twentyThreeFp = (sequence) -> return "GAATTCGCGGCCGCTTCTAGA" + sequence

Bricklayer.RFCPrimers.twentyThreeRp =
twentyThreeRp = (sequence) -> return "CTGCAGCGGCCGCTACTAGT" + sequence

Bricklayer.RFCPrimers.twentyFiveFp =
twentyFiveFp = (sequence) -> return "GAATTCGCGGCCGCTTCTAGATGGCCGGC" + sequence

Bricklayer.RFCPrimers.twentyFiveRp =
twentyFiveRp = (sequence) -> return "CTGCAGCGGCCGCTACTAGTATTAACCGGT" + sequence