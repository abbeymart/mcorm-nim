#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details a bout the copyright / license.
# 

##     CRUD Package - common / extendable base constructor & procedures for all CRUD operations
## 

import db_postgres, json, tables
import mcdb, mccache, mcresponse, mctranslog, mctypes
import ../helpers/helper

export db_postgres, json, tables
export mcdb, mccache, mcresponse, mctranslog
export helper

## Default CRUD contructor returns the instance/object for CRUD task(s)
## newCrud constructor returns a new crud-instance
proc newCrud*(params: CrudParamsType; options: CrudOptionsType): CrudType =    
    # new result
    result = CrudType()

    # crud-params
    result.params.appDb = params.appDb
    result.params.tableName = params.tableName
    result.params.userInfo = params.userInfo
    result.params.actionParams = params.actionParams
    result.params.recordIds = params.recordIds
    result.params.queryParams = params.queryParams
    result.params.sortParams = params.sortParams
    result.params.projectParams = params.projectParams
    result.params.existParams = params.existParams
    result.params.token = params.token
    result.params.taskName = params.taskName
    result.params.skip = params.skip
    result.params.limit = params.limit

    # crud-options
    result.options.auditTable = options.auditTable
    result.options.accessTable = options.accessTable
    result.options.roleTable = options.roleTable
    result.options.userTable = options.userTable
    result.options.userProfileTable = options.userProfileTable
    result.options.auditDb = options.auditDb
    result.options.accessDb = options.accessDb
    result.options.logAll = options.logAll
    result.options.logRead = options.logRead
    result.options.logCreate = options.logCreate
    result.options.logUpdate = options.logUpdate
    result.options.logDelete = options.logDelete
    result.options.checkAccess = options.checkAccess

    # Compute hashKey from tableName, queryParams, sortParams, projectParams and recordIds
    var qParam = $result.params.queryParams
    var sParam = $result.params.sortParams
    var pParam = $result.params.projectParams
    var recIds = $result.params.recordIds
    result.hashKey = qParam & sParam & pParam & recIds

    # Default values
    if result.options.auditTable == "":
            result.options.auditTable = "audits"

    if result.options.accessTable == "":
            result.options.accessTable = "access_keys"

    if result.options.roleTable == "":
            result.options.roleTable = "roles"

    if result.options.userTable == "":
            result.options.userTable = "users"

    if result.options.userProfileTable == "":
            result.options.userProfileTable = "user_profile"
    
    if result.options.serviceTable == "":
            result.options.serviceTable = "services"

    if result.options.auditDb == nil:
            result.options.auditDb = result.params.appDb

    if result.options.accessDb == nil:
            result.options.accessDb = result.params.appDb

    if result.options.skip < 0 :
            result.options.skip = 0

    if result.options.maxQueryLimit == 0 :
            result.options.maxQueryLimit = 10000

    if result.options.limit > result.options.maxQueryLimit and result.options.maxQueryLimit != 0:
            result.options.limit = result.options.maxQueryLimit

    if result.options.cacheExpire <= 0:
            result.options.cacheExpire = 300 # 300 secs, 5 minutes

    # audit/transLog instance
    result.transLog = newLog(result.options.auditDb, result.options.auditTable)
