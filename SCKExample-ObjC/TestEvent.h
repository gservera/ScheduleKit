//
//  TestEvent.h
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016-2017 Guillem Servera. All rights reserved.
//

@import ScheduleKit;

#import "TestUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface TestEvent : NSObject <SCKEvent>

- (instancetype)initWithKind:(NSInteger)kind user:(TestUser*)user title:(NSString*)title components:(NSDateComponents*)date;
+ (NSArray<TestEvent*>*)sampleEventsForUsers:(NSArray<TestUser*>*)users;

@property (nonatomic, readonly) NSInteger eventKind;
@property (nonatomic, readonly, strong) id <SCKUser> user;
@property (nonatomic, readonly, copy) NSString * title;
@property (nonatomic) NSInteger duration;
@property (nonatomic, copy) NSDate * scheduledDate;
@end


NS_ASSUME_NONNULL_END
