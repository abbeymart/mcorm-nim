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
    # auto-inject fieldName (args/params) from model-instance values
    let 
        firstName = ""
        middleName = ""
        lastName = ""

    result = if middleName != "":
                firstName & " " & middleName & " " & lastName
            else:
                 firstName & " " & lastName

proc getCurrentDateTime*(): string =
    result = (now().utc).getDateStr

# Define model procedures
# var userMethods: Table[string, proc(): string]
# userMethods["getCurrentDateTime"] = getCurrentDateTime
# userMethods["fullName"] = fullName

proc uuidDefault*(): string =
    result = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"

proc uuidValidate*(): bool = 
    result = true

proc hashPassword*(): string = 
    result = "HASHED-PASSWORD"

# Placeholder for Group mode (table: groups)
proc GroupModel(): ModelType =
    return nil

proc UserModel*(): ModelType =
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
        defaultValue: uuidDefault,
        validate: uuidValidate
        # minValue*: float
        # maxValue*: float
    )

    recordDesc["firstName"] = FieldDescType(
        fieldType: DataTypes.STRING,
        fieldLength: 255,           # default length for STRING (255)
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    recordDesc["lastName"] = FieldDescType(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    recordDesc["username"] = FieldDescType(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
    )

    recordDesc["password"] = FieldDescType(
        fieldType: DataTypes.STRING,
        fieldLength: 255,
        fieldPattern: "[a-zA-Z]",
        fieldFormat: "XXXXXXXXXX",
        notNull: true,
        setValue: hashPassword
    )

    recordDesc["isActive"] = FieldDescType(
        fieldType: DataTypes.BOOLEAN,
        notNull: true,
        defaultValue: proc(): string = "true"
    )

    recordDesc["desc"] = FieldDescType(
        fieldType: DataTypes.TEXT,
        fieldPattern: "[a-zA-Z0-9_-*|]",
        notNull: false,
    )

    # relations
    var modelRelations: seq[RelationType] = @[]
    
    modelRelations.add(RelationType(
        relationType: RelationTypeTypes.ONE_TO_MANY,
        targetField: "id",      # default: primary key/"id" field, it could be another unique key
        targetModel: GroupModel(),  # returns ModelType for groups table
        targetTable: "groups",
        foreignKey: "userId",   # default: sourceModel<sourceField>, e.g. userId
        relationTable: "",      # optional tableName for many-to-many | default: sourceTable_targetTable
        onDelete: RelationOptionTypes.SET_NULL,
        onUpdate: RelationOptionTypes.CASCADE,
    ))

    # model methods/procs
    let methods = @[
        ProcedureType(
            procName: fullName,
            procParams: @["firstName", "lastName", "middleName"],
            procReturnType: DataTypes.STRING
        ),
        ProcedureType(
            procName: getCurrentDateTime,
            procReturnType: DataTypes.DATETIME
        )
    ]

    # extend/instantiate the user-model, using newModel constructor proc
    result = newModel(
        modelName = "User",
        tableName = "users",
        recordDesc = recordDesc,
        timeStamp = true,       # default: true | auto-add: createdAt and updatedAt
        actorStamp = true,      # default: true | auto-add: createdBy(uuid/string) and updatedBy(uuid/string)
        activeStamp = true,     # default: true | auto-add: isActive(bool, default: true)
        relations = modelRelations,
        methods = methods,
        appDb = Database(),     # TBD
    )

# create an instance of the UserModel
var userMod = UserModel()
echo "user-model: ", userMod.repr, " \n\n"
var userTable = userMod.createTable()
echo "create-table-result: ", $userTable
