//
//  EventEngine.h
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

@import Foundation;

#import "TestUser.h"
#import "TestEvent.h"

@interface EventEngine : NSObject

+ (nonnull instancetype)sharedEngine;

@property (nonnull, readonly) NSArray<TestEvent*>* events;
@property (nonnull, readonly) NSArray<TestUser*>* users;
@end
