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

proc defaults(rec: UserRecord): seq[Default] =
    result = @[]

proc methods(rec: UserRecord): seq[Method] =
    result = @[]

proc constraints(rec: UserRecord): seq[Constraints] =
    result = @[]
     
proc validations(rec: UserRecord): seq[Validation] =
    result = @[]

proc fullName(userRecord: UserRecord): string =
    let userRec = userRecord
    result = if userRec.middleName != "":
                userRec.firstName & " " & userRec.middleName & " " & userRec.lastName
            else:
                 userRec.firstName & " " & userRec.lastName

proc User(): UserModel =
    result.userRecord = UserRecord()
    result.userModel = Model()

    result.userModel.modelName = "User"
    result.userModel.timeStamp = true
    
    # table structure / model definitions
    result.userModel.record = initTable[string, FieldDesc]()

    # define user-model field descriptions from the userValue type
    for name, _ in result.userRecord.fieldPairs:
        echo "TBD (may not be suitable due to customised fieldDesc)"
        result.userModel.record[name] = FieldDesc(
            fieldLength: 255
        )

    result.userModel.record["id"] = FieldDesc(
        fieldType: "UUID",
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

    result.userModel.record["firstName"] = FieldDesc(
        fieldType: "string",
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    # model methods/procs | initialize and/or define
    result.userModel.defaults = defaults(result.userRecord)
    result.userModel.validations = validations(result.userRecord)
    result.userModel.constraints = constraints(result.userRecord)
    result.userModel.methods = methods(result.userRecord)

echo "user-model: " & User().repr
