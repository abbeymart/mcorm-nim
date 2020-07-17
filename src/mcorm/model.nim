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
import ormtypes, times

# Examples:
proc getCurrentDateTime(rec: Field): DateTime =
    result = now().utc

proc userDefaults(rec: Field): string =
    result = "testing" 
proc userValidation(rec: Field): bool =
    result = true

# Default fields: isActive, timestamp etc. | to be used when creating table with timeStamp set to true
let 
    createdByField = Field(fieldName: "createdby", fieldType: "string" )
    createdAtField = Field(fieldName: "createdat", fieldType: "datetime")
    updatedByField = Field(fieldName: "updatedby", fieldType: "string" )
    updatedAtField = Field(fieldName: "updatedat", fieldType: "datetime")

type 
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    UserModel* =  object
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
        fullName*: proc(user: UserModel): string 

proc UserDesc(): ModelDesc =
    result.modelName = "User"
    result.fieldNames= @["id", "username", "firstName", "lastName"]
    result.fieldProps = @[
        Field(
            fieldName: "id",
            fieldType: "string",
            fieldLength: 64,
            notNull: true,
            primaryKey: true,
        ),
        Field(
            fieldName: "username",
            fieldType: "string",
            fieldLength: 64,
            notNull: true,
        ),
    ]

    result.timeStamp = true

proc fullName(user: UserModel): string =
    result = if user.middleName != "":
                user.firstName & " " & user.middleName & " " & user.lastName
            else:
                 user.firstName & " " & user.lastName




# var User: Model = Model(
#     modelName: "users",
#     fieldItems: @[
#         Field(
#             fieldName: "id",
#             fieldType: "uuid",
#             fieldLength: 64,
#             notNull: true,
#             primaryKey: true,
#         ),
#         Field(
#             fieldName: "username",
#             fieldType: "string",
#             fieldLength: 64,
#             notNull: true,
#         ),
#     ]
# )
# echo "user-model: " & User.repr