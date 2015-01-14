//
//  TestEvent.h
//  ScheduleKit
//
//  Created by Guillem on 14/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Foundation;
@import ScheduleKit;

@interface TestEvent : NSObject <SCKEvent>

+ (NSArray*)sampleEvents:(NSArray*)userArray;
- (instancetype)initWithType:(SCKEventType)type user:(id <SCKUser>)user patient:(id)patient title:(NSString*)title duration:(NSInteger)duration date:(NSDate*)date;

@property (assign) SCKEventType eventType;
@property (strong) id <SCKUser> user;
@property (strong) id patient;
@property (copy)   NSString * title;
@property (strong) NSNumber * duration;
@property (strong) NSDate * scheduledDate;
@end
