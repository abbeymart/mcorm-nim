#
#              mconnect solutions
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
        partOf*: string
        partOfField*: seq[string]
        contains*: string

    FieldDefinition* = ref object
        fieldName*: string
        fieldType*: string
        fieldLength*: uint
        fieldPatern*: string
        fieldFormat*: string
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
    