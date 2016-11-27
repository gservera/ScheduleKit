//
//  TestUser.h
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

@import Foundation;
@import ScheduleKit;

@interface TestUser : NSObject <SCKUser>

- (nonnull instancetype)initWithName:(nonnull NSString*)name
                               color:(nonnull NSColor*)color;

@property (nonnull, strong) NSString * name;
@property (nonatomic, readonly, strong) NSColor * _Nonnull eventColor;
@end
