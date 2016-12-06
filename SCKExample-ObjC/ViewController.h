//
//  ViewController.h
//  SCKExample-ObjC
//
//  Created by Guillem Servera Negre on 14/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

@import Cocoa;
@import ScheduleKit;

@interface ViewController : NSViewController <SCKEventManaging, SCKGridViewDelegate>


@property (nonatomic, strong) IBOutlet SCKViewController * scheduleController;
@end

