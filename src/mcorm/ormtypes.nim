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

    OpTypes* = enum
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

    OrderTypes* = enum
        ASC,
        DESC,

    CreatedByType* = DataTypes
    UpdatedByType* = DataTypes
    CreatedAtType* = DateTime
    UpdatedAtType* = DateTime
    
    DefaultProcedureType*[R] = proc(): R {.closure.}
    MethodProcedureType*[T, R] = proc(rec: T): R {.closure.}
    ValidateProcedureType*[T] = proc(rec: T): bool {.closure.}
    ConstraintProcedureType*[T] = proc(rec: T): bool {.closure.}
    SupplierProceduceType*[R] = proc(): R {.closure.}

    DefaultValueType* = object
        fieldName*: string
        defaultProc*: proc(): DataTypes
    
    ValidateType* = object
        fieldName*: string
        validateProc*: proc(): bool

    ConstraintType* = object
        fieldName*: string
        constraintProc*: proc(): bool

    MethodType* = object
        fieldNames*: seq[string]
        methodProc*: proc(): DataTypes

    FieldDescType* = object
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
        
    RecordDescType* = Table[string, FieldDescType ]

    FieldTypes* = Table[string, DataTypes ]

    RelationType* = ref object
        relationType*: string   # one-to-one, one-to-many, many-to-one, many-to-many
        sourceField*: FieldDescType
        targetTable*: string
        targetFields*: seq[FieldDescType]

    ModelType* = ref object
        modelName*: string
        tableName*: string
        recordDesc*: RecordDescType
        timeStamp*: bool
        relations*: seq[RelationType]
        defaults*: seq[ProcedureTypes]
        validations*: seq[ProcedureTypes]
        constraints*: seq[ProcedureTypes]
        methods*: seq[ProcedureTypes]
        appDb*: Database

    ## User/client information to be provided after successful login
    ## 
    UserParamType* = object
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
    FieldItemType* = object
        fieldTable*: string
        fieldName*: string
        fieldType*: DataTypes   ## "int", "string", "bool", "boolean", "float",...
        fieldOrder*: Positive
        fieldOp*: OpTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OpTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: OpTypes     ## e.g. AND | OR...
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
        fieldSubQuery*: QueryParamType
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    GroupFunctionType* = object
        fields*: seq[string]
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX, custom... for select/read-query...

    WhereFieldType* = object
        fieldName*: string
        fieldOrder*: Positive
        fieldOp*: OpTypes    ## GT/gt/>, EQ/==, GTE/>=, LT/<, LTE/<=, NEQ(<>/!=), BETWEEN, NOTBETWEEN, IN, NOTIN, LIKE, IS, ISNULL, NOTNULL etc., with matching params (fields/values)
        fieldValue*: string  ## for insert/update | start value for range/BETWEEN/NOTBETWEEN and pattern for LIKE operators
        fieldValueEnd*: string   ## end value for range/BETWEEN/NOTBETWEEN operator
        fieldValues*: seq[string] ## values for IN/NOTIN operator
        fieldSubQuery*: QueryParamType ## for WHERE IN (SELECT field from fieldTable)
        fieldPostOp*: OpTypes ## EXISTS, ANY or ALL e.g. WHERE fieldName <fieldOp> <fieldPostOp> <anyAllQueryParams>
        groupOp*: OpTypes     ## e.g. AND | OR...
        fieldFunction*: ProcedureTypes ## COUNT, MIN, MAX... for select/read-query...

    WhereParamType* = object
        groupCat*: string       # group (items) categorization
        groupLinkOp*: OpTypes        # group relationship to the next group (AND, OR)
        groupOrder*: Positive        # group order, the last group groupLinkOp should be "" or will be ignored
        groupItems*: seq[WhereFieldType] # group items to be composed by category

    SaveParamType* = object
        tableName*: string
        fields*: seq[SaveFieldType]
        where*: seq[WhereFieldType]
    
    CreateParamType* = object
        tableName*: string
        fields*: seq[CreateFieldType]
    
    UpdateParamType* = object
        tableName*: string
        fields*: seq[UpdateFieldType]
        where*: seq[WhereFieldType]
    
    ReadParamType* = object
        tableName*: string
        fields*: seq[ReadFieldType]
        where*: seq[WhereFieldType]
    
    DeleteParamType* = object
        tableName*: string
        fields*: seq[DeleteFieldType]
        where*: seq[WhereFieldType]
        
    ## queryProc type for function with one or more fields / arguments
    ## functionType => MIN(min), MAX, SUM, AVE, COUNT, CUSTOM/USER defined
    ## fields=> specify fields/parameters to match the arguments for the functionType.
    ## The field item type must match the argument types expected by the functionType, 
    ## otherwise the only the first function-matching field will be used, as applicable
    QueryProc* = object
        functionType*: ProcedureTypes
        fields*: seq[FieldItemType]
        
    QueryParamType* = object        # TODO: Generic => make specific to CRUD operations
        tableName*: string    ## default: "" => will use instance tableName instead
        fields*: seq[FieldItemType]   ## @[] => SELECT * (all fields)
        where*: seq[WhereParamType] ## whereParams or docId(s)  will be required for delete task

    ## For SELECT TOP... query
    QueryTopType* = object         
        topValue*: int    
        topUnit*: string ## number or percentage (# or %)
    
    ## SELECT CASE... query condition(s)
    CaseConditionType* = object
        fields*: seq[FieldItemType]
        resultMessage*: string
        resultField*: string  ## for ORDER BY options

    ## For SELECT CASE... query
    CaseQueryType* = object
        conditions*: seq[CaseConditionType]
        defaultField*: string   ## for ORDER BY options
        defaultMessage*: string 
        orderBy*: bool
        asField*: string

    SelectFromType* = object
        tableName*: string
        fields*: seq[FieldItemType]

    InsertIntoType* = object
        tableName*: string
        fields*: seq[FieldItemType]

    GroupType* = object
        fields*: seq[string]
        fieldFunction*: seq[ProcedureTypes]
        fieldOrder*: int

    OrderType* = object
        tableName*: string
        fieldName*: string
        queryProc*: ProcedureTypes
        fieldOrder*: OrderTypes ## "ASC" ("asc") | "DESC" ("desc")
        functionOrder*: OrderTypes

    # for aggregate query condition
    HavingType* = object
        tableName: string
        queryProc*: ProcedureTypes
        queryOp*: OpTypes
        queryOpValue*: string ## value will be cast to fieldType in queryProc
        orderType*: OrderTypes ## "ASC" ("asc") | "DESC" ("desc")
        # subQueryParams*: SubQueryParam # for ANY, ALL, EXISTS...

    SubQueryType* = object
        whereType*: string   ## EXISTS, ANY, ALL
        whereField*: string  ## for ANY / ALL | Must match the fieldName in QueryParamType
        whereOp*: OpTypes     ## e.g. "=" for ANY / ALL
        queryParams*: QueryParamType
        queryWhereParams*: WhereParamType

    ## combined/joined query (read) param-type
    JoinSelectFieldType* =  object
        tableName*: string
        collFields*: seq[FieldItemType]
    
    JoinFieldType* = object
        tableName*: string
        joinField*: string

    JoinQueryType* = object
        selectFromColl*: string ## default to tableName
        selectFields*: seq[JoinSelectFieldType]
        joinType*: string ## INNER (JOIN), OUTER (LEFT, RIGHT & FULL), SELF...
        joinFields*: seq[JoinFieldType] ## [{tableName: "abc", joinField: "field1" },]
    
    SelectIntoType* = object
        selectFields*: seq[FieldItemType] ## @[] => SELECT *
        intoColl*: string          ## new table/collection
        fromColl*: string          ## old/external table/collection
        fromFilename*: string      ## IN external DB file, e.g. backup.mdb
        WhereParamType*: seq[WhereParamType]
        joinParam*: JoinQueryType ## for copying from more than one table/collection

    UnionQueryType* = object
        selectQueryParams*: seq[QueryParamType]
        where*: seq[WhereParamType]
        orderParams*: seq[OrderType]

    RoleServiceType* = object
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
        roleServices*: seq[RoleServiceType]
        collId*: string

    OkayResponse* = object
        ok*: bool
    
    CurrentRecord* = object
        currentRec*: seq[Row]
    
    TaskRecord* = object
        taskRec*: seq[QueryParamType]
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
    CrudParamType* = ref object
        ## tableName: table/collection to insert, update, read or delete record(s).
        tableName*: string 
        docIds*: seq[string]  ## for update, delete and read tasks
        ## actionParams: @[{tableName: "abc", fieldNames: @["field1", "field2"]},], for create & update.
        ## Field names and corresponding values of record(s) to insert/create or update.
        ## Field-values will be validated based on data model definition.
        ## ValueError exception will be raised for invalid value/data type 
        ##
        actionParams*: seq[SaveParamType]
        queryParam*: QueryParamType
        ## Bulk Insert Operation: 
        ## insertToParams {tableName: "abc", fieldNames: @["field1", "field2"]}
        ## For tableName: "" will use the default constructor tableName
        insertInto*: seq[InsertIntoType]
        ## selectFrom =
        ## {tableName: "abc", fieldNames: @["field1", "field2"]}
        ## the order and types of insertInto' & selectFrom' fields must match, otherwise ValueError exception will occur
        ## 
        selectFrom*: seq[SelectFromType]
        selectInto*: seq[SelectIntoType]
        ## Query conditions
        ## where: @[{groupCat: "validLocation", groupOrder: 1, groupLinkOp: "AND", groupItems: @[]}]
        ## groupItems = @[{tableName: "testing", fieldName: "ab", fieldOp: ">=", groupOp: "AND(and)", order: 1, fieldType: "integer", filedValue: "10"},].
        ## 
        where*: seq[WhereParamType]
        # queryParams*: seq[QueryParamType] => actionParams
        ## Read-only params =>
        ##  
        subQuery*: SubQueryType
        ## Combined/joined query:
        ## 
        joinQuery*: seq[JoinQueryType]
        unionQuery*: seq[UnionQueryType]
        queryDistinct*: bool
        queryTop*: QueryTopType
        ## Query function
        queryFunctions*: seq[ProcedureTypes]
        ## orderParams = @[{tableName: "testing", fieldName: "name", fieldOrder: "ASC", queryProc: "COUNT", functionOrderr: "DESC"}] 
        ## An order-param without orderType will default to ASC (ascending-order)
        ## 
        order*: seq[OrderType]
        group*: seq[GroupType] ## @[{fieldName: ""location", fieldOrder: 1}]
        having*: seq[HavingType]
        caseQuery*: seq[CaseQueryType] 
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
        userInfo*: UserParamType
        checkAccess*: bool
        transLog*: LogParam
        isRecExist*: bool
        isAuthorized*: bool
        currentRecords*: seq[Row]
        roleServices*: seq[RoleServiceType]
        recExistMessage*: string
        unAuthMessage*: string
