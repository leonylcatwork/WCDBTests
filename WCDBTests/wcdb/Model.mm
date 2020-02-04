//
//  Model.mm
//  WCDBTests
//
//  Created by leon on 05/02/2020.
//  Copyright © 2020 Maimemo Inc. All rights reserved.
//

#import "Model+WCTTableCoding.h"
#import "Model.h"
#import <WCDB/WCDB.h>

@implementation Model

WCDB_IMPLEMENTATION(Model)

WCDB_SYNTHESIZE_COLUMN_DEFAULT(Model, id, "_id", NULL)
WCDB_SYNTHESIZE_COLUMN_DEFAULT(Model, name, "_name", NULL)
WCDB_SYNTHESIZE_COLUMN_DEFAULT(Model, age, "_age", 0)

WCDB_PRIMARY(Model, id)
  
@end
