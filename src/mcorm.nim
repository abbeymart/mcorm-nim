#
#            mccentral APIs solution
#        (c) Copyright 2020 Abi Akindele (mconnect.biz)
#
#    See the file "LICENSE.md", included in this
#    distribution, for details about the copyright / license.
#
#      This is the entry point for mcorm package / library
#           All CRUD operations are transactional
# 

import mcorm/ormtypes
import mcorm/ddl/model
import mcorm/dml/getrecord
import mcorm//dml/saverecord
import mcorm/dml/deleterecord

export ormtypes
export model
export getrecord
export saverecord
export deleterecord
