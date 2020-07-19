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

# Define ORM Types
type
    DataTypes* = enum
        STRING,
        TEXT,
        UUID,
        POSITIVE,
        INT,
        FLOAT,
        BOOL,
        JSON,
        BIGINT,
        BIGFLOAT,
        DATE,
        DATETIME,
        TIMESTAMP,
        OBJECT,     ## key-value pairs
        ENUM,       ## Enumerations
        SET,        ## Unique values set
        ARRAY,
        SEQ,
        TABLE,      ## Table/Map/Dictionary
        MCDB,       ## Database connection handle
        MODELREC,   ## Model record definition
        MODELVAL,   ## Model value definition
        
    ProcedureTypes* = enum
        PROC,              ## proc(): T
        VALIDATEPROC,      ## proc(val: T): bool
        CONSTRAINTPROC,    ## proc(val: T): bool
        DEFAULTPROC,       ## proc(): T
        UNARYPROC,         ## proc(val: T): T
        BIPROC,            ## proc(valA, valB: T): T
        PREDICATEPROC,     ## proc(val: T): bool
        BIPREDICATEPROC,   ## proc(valA, valB: T): bool
        SUPPLYPROC,        ## proc(): T
        BISUPPLYPROC,      ## proc(): (T, T)
        CONSUMERPROC,      ## proc(val: T): void
        BICONSUMERPROC,    ## proc(valA, valB: T): void
        COMPARATORPROC,    ## proc(valA, valB: T): int
        MODELPROC,         ## proc(): Model  | to define new data model

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

    CreatedBy* = DataTypes
    UpdatedBy* = DataTypes
    CreatedAt* = DateTime
    UpdatedAt* = DateTime
    
    DefaultProcedure*[T, R] = proc(val: T): R {.closure.}
    MethodProcedure*[T, R] = proc(rec: T): R {.closure.}
    ValidationProcedure*[T] = proc(rec: T): bool {.closure.}
    ConstraintProcedure*[T] = proc(rec: T): bool {.closure.}
    SupplierProcedure*[R] = proc(): R {.closure.}

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
        fieldDefaultValue*: ProcedureTypes
        
    RecordDesc* = Table[string, FieldDesc ]
    FieldTypes* = Table[string, DataTypes ]

    Relation* = ref object
        relationType*: string   # one-to-one, one-to-many, many-to-one, many-to-many
        sourceField*: FieldDesc
        targetTable*: string
        targetFields*: seq[FieldDesc]

    ModelType* = ref object
        modelName*: string
        tableName*: string
        recordDesc*: RecordDesc
        timeStamp*: bool
        relations*: seq[Relation]
        defaults*: seq[ProcedureTypes]
        validations*: seq[ProcedureTypes]
        constraints*: seq[ProcedureTypes]
        methods*: seq[ProcedureTypes]
        appDb*: Database

    Model* = ref object
        modelName*: string
        tableName*: string
        recordDesc*: RecordDesc
        # fieldTypes*: FieldTypes
        timeStamp*: bool
        relations*: seq[Relation]
        defaults*: seq[ProcedureTypes]
        validations*: seq[ProcedureTypes]
        constraints*: seq[ProcedureTypes]
        methods*: seq[ProcedureTypes]
        appDb: Database

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
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: Positive
        fieldOp*: Op    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParam ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: Op ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: Op     ## e.g. AND | OR...
        fieldAlias*: string ## for SELECT/Read query
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    SaveFieldType* = object
        fieldName*: string
        fieldValue*: string
        fieldOrder*: Positive
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    CreateFieldType* = object
        fieldName*: string
        fieldValue*: string 

    UpdateFieldType* = object
        fieldName*: string
        fieldValue*: string
        fieldOrder*: Positive
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    ReadFieldType* = object
        fieldName*: string
        fieldOrder*: Positive
        fieldAlias*: string
        show*: bool     ## includes or excludes from the SELECT query fields
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    DeleteFieldType* = object
        fieldName*: string
        fieldSubQuery*: QueryParam
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    WhereFieldType* = object
        fieldName*: string
        fieldOrder*: Positive
        fieldOp*: Op    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParam ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: Op ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: Op     ## e.g. AND | OR...
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    WhereParam* = object
        groupCat*: string       # group (items) categorization
        groupLinkOp*: Op        # group relationship to the next group (AND, OR)
        groupOrder*: Positive        # group order, the last group groupLinkOp should be "" or will be ignored
        groupItems*: seq[WhereFieldType] # group items to be composed by category

    SaveParam* = object
        tableName*: string
        fields*: seq[SaveFieldType]
    
    CreateParam* = object
        tableName*: string
        fields*: seq[CreateFieldType]
    
    UpdateParam* = object
        tableName*: string
        fields*: seq[UpdateFieldType]
        where*: seq[WhereFieldType]
    
    ReadParam* = object
        tableName*: string
        fields*: seq[ReadFieldType]
        where*: seq[WhereFieldType]
    
    DeleteParam* = object
        tableName*: string
        fields*: seq[DeleteFieldType]
        where*: seq[WhereFieldType]
        
    ## queryProc type for function with one or more fields / arguments
    ## functionType => MIN(min), MAX, SUM, AVE, COUNT, CUSTOM/USER defined
    ## fieldItems=> specify fields/parameters to match the arguments for the functionType.
    ## The field item type must match the argument types expected by the functionType, 
    ## otherwise the only the first function-matching field will be used, as applicable
    QueryProc* = object
        functionType*: ProcedureTypes
        fieldItems*: seq[FieldItem]
        
    QueryParam* = object        # TODO: Generic => make specific to CRUD operations
        tableName*: string    ## default: "" => will use instance tableName instead
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
        tableName*: string
        fieldItems*: seq[FieldItem]

    InsertIntoParam* = object
        tableName*: string
        fieldItems*: seq[FieldItem]

    GroupParam* = object
        fieldName*: string
        fieldOrder*: int

    OrderParam* = object
        tableName*: string
        fieldName*: string
        queryProc*: ProcedureTypes
        fieldOrder*: Order ## "ASC" ("asc") | "DESC" ("desc")
        functionOrder*: Order

    # for aggregate query condition
    HavingParam* = object
        tableName: string
        queryProc*: ProcedureTypes
        queryOp*: Op
        queryOpValue*: string ## value will be cast to fieldType in queryProc
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
        tableName*: string
        collFields*: seq[FieldItem]
    
    JoinField* = object
        tableName*: string
        joinField*: string

    JoinQueryParam* = object
        selectFromColl*: string ## default to tableName
        selectFields*: seq[JoinSelectField]
        joinType*: string ## INNER (JOIN), OUTER (LEFT, RIGHT & FULL), SELF...
        joinFields*: seq[JoinField] ## [{tableName: "abc", joinField: "field1" },]
    
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
        ## tableName: table/collection to insert, update, read or delete record(s).
        tableName*: string 
        docIds*: seq[string]  ## for update, delete and read tasks
        ## actionParams: @[{tableName: "abc", fieldNames: @["field1", "field2"]},], for create & update.
        ## Field names and corresponding values of record(s) to insert/create or update.
        ## Field-values will be validated based on data model definition.
        ## ValueError exception will be raised for invalid value/data type 
        ##
        actionParams*: seq[QueryParam]
        queryParam*: QueryParam
        ## Bulk Insert Operation: 
        ## insertToParams {tableName: "abc", fieldNames: @["field1", "field2"]}
        ## For tableName: "" will use the default constructor tableName
        insertIntoParams*: seq[InsertIntoParam]
        ## selectFromParams =
        ## {tableName: "abc", fieldNames: @["field1", "field2"]}
        ## the order and types of insertIntoParams' & selectFromParams' fields must match, otherwise ValueError exception will occur
        ## 
        selectFromParams*: seq[SelectFromParam]
        selectIntoParams*: seq[SelectIntoParam]
        ## Query conditions
        ## whereParams: @[{groupCat: "validLocation", groupOrder: 1, groupLinkOp: "AND", groupItems: @[]}]
        ## groupItems = @[{tableName: "testing", fieldName: "ab", fieldOp: ">=", groupOp: "AND(and)", order: 1, fieldType: "integer", filedValue: "10"},].
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
        queryFunctions*: seq[ProcedureTypes]
        ## orderParams = @[{tableName: "testing", fieldName: "name", fieldOrder: "ASC", queryProc: "COUNT", functionOrderr: "DESC"}] 
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
