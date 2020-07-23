#
#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect Model Definition and DDL Operations
#

## mConnect Model Definition: constructor/procedure for defining new model
## DDL Operations: create/alter/drop table/index/view..., sync data...

# types
# import tables
import mcresponse, mcdb
import ../ormtypes

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
        alterTable: bool = true;       
        methods: seq[ProcedureType] = @[]): ModelType =
    result.appDb = appDb
    result.modelName = modelName
    result.tableName = tableName
    result.recordDesc = recordDesc
    result.timeStamp = timeStamp
    result.actorStamp = actorStamp
    result.activeStamp = activeStamp
    result.relations = relations
    result.alterTable = alterTable
    result.methods = methods

## Model DDL methods
## modelTable methods/procs to create/alter/drop table/index/view..., sync data...
## 
proc createTable*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc alterTable*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc dropTable*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc createIndex*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc dropIndex*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc alterIndex*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc createView*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc alterView*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc dropView*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc syncData*(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())
