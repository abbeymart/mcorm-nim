import json
import ormtypes
import ormExample
import tables

# JSON request object
var jsonText = """
    {
    "id": "aaaaaaaaaaaaaaaaaaaaaaa-bbbbbbb-cccccccccccccc",
    "username": "abbeymart",
    "email": "abc@abc.com",
    "firstName": "Abi",
    "lastName": "Akindele",
    "isActive": true,
    "lang": "en-US",
    "profile": {"isAdmin": true, "group": "admin", "groups": ["admin", "guest"], "lang": "en-US", "dob": "2020-01-10" }
    }
"""
# data coming from the client in json-format
var jNode: JsonNode = parseJson(jsonText)

type 
    Profile* = object
        isAdmin*: bool
        group*: string
        groups*: seq[string]
        lang*: string
        dob*: string

    # captures client/user's inputs (from ui-form, RESTFUL-json-api, websocket, rpc etc.)
    UserRecord* =  object
        id*: string
        username*: string
        email*: string
        # recoveryEmail*: string
        firstName*: string
        # middleName*: string
        lastName*: string
        profile*: Profile
        lang*: string
        # desc*: string
        isActive*: bool
        # fullName*: proc(user: UserRecord): string 

# let JNode = %*(
#     UserRecord(
#     id: "aaaaaaaaaaaaaaaaaaaaaaa-bbbbbbb-cccccccccccccc",
#     username: "abbeymart",
#     email: "abc@abc.com",
#     firstName: "Abi",
#     lastName: "Akindele",
#     isActive: true,
#     lang: "en-US",
#     profile: Profile(isAdmin: true, group: "admin", groups: ["admin", "guest"], lang: "en-US", dob: DateTime(year: 2020, month: 01))
#     )
# )

var jsonToObj = to(jNode, UserRecord)

echo "json-to-object: ", jsonToObj

echo "user-name: ", jsonToObj.username
echo "profile: ", jsonToObj.profile

# Convert jsonToObj to QuerySaveParamType | QueryReadParamType | QueryDeleteParamType

var 
    saveFields: seq[SaveFieldType] = @[]
    saveWhere: seq[WhereParamType] = @[]

#  compose CRUD meta-data by types
for name, val in jsonToObj.fieldPairs:
    var valType = typed(val)
    when valType is string:
        saveFields.add(
            SaveFieldType(
                fieldName: name,
                fieldValue: val,
                fieldType: DataTypes.STRING
                )    
            )
    when valType is bool:
        proc boolVal(): string =
            if val == true:
                "true"
            else:
                "false"
         
        saveFields.add(
            SaveFieldType(
                fieldName: name,
                fieldValue: boolVal(),
                fieldType: DataTypes.BOOL
                )    
            )
    when valType is Profile:
        saveFields.add(
            SaveFieldType(
                fieldName: name,
                fieldValue: getStr(%*(val)),
                fieldType: DataTypes.JSON
                )    
            )


    # QueryReadParamType* = object
    #     tableName*: string
    #     fields*: seq[ReadFieldType]
    #     where*: seq[WhereParamType]

    # QuerySaveParamType* = object
    #     tableName*: string
    #     fields*: seq[SaveFieldType]
    #     where*: seq[WhereParamType]

    # QueryUpdateParamType* = object
    #     tableName*: string
    #     fields*: seq[UpdateFieldType]
    #     where*: seq[WhereParamType]

    # QueryDeleteParamType* = object
    #     tableName*: string
    #     fields*: seq[DeleteFieldType]
    #     where*: seq[WhereParamType]