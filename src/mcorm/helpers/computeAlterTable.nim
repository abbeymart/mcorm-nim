import ../ormtypes

## TODO: computeAlterTableScript: alter script for an existing table with different structure
## 
proc computeAlterTableScript*(tableName: string; model: ModelType): string =
    result = ""
