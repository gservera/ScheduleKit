//
//  SCKTextField.h
//  ScheduleKit
//
//  Created by Guillem on 1/1/15.
//  Copyright (c) 2015 Guillem Servera. All rights reserved.
//

@import Cocoa;

@interface SCKTextFieldCell : NSTextFieldCell {
    BOOL _editingOrSelected;
}

@end

@interface SCKTextField : NSTextField

@end
