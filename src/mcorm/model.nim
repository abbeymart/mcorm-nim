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
import times

# Define types
type
    Relation* = object
        relationType*: string   # one-to-one, one-to-many, many-to-many
        foreignTable*: string
        foreignFields*: seq[string]

    UUID* = string

    TimeStamp* = object
        createBy: string
        createdAt: DateTime
        updatedBy: string
        updatedAt: DateTime

    Field* = ref object
        fieldName*: string
        fieldType*: typedesc
        fieldLength*: uint
        fieldPatern*: string # "![0-9]" => excluding digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        fieldFormat*: string # "12.2" => max 12 digits, including 2 digits after the decimal
        notNull*: bool
        unique*: bool
        indexable*: bool
        primaryKey*: bool
        foreignKey*: Relation
        fieldDefaultValue*: proc(rec: Field): string | int | float | bool
        fieldMinValue*: float
        fieldMaxValue*: float

    Function* = object
        funcName*: string
    
    Model* = ref object
        modelName*: string
        partOf*: string     # e.g. employee is part of a department
        partsOf*: string     # e.g. employee is part of more than one department
        partOfField*: seq[string]
        contains*: string # e.g. department may contains employees
        fieldItems*: seq[Field]
        timeStamp*: bool

    # Examples:
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    UserModel* = object
        username*: string
        email*: string
        recovery_email*: string
        firstname*: string
        middlename*: string
        lastname*: string
        profile*: Profile
        lang*: string
        desc*: string
        isActive*: bool


# Examples:
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

