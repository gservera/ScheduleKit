//
//  TestUser.h
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016-2017 Guillem Servera. All rights reserved.
//

@import ScheduleKit;

NS_ASSUME_NONNULL_BEGIN

@interface TestUser : NSObject <SCKUser>

- (instancetype)initWithName:(NSString*)name color:(NSColor*)color;

@property (nonnull, strong) NSString * name;
@property (nonatomic, readonly, strong) NSColor * eventColor;
@end

NS_ASSUME_NONNULL_END
