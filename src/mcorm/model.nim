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

var User: Model = Model(
    modelName: "users",
    fieldItems: @[
        Field(
            fieldName: "id",
            fieldType: "uuid",
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
    ],
)
echo "user-model: " & User.repr



# proc User(): Model =
#     echo "user model"
#     result.modelName = "users"

#     result.fieldItems = @[
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

#     result.timeStamp = true

