//
//  TestUser.m
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

- (nonnull instancetype)initWithName:(nonnull NSString*)name
                               color:(nonnull NSColor*)color {
    self = [super init];
    if (self) {
        self.name = name;
        _labelColor = color;
    }
    return self;
}

@end
