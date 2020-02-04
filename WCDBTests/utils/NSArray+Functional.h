//
//  NSArray+Functional.h
//  WCDBTests
//
//  Created by leon on 05/02/2020.
//  Copyright © 2020 Maimemo Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (NSArray *)map:(id (^)(id object))block;

@end
