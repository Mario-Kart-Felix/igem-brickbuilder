// Author: Matt Kruse <matt@mattkruse.com>
// WWW: http://www.mattkruse.com/

// -------------------------------------------------------------------
// hasOptions(obj)
//  Utility function to determine if a select object has an options array
// -------------------------------------------------------------------
hasOptions = (obj) ->
    if obj != null && obj.options != null
        return true
    return false

// -------------------------------------------------------------------
// selectUnselectMatchingOptions(select_object,regex,select/unselect,true/false)
//  This is a general function used by the select functions below, to
//  avoid code duplication
// -------------------------------------------------------------------
