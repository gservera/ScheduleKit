//
//  TestEvent.h
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

@import Foundation;
@import ScheduleKit;

#import "TestUser.h"

@interface TestEvent : NSObject <SCKEvent>

- (nonnull instancetype)initWithKind:(NSInteger)kind user:(nonnull TestUser*)user title:(nonnull NSString*)title duration:(NSInteger)duration date:(nonnull NSDate*)date;

+ (nonnull NSArray<TestEvent*>*)sampleEventsForUsers:(nonnull NSArray<TestUser*>*)users;

@property (nonatomic, readonly) NSInteger eventType;
@property (nonatomic, readonly, strong) id <SCKUser> _Nonnull user;
@property (nonatomic, readonly, copy) NSString * _Nonnull title;
@property (nonatomic) NSInteger duration;
@property (nonatomic, copy) NSDate * _Nonnull scheduledDate;
@end
