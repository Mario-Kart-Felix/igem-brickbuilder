class RFCAssemblyMethod
    constructor: (@incompatibleSequences) ->

    isCompatible: (sqnc) ->
        sqnc = sqnc.toUpperCase()
        for incompatibleSequence in @incompatibleSequences
            if sqnc.search(incompatibleSequence) != -1
                return false
        return true

# RFC Checkers should be attached to RFCService. Nuttin else or the monkeys will come hurt you
Bricklayer.RFCService = {}
Bricklayer.RFCs = RFCs = ['10', '12', '21', '23', '25']

Bricklayer.RFCService[RFCs[0]] =
RFC10 = new RFCAssemblyMethod ['GAATTC','TCTAGA','ACTAGT','CTGCAG','GCGGCCGC']

Bricklayer.RFCService[RFCs[1]] =
RFC12 = new RFCAssemblyMethod ['GAATTC','ACTAGT','GCTAGC','CTGCAG','GCGGCCGC']

Bricklayer.RFCService[RFCs[2]] =
RFC21 = new RFCAssemblyMethod ['GAATTC', 'AGATCT', 'GGATCC', 'CTCGAG']

Bricklayer.RFCService[RFCs[3]] =
RFC23 = new RFCAssemblyMethod ['GAATTC','TCTAGA','ACTAGT','CTGCAG','GCGGCCGC']

Bricklayer.RFCService[RFCs[4]] =
RFC25 = new RFCAssemblyMethod ['GAATTC','TCTAGA','ACTAGT','CTGCAG','GCGGCCGC','ACCGGT','GCCGGC']

