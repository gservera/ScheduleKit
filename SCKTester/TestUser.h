//
//  TestUser.h
//  ScheduleKit
//
//  Created by Guillem on 12/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Cocoa;
@import ScheduleKit;

@interface TestUser : NSObject <SCKUser>
- (instancetype)initWithName:(NSString*)name color:(NSColor*)color;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSColor * labelColor;
@end
