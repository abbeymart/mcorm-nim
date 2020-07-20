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
import ormtypes, times, tables, mcresponse, mcdb
import crud

## Model constructor: for table structure definition
## 
proc newModel(appDb: Database;
        modelName: string;
        tableName: string;
        recordDesc: RecordDescType;
        timeStamp: bool;
        relations: seq[RelationType];
        defaults: seq[DefaultValueType];
        validations: seq[ValidateType];
        methods: seq[MethodType]): ModelType =
    result.appDb = appDb
    result.modelName = modelName
    result.tableName = tableName
    result.recordDesc = recordDesc
    result.timeStamp = timeStamp
    result.relations = relations
    result.defaults = defaults
    result.validations = validations
    result.methods = methods

# CRUD constructor : imported

## Model methods
## 
## createTable method for creating, altering, sync data (if exist)...
## 
proc createTable(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

# => part of the CRUD methods
## getRecords: read all records with or without condition(s), with skip and limit props
## Mainly for lookup tables, which require no access / permission => consolidate with getRecord(?)
## 
proc getRecords(crud: CrudParamType): void = 
    echo "get records"

## getRecord: read records read all records with or without condition(s), with skip and limit props
## Require access / permission
proc getRecord(crud: CrudParamType): void = 
    echo "get record(s)"

## saveRecord: create or update record(s) by access / permission (roles)
## 
proc saveRecord(crud: CrudParamType): void = 
    echo "save record(s)"

## deleteRecord
proc deleteRecord(crud: CrudParamType): void = 
    echo "delete record"


# Examples:
type 
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    # captures client/user's inputs (from ui-form, RESTFUL-json-api, websocket, rpc etc.)
    UserRecord* =  object
        id*: string
        username*: string
        email*: string
        recoveryEmail*: string
        firstName*: string
        middleName*: string
        lastName*: string
        profile*: Profile
        lang*: string
        desc*: string
        isActive*: bool
        fullName*: proc(user: UserRecord): string 
    
    # UserModel* = object
    #     userRecord*: UserRecord
    #     userModel*: Model


proc methods(rec: ModelType): seq[ProcedureTypes] =
    result = @[]

proc fullName(firstName, lastName: string; middleName = ""): string =
    result = if middleName != "":
                firstName & " " & middleName & " " & lastName
            else:
                 firstName & " " & lastName

proc getCurrentDateTime(): DateTime =
    result = now().utc

# Define model procedures
var userMethods = initTable[string, proc]()
userMethods["getCurrentDateTime"] = getCurrentDateTime
userMethods["fullName"] = fullName


proc UserModel(): ModelType =
    echo "test model"
    var appDb = Database()     # TBD
    var userModel = ModelType()

    let 
        modelName = "Users"
        tableName = "users"
        timeStamp = true
    
    # Table structure / model definitions
    var recordDesc = initTable[string, FieldDescType]()
    
    # Model recordDesc definition
    recordDesc["id"] = FieldDesc(
        fieldType: DataTypes.UUID,
        fieldLength: 255,
        fieldPattern: "![0-9]", # exclude digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        fieldFormat: "12.2", # => max 12 digits, including 2 digits after the decimal
        notNull: true,
        unique: true,
        indexable: true,
        primaryKey: true,
        foreignKey: true,
        # fieldMinValue*: float
        # fieldMaxValue*: float
    )

    recordDesc["firstName"] = FieldDesc(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    userModel = ModelType(
        modelName: modelName,
        tableName: tableName,
        recordDesc: recordDesc,
        timeStamp: timeStamp,
        relations: @[],
        defaults: @[],
        validations: @[],
        constraints: @[],
        methods: @[],
        appDb: appDb,
    )n

    # model methods/procs | initialize and/or define
    let methods = @[
        ProcedureType(
            procName: "fullName",
            fieldNames: @["firstName", "lastName", "middleName"],
            procReturnType: DataTypes.STRING
        ),
        ProcedureType(
            procName: "getCurrentDateTime",
            procReturnType: DateTime
        )
    ]

    # extend / instantiate model
    result = newModel(
        modelName = modelName,
        tableName = tableName,
        recordDesc = recordDesc,
        timeStamp = timeStamp,
        relations = @[],
        methods = methods,
        appDb = appDb,
    )

echo "user-model: " & UserModel().repr
