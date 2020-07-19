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

# Model constructor: 
proc newModel(appDb: Database;
        modelName: string;
        tableName: string;
        recordDesc: RecordDescType;
        timeStamp: bool;
        relations: seq[RelationType];
        defaults: seq[ProcedureTypes];
        validations: seq[ProcedureTypes];
        constraints: seq[ProcedureTypes];
        methods: seq[ProcedureTypes]): ModelType =
    result.appDb = appDb
    result.modelName = modelName
    result.tableName = tableName
    result.recordDesc = recordDesc
    result.timeStamp = timeStamp
    result.relations = relations
    result.defaults = defaults
    result.validations = validations
    result.constraints = constraints
    result.methods = methods

# CRUD constructor : imported

# Model methods
proc createTable(model: ModelType): ResponseMessage = 
    result = getResMessage("success", ResponseMessage())

proc getRecords(crud: CrudParamType): void = 
    echo "get all records"

proc getRecord(crud: CrudParamType): void = 
    echo "get all record"

proc saveRecord(crud: CrudParamType): void = 
    echo "get all record"

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


proc defaults(rec: ModelType): seq[ProcedureTypes] =
    result = @[]

proc methods(rec: ModelType): seq[ProcedureTypes] =
    result = @[]

proc constraints(rec: ModelType): seq[ProcedureTypes] =
    result = @[]
     
proc validations(rec: ModelType): seq[ProcedureTypes] =
    result = @[]

proc fullName(rec: UserRecord): string =
    let userRec = rec
    result = if userRec.middleName != "":
                userRec.firstName & " " & userRec.middleName & " " & userRec.lastName
            else:
                 userRec.firstName & " " & userRec.lastName

proc getCurrentDateTime(): DateTime =
    result = now().utc


proc UserModel(): ModelType =
    echo "test model"
    var appDb = Database()     # TBD
    var userModel = ModelType()

    let 
        modelName = "Users"
        tableName = "users"
        timeStamp = true
    
    # Table structure / model definitions
    var recordDesc = initTable[string, FieldDesc]()
    
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
    )

    # model methods/procs | initialize and/or define
    let 
        defaults = defaults(userModel)
        validations = validations(userModel)
        constraints = constraints(userModel)
        methods = methods(userModel)

    # extend / instantiate model
    result = newModel(
        modelName = modelName,
        tableName = tableName,
        recordDesc = recordDesc,
        timeStamp = timeStamp,
        relations = @[],
        defaults = defaults,
        validations = validations,
        constraints = constraints,
        methods = methods,
        appDb = appDb,
    )

echo "user-model: " & UserModel().repr
