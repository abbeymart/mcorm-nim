#
#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Model Definition Types
#

## mConnect Model Definition Types:
## 

# types
import tables
import ormtypes, mcresponse, mcdb, helpers/helper
import crud

## Model constructor: for table structure definition
## 
proc newModel*(appDb: Database;
        modelName: string;
        tableName: string;
        recordDesc: RecordDescType;
        relations: seq[RelationType] = @[];
        timeStamp: bool = true;
        actorStamp: bool = true;
        activeStamp: bool = true;       
        methods: seq[ProcedureType] = @[]): ModelType =
    result.appDb = appDb
    result.modelName = modelName
    result.tableName = tableName
    result.recordDesc = recordDesc
    result.timeStamp = timeStamp
    result.actorStamp = actorStamp
    result.activeStamp = activeStamp
    result.relations = relations
    result.methods = methods

## Model methods
## modelTable method for creating, altering, sync data (if exist)...
## 
proc createTable*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

# => part of the CRUD methods
## getRecords: read all records with or without condition(s), with skip and limit props
## Mainly for lookup tables, which require no access / permission => consolidate with getRecord(?)
## 
proc getRecords*(crud: CrudParamType): void = 
    echo "get records"

## getRecord: read records read all records with or without condition(s), with skip and limit props
## Require access / permission
proc getRecord*(crud: CrudParamType): void = 
    echo "get record(s)"

## saveRecord: create or update record(s) by access / permission (roles)
## 
proc saveRecord*(crud: CrudParamType): void = 
    echo "save record(s)"

## deleteRecord
proc deleteRecord*(crud: CrudParamType): void = 
    echo "delete record"
