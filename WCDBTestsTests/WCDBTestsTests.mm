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


@end
