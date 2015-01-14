//
//  TestUser.m
//  ScheduleKit
//
//  Created by Guillem on 12/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

- (instancetype)initWithName:(NSString*)name color:(NSColor*)color {
    self = [super init];
    if (self) {
        _name = name;
        _labelColor = color;
    }
    return self;
}
@end
