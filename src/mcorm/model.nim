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
    
    UserModel* = object
        userRecord*: UserRecord
        userModel*: Model

proc getCurrentDateTime(): DateTime =
    result = now().utc

proc defaults(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc methods(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc constraints(rec: Model): seq[ProcedureTypes] =
    result = @[]
     
proc validations(rec: Model): seq[ProcedureTypes] =
    result = @[]

proc fullName(userRecord: UserRecord): string =
    let userRec = userRecord
    result = if userRec.middleName != "":
                userRec.firstName & " " & userRec.middleName & " " & userRec.lastName
            else:
                 userRec.firstName & " " & userRec.lastName

proc User(): Model =
    # result.userRecord = UserRecord()
    # result.userModel = Model()

    result.modelName = "User"
    result.timeStamp = true
    
    # table structure / model definitions
    result.record = initTable[string, FieldDesc]()
    result.value = initTable[string, DataTypes]()

    result.record["id"] = FieldDesc(
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

    result.record["firstName"] = FieldDesc(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    # model methods/procs | initialize and/or define
    result.defaults = defaults(result)
    result.validations = validations(result)
    result.constraints = constraints(result)
    result.methods = methods(result)

echo "user-model: " & User().repr
