#
#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#                  CRUD Helper Procedures
# 

## CRUD helper procedures/functions for the CRUD operations
##
import strutils, times

import computeCreateTable, computeAlterTable, computeSyncTable
import computeSelect, computeWhere, computeCreate, computeUpdate, computeDelete

export computeCreateTable
export computeAlterTable
export computeSyncTable
export computeSelect
export computeWhere
export computeCreate
export computeUpdate
export computeDelete

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

## strToTime converts time from string to Time format
proc strToTime*(val: string): Time =
    try:
        result = fromUnix(val.parseInt)
    except:
        # return the current time
        return getTime()
