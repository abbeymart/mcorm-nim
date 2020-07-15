#
#                   mconnect solutions
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details a bout the copyright / license.
# 
#            CRUD Package - delete(remove) record(s)
# 

## delete(remove)-record procedure is delete record(s) by role (access-control)
## 
import crud

# constructor
## delete-record operations constructor
proc newDeleteRecord*(appDb: Database;
                    collName: string;
                    userInfo: UserParam;
                    whereParams: seq[QueryParam];
                    docIds: seq[string] = @[]; 
                    options: Table[string, ValueType] = []): CrudParam =
    ## base / shared constructor
    result = newCrud(appDb, collName, userInfo, whereParams = whereParams, docIds = docIds, options = options )

## Delete or remove record(s) by id(s)
## 
proc deleteRecordById(crud: CrudParam): ResponseMessage =
    try:
        ## get current records
        let currentRecScript = computeSelectByIdScript(crud.collName, crud.docIds)
        let currentRecs =  crud.appDb.db.getAllRows(sql(currentRecScript))

        # exit / return if currentRecs[0].len < 1 or currentRecs.len < crud.docIds.len
        if currentRecs[0].len < 1 or currentRecs.len < crud.docIds.len:
            let okRes = OkayResponse(ok: false)
            return getResMessage("notFound", ResponseMessage(value: %*(okRes), message: "No or less record(s) found"))  
        
        ## compute delete script from docIds
        let deleteScripts: string = computeDeleteByIdScript(crud.collName, crud.docIds)
                
        # perform delete task, wrap in transaction
        crud.appDb.db.exec(sql"BEGIN")
        crud.appDb.db.exec(sql(deleteScripts))
        crud.appDb.db.exec(sql"COMMIT")

        # perform audit/trans-log action
        # TODO: transform currentRecs into JSON based on projected fiedls or data model structure
        let collValues = %*(CurrentRecord(currentRec: currentRecs))
        if crud.logDelete:
            discard crud.transLog.deleteLog(crud.collName, collValues, crud.userInfo.id)

        # response
        return getResMessage("success", ResponseMessage(value: %*(crud.docIds), message: "Record(s) deleted(removed) successfully"))
    except:
        let okRes = OkayResponse(ok: false)
        return getResMessage("deleteError", ResponseMessage(value: %*(okRes), message: getCurrentExceptionMsg()))  

## Delete or remove record(s) by params / query
## 
proc deleteRecordByParam(crud: CrudParam): ResponseMessage =
    try:
        ## get current records
        let selectQuery = computeSelectQuery(crud.collName, crud.queryParam)
        let whereParam = computeWhereQuery(crud.whereParams)

        let currentRecScript = selectQuery & " " & whereParam

        let currentRecs =  crud.appDb.db.getAllRows(sql(currentRecScript))

        # exit / return if currentRecs[0].len < 1
        if currentRecs[0].len < 1:
            let okRes = OkayResponse(ok: false)
            return getResMessage("notFound", ResponseMessage(value: %*(okRes), message: "No record(s) found"))  
        
        ## compute delete script from whereParams
        let deleteScripts: string = computeDeleteByParamScript(crud.collName, crud.whereParams)
            
        # wrap in transaction
        crud.appDb.db.exec(sql"BEGIN")
        crud.appDb.db.exec(sql(deleteScripts))
        crud.appDb.db.exec(sql"COMMIT")

        # perform audit/trans-log action
        # TODO: transform currentRecs into JSON based on projected fiedls or data model structure
        let collValues = %*(CurrentRecord(currentRec: currentRecs))
        if crud.logDelete:
            discard crud.transLog.deleteLog(crud.collName, collValues, crud.userInfo.id)

        # response
        return getResMessage("success", ResponseMessage(value: %*(crud.docIds), message: "Record(s) deleted(removed) successfully"))
    except:
        let okRes = OkayResponse(ok: false)
        return getResMessage("deleteError", ResponseMessage(value: %*(okRes), message: getCurrentExceptionMsg()))  

proc deleteRecord*(crud: CrudParam; by: string;
                    docIds: seq[string] = @[];
                    whereParams: seq[WhereParam] = @[]): ResponseMessage =
    ## perform delete task, by taskType (id or params/query)
    try:
        # update crud instance ref-variables
        if crud.docIds.len < 1 and docIds.len > 0:
            crud.docIds = docIds
        if crud.whereParams.len < 1 and whereParams.len > 0:
            crud.whereParams = whereParams

        # validate required inputs by action-type
        if by == "id" and crud.docIds.len < 1:
            # return error message
            return getResMessage("paramsError", ResponseMessage(value: nil, message: "Fod delete by id, docIds[] is required"))
        elif whereParams.len < 1:
            return getResMessage("paramsError", ResponseMessage(value: nil, message: "For delete by params, whereParams is required"))
        
        case by:
        of "id":
            # check permission based on the delete task
            var taskPermit = taskPermission(crud, "delete")
            let taskValue = taskPermit.value{"ok"}.getBool(false)
            if taskValue and taskPermit.code == "success":
                # delete record(s) by id
                return deleteRecordById(crud)
            else:
                # return task permission response (unAuthorized)
                return taskPermit
        of "params", "query":
            # check permission based on the create and/or update records
            var taskPermit = taskPermission(crud, "delete")
            let taskValue = taskPermit.value{"ok"}.getBool(false)
            if taskValue and taskPermit.code == "success":
                # delete record(s) by params/query
                return deleteRecordByParam(crud)
            else:
                # return task permission response (unAuthorized)
                return taskPermit
    except:
        let okRes = OkayResponse(ok: false)
        return getResMessage("saveError", ResponseMessage(value: %*(okRes), message: getCurrentExceptionMsg()))
    