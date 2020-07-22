import json

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
