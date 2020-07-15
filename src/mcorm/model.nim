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
import times, ormtypes

# Examples:

# Default fields: isActive, timestamp etc. | to be used when creating table with timeStamp set to true
let 
    createdByField = Field(fieldName: "createdby", fieldType: CreatedBy )
    createdAtField = Field(fieldName: "createdat", fieldType: CreatedAt, fieldDefaultValue: now().utc )
    updatedByField = Field(fieldName: "updatedby", fieldType: UpdatedBy )
    updatedAtField = Field(fieldName: "updatedat", fieldType: CreatedAt, fieldDefaultValue: now().utc )

var User = Model(
    modelName: "users",
    fieldItems: @[
        Field(
            fieldName: "id",
            fieldType: UUID,
            fieldLength: 64,
            notNull: true,
            primaryKey: true,
        ),
        Field(
            fieldName: "username",
            fieldType: string,
            fieldLength: 64,
            notNull: true,
        ),
    ]
)

echo "user-model: " & User.repr
