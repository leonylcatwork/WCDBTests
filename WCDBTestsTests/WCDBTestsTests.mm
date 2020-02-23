//
//  WCDBTestsTests.m
//  WCDBTestsTests
//
//  Created by leon on 05/02/2020.
//  Copyright © 2020 Maimemo Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSArray+Functional.h"
#import "Model+WCTTableCoding.h"
#import "AnyStatement.h"


using namespace WCDB;


@interface WCDBTestsTests : XCTestCase

@property (nonatomic, strong) WCTDatabase *db;

@end


@implementation WCDBTestsTests


- (void)setUp {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"database.db"]];
        if (_db.canOpen && ![_db isTableExists:NSStringFromClass(Model.class)]) {
            [_db createTableAndIndexesOfName:NSStringFromClass(Model.class) withClass:Model.class];
        }
    }
}


- (void)tearDown {
    [_db close];
    _db = nil;
}


- (void)testBatchInsert {
    NSArray <Model *> *models =
    [@[@"1", @"2", @"3"] map:^id(NSString *object) {
        Model *model = [Model new];
        model.id = object;
        return model;
    }];

    XCTAssertTrue(_db.canOpen, @"Unable to open database");
    // clean table
    BOOL ret = [_db deleteAllObjectsFromTable:NSStringFromClass(Model.class)];
    XCTAssertTrue(ret, @"Unable clean objects");

    ret = [_db insertObjects:models into:NSStringFromClass(Model.class)];
    XCTAssertTrue(ret, @"Unable insert objects");
    NSInteger count = [[_db getOneValueOnResult:Model.id.count() fromTable:NSStringFromClass(Model.class)] integerValue];
    XCTAssertTrue(count == models.count, @"Error insert objects (%d / %d)", (int)count, (int)models.count);
}


- (void)testBatchInsertInTransaction1 {
    NSArray <Model *> *models =
    [@[@"1", @"2", @"3"] map:^id(NSString *object) {
        Model *model = [Model new];
        model.id = object;
        return model;
    }];

    XCTAssertTrue(_db.canOpen, @"Unable to open database");
    // clean table
    BOOL ret = [_db deleteAllObjectsFromTable:NSStringFromClass(Model.class)];
    XCTAssertTrue(ret, @"Unable clean objects");

    ret =
    [_db runTransaction:^BOOL{
        return [self.db insertObjects:models into:NSStringFromClass(Model.class)];
    }];
    XCTAssertTrue(ret, @"Unable insert objects");
    NSInteger count = [[_db getOneValueOnResult:Model.id.count() fromTable:NSStringFromClass(Model.class)] integerValue];
    XCTAssertTrue(count == models.count, @"Error insert objects (%d / %d)", (int)count, (int)models.count);
}


- (void)testBatchInsertInTransaction2 {
    NSArray <Model *> *models =
    [@[@"1", @"2", @"3"] map:^id(NSString *object) {
        Model *model = [Model new];
        model.id = object;
        return model;
    }];

    XCTAssertTrue(_db.canOpen, @"Unable to open database");
    // clean table
    BOOL ret = [_db deleteAllObjectsFromTable:NSStringFromClass(Model.class)];
    XCTAssertTrue(ret, @"Unable clean objects");
    
    WCTTransaction *transaction = _db.getTransaction;
    [transaction begin];
    ret = [transaction insertObjects:models into:NSStringFromClass(Model.class)];
    if (ret) {
        [transaction commit];
    } else {
        [transaction rollback];
    }

    XCTAssertTrue(ret, @"Unable insert objects");
    NSInteger count = [[self.db getOneValueOnResult:Model.id.count() fromTable:NSStringFromClass(Model.class)] integerValue];
    XCTAssertTrue(count == models.count, @"Error insert objects (%d / %d)", (int)count, (int)models.count);
}


- (void)testBatchInsertInTransaction3 {
    NSArray <Model *> *models =
    [@[@"1", @"2", @"3"] map:^id(NSString *object) {
        Model *model = [Model new];
        model.id = object;
        return model;
    }];

    XCTAssertTrue(_db.canOpen, @"Unable to open database");
    // clean table
    BOOL ret = [_db deleteAllObjectsFromTable:NSStringFromClass(Model.class)];
    XCTAssertTrue(ret, @"Unable clean objects");

    WCTTransaction *transaction = _db.getTransaction;
    ret =
    [transaction runTransaction:^BOOL{
        return [transaction insertObjects:models into:NSStringFromClass(Model.class)];
    }];

    XCTAssertTrue(ret, @"Unable insert objects");
    NSInteger count = [[_db getOneValueOnResult:Model.id.count() fromTable:NSStringFromClass(Model.class)] integerValue];
    XCTAssertTrue(count == models.count, @"Error insert objects (%d / %d)", (int)count, (int)models.count);
}


