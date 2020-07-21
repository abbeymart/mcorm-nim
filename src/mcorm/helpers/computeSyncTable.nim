import ../ormtypes

## TODO: computeSyncTableScript: to sync existing table data, for changed table structure
## 
proc computeSyncTableScript*(tableName: string; model: ModelType): string =
    result = ""