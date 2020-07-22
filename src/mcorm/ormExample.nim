#
#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
# 
#             mConnect ORM Example: model, DDL, client-request-object(json) and DML
#

import times, tables, json
import model
import crud

# Examples:

proc fullName*(): string =
    # params obtained from the model-instance-values (e.g. user.firstName)
    let 
        firstName = ""
        middleName = ""
        lastName = ""

    result = if middleName != "":
                firstName & " " & middleName & " " & lastName
            else:
                 firstName & " " & lastName

proc getCurrentDateTime*(): DateTime =
    result = now().utc

# Define model procedures
# var userMethods = initTable[string, proc(): auto]()
var userMethods: Table[string, proc(): string]
# userMethods["getCurrentDateTime"] = getCurrentDateTime
userMethods["fullName"] = fullName

proc UUIDDefault*(): string =
    result = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

proc UUIDValidate*(): bool = 
    result = true

proc UserModel(): ModelType =
    var appDb = Database()     # TBD
    var userModel = ModelType()

    let 
        modelName = "Users"
        tableName = "users"
        timeStamp = true
    
    # Table structure / model definitions
    var recordDesc = initTable[string, FieldDescType]()
    
    # Model recordDesc definition
    recordDesc["id"] = FieldDescType(
        fieldType: DataTypes.UUID,
        fieldLength: 255,
        fieldPattern: "![0-9]", # exclude digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        fieldFormat: "12.2", # => max 12 digits, including 2 digits after the decimal
        notNull: true,
        unique: true,
        indexable: true,
        primaryKey: true,
        foreignKey: true,
        defaultValue: proc(): string = "AAAAAAAAAA-BBB-CCCC",
        validate: UUIDValidate
        # minValue*: float
        # maxValue*: float
    )

    recordDesc["firstName"] = FieldDescType(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    # model methods/procs | initialize and/or define
    let methods = @[
        ProcedureType(
            procName: "fullName",
            fieldNames: @["firstName", "lastName", "middleName"],
            procReturnType: DataTypes.STRING
        ),
        ProcedureType(
            procName: "getCurrentDateTime",
            procReturnType: DataTypes.DATETIME
        )
    ]

    # extend / instantiate model
    result = newModel(
        modelName = "User",
        tableName = "users",
        recordDesc = recordDesc,
        timeStamp = true,
        actorStamp = true,
        activeStamp = true,
        relations = @[],
        methods = methods,
        appDb = appDb,
    )

var userMod = UserModel()
echo "user-model: ", userMod.repr, " \n\n"
var userTable = userMod.createTable()
echo "create-table-result: ", $userTable