- (void)testWithoutRowid {
    NSMutableArray *models = NSMutableArray.array;
    long long a = 1e11;
    NSString *prefix = @(a).stringValue;
    for (NSInteger i = 0; i < 1000000; i++) {
        @autoreleasepool {
            Model *model = [Model new];
            model.id = [prefix stringByAppendingString:@(i + a).stringValue]; // pretending this is a 24-bit id
            model.age = arc4random();
            model.updatedTime = @"2020-02-20T01:01:01.123+0800";
            model.createdTime = @"2020-02-20T01:01:01.123+0800";
            model.status = @"PUBLISHED";
            [models addObject:model];
        }
    }

    NSString *table = @"tbl";

    const WCTBinding *binding = [Model objectRelationalMappingForWCDB];
    StatementCreateTable stmt = binding->generateCreateTableStatement(table.UTF8String);

    __block NSUInteger sizeWithoutRowid, sizeWithRowid;
    @autoreleasepool {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"withoutrowid.db"];
        WCTDatabase *db = [[WCTDatabase alloc] initWithPath:path];
        XCTAssertTrue(db.canOpen);
        AnyStatement withoutRowid = AnyStatement(stmt).append(Expr(Column("WITHOUT ROWID")));
        NSLog(@"sql: %s", withoutRowid.getDescription().c_str());
        BOOL ret = [db exec:withoutRowid];
        if (ret) {
            ret = [db isTableExists:table];
            NSLog(@"schema: %@", [self.class schemaOfTable:table db:db]);
            NSLog(@"path: %@", [db path]);
            ret = [db insertOrReplaceObjects:models into:table];
            if (ret) {
                NSInteger count = [[db getOneValueOnResult:Model.AnyProperty.count() fromTable:table] integerValue];
                [db close:^{
                    sizeWithoutRowid = [db getFilesSizeWithError:nil];
                    NSLog(@"WITHOUT ROWID %ld rows inserted, size: %lu MB", count, sizeWithoutRowid / 1024 / 1024);
                    [db removeFilesWithError:nil];
                }];
            }
        }
    }

    @autoreleasepool {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"withrowid.db"];
        WCTDatabase *db = [[WCTDatabase alloc] initWithPath:path];
        XCTAssertTrue(db.canOpen);
        NSLog(@"sql: %s", stmt.getDescription().c_str());
        BOOL ret = [db exec:stmt];
        if (ret) {
            ret = [db isTableExists:table];
            NSLog(@"schema: %@", [self.class schemaOfTable:table db:db]);
            NSLog(@"path: %@", [db path]);
            ret = [db insertOrReplaceObjects:models into:table];
            if (ret) {
                NSInteger count = [[db getOneValueOnResult:Model.AnyProperty.count() fromTable:table] integerValue];
                [db close:^{
                    sizeWithRowid = [db getFilesSizeWithError:nil];
                    NSLog(@"WITH ROWID %ld rows inserted, size: %lu MB", count, sizeWithRowid / 1024 / 1024);
                    [db removeFilesWithError:nil];
                }];
            }
        }
    }

    NSLog(@"Using 'WITHOUT ROWID' saved %luMB (%.2f)%% space",
          (sizeWithRowid - sizeWithoutRowid) / 1024 / 1024,
          (sizeWithRowid - sizeWithoutRowid) * 100 / (double)sizeWithRowid);
}


+ (NSString *)schemaOfTable:(NSString *)table db:(WCTDatabase *)db {
    @autoreleasepool {
        StatementSelect select = StatementSelect()
        .select({ColumnResult(Column("sql"))})
        .from("sqlite_master")
        .where(Expr(Column("type")) == "table" && Expr(Column("name")) == table.UTF8String);
        WCTStatement *stmt = [db prepare:select];
        NSString * sql = nil;
        if (stmt.step) {
            @autoreleasepool {
                sql = (NSString *)[stmt getValueAtIndex:0];
            }
        }
        [stmt finalize];
        return sql;
    }
}


@end
