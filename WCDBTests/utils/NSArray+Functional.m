//
//  NSArray+Functional.m
//  WCDBTests
//
//  Created by leon on 05/02/2020.
//  Copyright © 2020 Maimemo Inc. All rights reserved.
//

#import "NSArray+Functional.h"


@implementation NSArray (Functional)


- (NSArray *)map:(id (^)(id object))block {
    if (!block) return self;
    NSMutableArray *array = NSMutableArray.array;
    id value;
    for (id obj in self) {
        if ((value = block(obj)) != nil) {
            [array addObject:value];
        }
    }
    return array.copy;
}


@end
