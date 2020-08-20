# Utility functions / procs

import times, strutils

## strToBool procedure converts a string parameter to a boolean
proc strToBool*(val: string): bool =
    try:
        let strVal = val.toLower
        if strVal == "true" or strVal == "t" or strVal == "yes" or strVal == "y":
            return true
        elif val.parseInt > 0:
            return true
        else:
            return false 
    except:
        return false

## strToSeq procedure converts a stringified array to seq[string]
proc strToSeq*(val: string): seq[string] =
    try:
        var seqRes: seq[string] = @[]
        let strVal = val.split(",")
        for item in strVal:
            seqRes.add(item)
        return seqRes
    except:
        return @[]    

## strToTime converts time from string to Time format
proc strToTime*(val: string): Time =
    try:
        result = fromUnix(val.parseInt)
    except:
        # return the current time
        return getTime()
