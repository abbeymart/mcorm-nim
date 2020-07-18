#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#       See the file "LICENSE.md", included in this
#    distribution, for details a bout the copyright / license.
# 
#                   ORM Package Types

## ORM types | centralised and exported types for all ORM operations:
## SQL-DDL (CREATE...), SQL-CRUD (INSERT, SELECT, UPDATE, DELETE...) operations
## 
import json, db_postgres, tables, times
import mcdb, mctranslog

# Define crud types
type
    DataTypes* = enum
        STRING,
        POSITIVE,
        INT,
        FLOAT,
        BOOLEAN,
        JSON,
        BIGINT,
        BIGFLOAT,
        OBJECT,     # Table/Map: key-value pairs
        ENUM,       # Enumerations
        SET,        # unique values
        ARRAY,
        PROC,
        UNARYPROC,
        BIPROC,
        PREDICATEPROC,
        BIPREDICATEPROC,
        SUPPLYPROC,
        BISUPPLYPROC,
        CONSUMERPROC,
        BICONSUMERPROC,
        COMPARATORPROC,

    Op* = enum
        AND,
        OR,
        NE,
        EQ,
        GT,
        GTE,
        LE,
        LTE,
        IN,
        NOTIN,
        BETWEEN,
        NOTBETWEEN,
        INCLUDE,
        LIKE,
        NOTLIKE,
        STARTSWITH,
        ENDSWITH,
        ILIKE,
        NOTILIKE,
        REGEX,
        NOTREGEX,
        IREGEX,
        NOTIREGEX,
        ANY,
        ALL,

    Order* = enum
        ASC,
        DESC,

    UUID* = string

    ValueType* = int | string | float | bool | Positive | JsonNode | BiggestInt | BiggestFloat | Table | Database

    FieldValueType* = int | string | float | bool | Positive | JsonNode | BiggestInt | BiggestFloat

    CreatedBy* = UUID
    UpdatedBy* = UUID
    CreatedAt* = DateTime
    UpdatedAt* = DateTime

    TimeStamp* = object
        createdBy*: CreatedBy
        createdAt*: CreatedAt
        updatedBy*: UpdatedBy
        updatedAt*: UpdatedAt
    
    DefaultProc*[T, R] = proc(val: T): R {.closure.}
    MethodProc*[T, R] = proc(rec: T): R {.closure.}
    ValidationProc*[T] = proc(rec: T): bool {.closure.}
    ConstraintProc*[T] = proc(rec: T): bool {.closure.}
    SupplierProc*[R] = proc(): R {.closure.}
    # proc(val: Record): FieldValueType
    # proc(val: Record): bool

    Default* = object
        fieldName*: string
        fieldType*: DataTypes
        fieldValue*: string  # stringified field value to be casted into fieldType

    Method* = object
        methodName*: string
        valueType*: DataTypes  # return type
        value*: string  # stringified field value to be casted into fieldType

    Validation* = object
        fieldName*: string
        fieldValid*: bool
    
    Constraint* = object
        fieldName*: string
        fieldOp*: string
        fieldValue*: bool

    Constraints* = object
        constraintGroup*: string
        constraintOp*: string
        constraintOrder*: int
        constraintItems*: seq[Constraint]

    FieldDesc* = object
        fieldType*: DataTypes
        fieldLength*: Positive
        fieldPattern*: string # "![0-9]" => excluding digit 0 to 9 | "![_, -, \, /, *, |, ]" => exclude the charaters
        fieldFormat*: string # "12.2" => max 12 digits, including 2 digits after the decimal
        notNull*: bool
        unique*: bool
        indexable*: bool
        primaryKey*: bool
        foreignKey*: bool
        fieldMinValue*: float
        fieldMaxValue*: float
        fieldDefaultValue*: Default     # TODO: stringified field value to be casted into fieldType
        
    Record* = Table[string, FieldDesc ]

    Relation* = ref object
        relationType*: string   # one-to-one, one-to-many, many-to-one, many-to-many
        sourceField*: FieldDesc
        targetTable*: string
        targetFields*: seq[FieldDesc]

    Model* = ref object
        modelName*: string
        timeStamp*: bool
        record*: Record
        relations*: seq[Relation]
        defaults*: seq[Default]
        validations*: seq[Validation]
        constraints*: seq[Constraints]
        methods*: seq[Method]
    
    # Procedure to define new data model (R => Model)
    ModelConstructor* = proc(): Model

    ## User/client information to be provided after successful login
    ## 
    UserParam* = object
        id*: string         # stored as uuid in the DB
        firstName*: string
        lastName*: string
        lang*: string
        loginName*: string
        email*: string
        token*: string

    # fieldValue(s) are string type for params parsing convenience,
    # fieldValue(s) will be cast by supported fieldType(s), else will through ValueError exception
    # fieldOp: GT, EQ, GTE, LT, LTE, NEQ(<>), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
    # groupOp/groupLinkOp: AND | OR
    # groupCat: user-defined, e.g. "age-policy", "demo-group"
    # groupOrder: user-defined e.g. 1, 2...
    FieldItem* = object
        fieldColl*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: string
        fieldOp*: Op    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParam ## for WHERE IN (SELECT field from fieldColl)
        fieldPostOp*: string ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: Op     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: string ## COUNT, MIN, MAX... for select/read-query...

    WhereParam* = object
        groupCat*: string       # group (items) categorization
        groupLinkOp*: Op    # group relationship to the next group (AND, OR)
        groupOrder*: int        # group order, the last group groupLinkOp should be "" or will be ignored
        groupItems*: seq[FieldItem] # group items to be composed by category

    ## QueryFunction type for function with one or more fields / arguments
    ## functionType => MIN(min), MAX, SUM, AVE, COUNT, CUSTOM/USER defined
    ## fieldItems=> specify fields/parameters to match the arguments for the functionType.
    ## The field item type must match the argument types expected by the functionType, 
    ## otherwise the only the first function-matching field will be used, as applicable
    QueryFunction* = object
        functionType*: string
        fieldItems*: seq[FieldItem]
        
    QueryParam* = object
        collName*: string    ## default: "" => will use instance collName instead
        fieldItems*: seq[FieldItem]   ## @[] => SELECT * (all fields)
        whereParams*: seq[WhereParam] ## whereParams or docId(s)  will be required for delete task

    ## For SELECT TOP... query
    QueryTop* = object         
        topValue*: int    
        topUnit*: string ## number or percentage (# or %)
    
    ## SELECT CASE... query condition(s)
    CaseCondition* = object
        fieldItems*: seq[FieldItem]
        resultMessage*: string
        resultField*: string  ## for ORDER BY options

    ## For SELECT CASE... query
    CaseQueryParam* = object
        conditions*: seq[CaseCondition]
        defaultField*: string   ## for ORDER BY options
        defaultMessage*: string 
        orderBy*: bool
        asField*: string

    SelectFromParam* = object
        collName*: string
        fieldItems*: seq[FieldItem]

    InsertIntoParam* = object
        collName*: string
        fieldItems*: seq[FieldItem]

    GroupParam* = object
        fieldName*: string
        fieldOrder*: int

    OrderParam* = object
        collName*: string
        fieldName*: string
        queryFunction*: QueryFunction
        fieldOrder*: Order ## "ASC" ("asc") | "DESC" ("desc")
        functionOrder*: Order

    # for aggregate query condition
    HavingParam* = object
        collName: string
        queryFunction*: QueryFunction
        queryOp*: Op
        queryOpValue*: string ## value will be cast to fieldType in queryFunction
        orderType*: Order ## "ASC" ("asc") | "DESC" ("desc")
        # subQueryParams*: SubQueryParam # for ANY, ALL, EXISTS...

    SubQueryParam* = object
        whereType*: string   ## EXISTS, ANY, ALL
        whereField*: string  ## for ANY / ALL | Must match the fieldName in queryParam
        whereOp*: Op     ## e.g. "=" for ANY / ALL
        queryParams*: QueryParam
        queryWhereParams*: WhereParam

    ## combined/joined query (read) param-type
    JoinSelectField* =  object
        collName*: string
        collFields*: seq[FieldItem]
    
    JoinField* = object
        collName*: string
        joinField*: string

    JoinQueryParam* = object
        selectFromColl*: string ## default to collName
        selectFields*: seq[JoinSelectField]
        joinType*: string ## INNER (JOIN), OUTER (LEFT, RIGHT & FULL), SELF...
        joinFields*: seq[JoinField] ## [{collName: "abc", joinField: "field1" },]
    
    SelectIntoParam* = object
        selectFields*: seq[FieldItem] ## @[] => SELECT *
        intoColl*: string          ## new table/collection
        fromColl*: string          ## old/external table/collection
        fromFilename*: string      ## IN external DB file, e.g. backup.mdb
        whereParam*: seq[WhereParam]
        joinParam*: JoinQueryParam ## for copying from more than one table/collection

    UnionQueryParam* = object
        selectQueryParams*: seq[QueryParam]
        whereParams*: seq[WhereParam]
        orderParams*: seq[OrderParam]

    RoleService* = object
        serviceId*: string
        group*    : string
        category* : string
        canRead*  : bool
        canCreate*: bool
        canUpdate*: bool
        canDelete*: bool
        collAccessPermitted: bool
    
    CheckAccess* = object
        userId*: string
        userRole*: string
        userRoles*: JsonNode
        isActive*: bool
        isAdmin*: bool
        roleServices*: seq[RoleService]
        collId*: string

    OkayResponse* = object
        ok*: bool
    
    CurrentRecord* = object
        currentRec*: seq[Row]
    
    TaskRecord* = object
        taskRec*: seq[QueryParam]
        recCount*: Positive 

    # Exception types
    SaveError* = object of CatchableError
    CreateError* = object of CatchableError
    UpdateError* = object of CatchableError
    DeleteError* = object of CatchableError
    ReadError* = object of CatchableError
    AuthError* = object of CatchableError
    ConnectError* = object of CatchableError
    SelectQueryError* = object of CatchableError
    WhereQueryError* = object of CatchableError
    CreateQueryError* = object of CatchableError
    UpdateQueryError* = object of CatchableError
    DeleteQueryError* = object of CatchableError


    ## Shared CRUD Operation Types  
    CrudParam* = ref object
        ## collName: table/collection to insert, update, read or delete record(s).
        collName*: string 
        docIds*: seq[string]  ## for update, delete and read tasks
        ## actionParams: @[{collName: "abc", fieldNames: @["field1", "field2"]},], for create & update.
        ## Field names and corresponding values of record(s) to insert/create or update.
        ## Field-values will be validated based on data model definition.
        ## ValueError exception will be raised for invalid value/data type 
        ##
        actionParams*: seq[QueryParam]
        queryParam*: QueryParam
        ## Bulk Insert Operation: 
        ## insertToParams {collName: "abc", fieldNames: @["field1", "field2"]}
        ## For collName: "" will use the default constructor collName
        insertIntoParams*: seq[InsertIntoParam]
        ## selectFromParams =
        ## {collName: "abc", fieldNames: @["field1", "field2"]}
        ## the order and types of insertIntoParams' & selectFromParams' fields must match, otherwise ValueError exception will occur
        ## 
        selectFromParams*: seq[SelectFromParam]
        selectIntoParams*: seq[SelectIntoParam]
        ## Query conditions
        ## whereParams: @[{groupCat: "validLocation", groupOrder: 1, groupLinkOp: "AND", groupItems: @[]}]
        ## groupItems = @[{collName: "testing", fieldName: "ab", fieldOp: ">=", groupOp: "AND(and)", order: 1, fieldType: "integer", filedValue: "10"},].
        ## 
        whereParams*: seq[WhereParam]
        # queryParams*: seq[QueryParam] => actionParams
        ## Read-only params =>
        ##  
        subQueryParams*: SubQueryParam
        ## Combined/joined query:
        ## 
        joinQueryParams*: seq[JoinQueryParam]
        unionQueryParams*: seq[UnionQueryParam]
        queryDistinct*: bool
        queryTop*: QueryTop
        ## Query function
        queryFunctions*: seq[QueryFunction]
        ## orderParams = @[{collName: "testing", fieldName: "name", fieldOrder: "ASC", queryFunction: "COUNT", functionOrderr: "DESC"}] 
        ## An order-param without orderType will default to ASC (ascending-order)
        ## 
        orderParams*: seq[OrderParam]
        groupParams*: seq[GroupParam] ## @[{fieldName: ""location", fieldOrder: 1}]
        havingParams*: seq[HavingParam]
        caseParams*: seq[CaseQueryParam] 
        skip*: Natural
        limit*: Positive
        defaultLimit*: Positive
        ## Database, audit-log and access parameters 
        ## 
        auditColl*: string
        accessColl*: string
        serviceColl*: string
        roleColl*: string
        userColl*: string
        appDb*: Database
        accessDb*: Database
        auditDb*: Database
        logAll*: bool
        logRead*: bool
        logCreate*: bool
        logUpdate*: bool
        logDelete*: bool
        userInfo*: UserParam
        checkAccess*: bool
        transLog*: LogParam
        isRecExist*: bool
        isAuthorized*: bool
        currentRecords*: seq[Row]
        roleServices*: seq[RoleService]
        recExistMessage*: string
        unAuthMessage*: string
