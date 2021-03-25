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
import mcresponse, mctypes

## Model constructor: for table structure definition
## 
proc newModel*(model: ModelType; options: ModelOptionsType): ModelType =
    result.appDb = model.appDb
    result.modelName = model.modelName
    result.tableName = model.tableName
    result.recordDesc = model.recordDesc
    result.timeStamp = model.timeStamp or options.timeStamp
    result.actorStamp = model.actorStamp or options.actorStamp
    result.activeStamp = model.activeStamp or options.activeStamp
    result.relations = model.relations
    result.alterSyncTable = model.alterSyncTable
    result.computedProcedures = model.computedProcedures
    result.validateProcedures = model.validateProcedures

## Model instance methods
## 
proc getParentRelations*(model: ModelType;): seq[ModelRelationType] = 
    result = @[]

proc getChildRelations*(model: ModelType;): seq[ModelRelationType] = 
    result = @[]

proc getParentTables*(model: ModelType;): seq[string] = 
    result = @[]

proc getChildTables*(model: ModelType;): seq[string] = 
    result = @[]

proc computeDocValueType*(model: ModelType; docValue: RecordValueType): ValueToDataType =
    result = ValueToDataType()

proc updateDefaultValues*(model: ModelType; docValue: RecordValueType): RecordValueType =
    result = RecordValueType()

proc validateDocValue*(model: ModelType; docValue: RecordValueType; taskName: string): ValidateResponseType =
    result = ValidateResponseType()

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

proc save*(model: ModelType; params: CrudParamsType; options: CrudOptionsType): ResponseMessage =
    result = getResMessage("success", ResponseMessage())

proc get*(model: ModelType; params: CrudParamsType; options: CrudOptionsType): ResponseMessage =
    result = getResMessage("success", ResponseMessage())

proc gets*(model: ModelType; params: CrudParamsType; options: CrudOptionsType): ResponseMessage =
    result = getResMessage("success", ResponseMessage())

proc delete*(model: ModelType; params: CrudParamsType; options: CrudOptionsType): ResponseMessage =
    result = getResMessage("success", ResponseMessage())
