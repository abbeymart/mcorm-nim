import ../ormtypes

## TODO: computeCreateTempTableScript, from existing table, prior to SyncTable operation
## 
proc computeCreateTempTableScript*(tableName: string; model: ModelType): string =
    result = ""
