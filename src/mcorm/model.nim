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
import ormtypes, times, tables

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

proc getCurrentDateTime(): DateTime =
    result = now().utc

proc User(): Model =
    # result.userRecord = UserRecord()
    # result.userModel = Model()

    result.modelName = "User"
    result.timeStamp = true
    
    # table structure / model definitions
    result.recordDesc = initTable[string, FieldDesc]()
    result.fieldTypes = initTable[string, DataTypes]()

    # Model recordDesc definition
    result.recordDesc["id"] = FieldDesc(
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

    result.recordDesc["firstName"] = FieldDesc(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    # model recordDesc-field-fieldTypes definition
    result.fieldTypes["id"] = DataTypes.UUID
    result.fieldTypes["username"] = DataTypes.STRING
    result.fieldTypes["email"] = DataTypes.STRING
    result.fieldTypes["recoveryEmail"] = DataTypes.STRING
    result.fieldTypes["firstName"] = DataTypes.STRING
    result.fieldTypes["middleName"] = DataTypes.STRING
    result.fieldTypes["lastName"] = DataTypes.STRING
    result.fieldTypes["profile"] = DataTypes.JSON
    result.fieldTypes["lang"] = DataTypes.STRING
    result.fieldTypes["desc"] = DataTypes.STRING
    result.fieldTypes["isActive"] = DataTypes.BOOL

    # model methods/procs | initialize and/or define
    # result.defaults = defaults(result)
    # result.validations = validations(result)
    # result.constraints = constraints(result)
    # result.methods = methods(result)

echo "user-model: " & User().repr


proc defaults(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc methods(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc constraints(rec: Model): seq[ProcedureTypes] =
    result = @[]
     
proc validations(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc fullName(rec: UserRecord): string =
    let userRec = rec
    result = if userRec.middleName != "":
                userRec.firstName & " " & userRec.middleName & " " & userRec.lastName
            else:
                 userRec.firstName & " " & userRec.lastName



let rec = User()

let 
    defValues = defaults(rec)
    met = methods(rec)
    constr = constraints(rec)
    validate = validations(rec)

