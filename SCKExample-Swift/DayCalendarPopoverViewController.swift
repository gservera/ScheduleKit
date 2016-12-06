//
//  DayCalendarPopoverViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 15/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

class DayCalendarPopoverViewController: NSViewController {

    weak var dayView: SCKDayView!
    
    @IBOutlet var todayButton: NSButton!
    @IBOutlet var datePicker: NSDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.dateValue = dayView.dateInterval.start
        todayButton.target = dayView.controller
        todayButton.action = #selector(SCKViewController.resetOffset(_:))
    }
    
    @IBAction func datePickerValueChanged(_ sender: NSDatePicker) {
        let calendar = Calendar.current
        let sD = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: sender.dateValue)
        let eD = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: sender.dateValue)
        dayView.dateInterval = DateInterval(start: sD!, end: eD!)
        dayView.controller.reloadData(ofConcreteType: TestEvent.self)
    }
}
