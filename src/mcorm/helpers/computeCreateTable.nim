import ../ormtypes

## TODO: computeCreateTableScript
## 
proc computeCreateTableScript*(tableName: string; model: ModelType): string =
    result = ""
