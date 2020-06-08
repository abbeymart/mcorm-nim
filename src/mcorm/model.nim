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
##

# types
import times

# Define types
type
    ModelDefinition* = ref object
        modelName*: string
        partOf*: string     # e.g. employee is part of a department
        partsOf*: string     # e.g. employee is part of more than one department
        partOfField*: seq[string]
        contains*: string # e.g. department may contains employees

    FieldDefinition* = ref object
        fieldName*: string
        fieldType*: string
        fieldLength*: uint
        fieldPatern*: string # "![0-9]" => excluding digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        fieldFormat*: string # "12.2" => max 12 digits, including 2 digits after the decimal
        notNull*: bool
        unique*: bool
        indexable*: bool
        primaryKey*: bool
        fieldDefaultValue*: proc(user: FieldDefinition): typedesc
        fieldMinValue*: float
        fieldMaxValue*: float

    # Example:
    Profile* = object
        isAdmin*: bool
        defaultGroup*: string
        defaultLanguage*: string
        dob*: DateTime

    User* = object
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
    