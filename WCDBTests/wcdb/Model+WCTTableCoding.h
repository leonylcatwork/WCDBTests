//
//  Model+WCTTableCoding.h
//  WCDBTests
//
//  Created by leon on 05/02/2020.
//  Copyright © 2020 Maimemo Inc. All rights reserved.
//

#import "Model.h"
#import <WCDB/WCDB.h>

@interface Model (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(id)
WCDB_PROPERTY(name)
WCDB_PROPERTY(age)
WCDB_PROPERTY(status)
WCDB_PROPERTY(updatedTime)
WCDB_PROPERTY(createdTime)

@end
