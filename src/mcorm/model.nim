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
proc getCurrentDateTime(rec: FieldTemp): DateTime =
    result = now().utc

proc userDefaults(rec: FieldTemp): string =
    result = "testing"
     
proc userValidation(rec: FieldTemp): bool =
    result = true

# Default fields: isActive, timestamp etc. | to be used when creating table with timeStamp set to true
# let 
#     createdByField = Field(fieldName: "createdby", fieldType: "string" )
#     createdAtField = Field(fieldName: "createdat", fieldType: "datetime")
#     updatedByField = Field(fieldName: "updatedby", fieldType: "string" )
#     updatedAtField = Field(fieldName: "updatedat", fieldType: "datetime")

type 
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    # captures client/user's inputs (from ui-form, RESTFUL-json-api, websocket, rpc etc.)
    UserValue* =  object
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
        fullName*: proc(user: UserValue): string 
    
    UserModel* = object
        userValue*: UserValue
        userModel*: Model

proc fullName(userModel: UserModel): string =
    let userRec = userModel.userValue
    result = if userRec.middleName != "":
                userRec.firstName & " " & userRec.middleName & " " & userRec.lastName
            else:
                 userRec.firstName & " " & userRec.lastName

proc User(): UserModel =
    result.userValue = UserValue()
    result.userModel = Model()

    result.userModel.modelName = "User"
    result.userModel.timeStamp = true
    
    # table structure / model definitions
    result.userModel.record = initTable[string, FieldDesc]()

    # define user-model field descriptions from the userValue type
    for name, _ in result.userValue.fieldPairs:
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
    result.userModel.defaultValues = @[]
    result.userModel.constraints = @[]
    result.userModel.methods = @[]

echo "user-model: " & User().repr
