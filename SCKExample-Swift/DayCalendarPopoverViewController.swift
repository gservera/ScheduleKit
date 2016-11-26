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
        datePicker.dateValue = dayView.startDate
        todayButton.target = dayView
        todayButton.action = #selector(SCKDayView.resetDayOffset(sender:))
    }
    
    @IBAction func datePickerValueChanged(_ sender: NSDatePicker) {
        let calendar = Calendar.current
        let sD = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: sender.dateValue)
        let eD = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: sender.dateValue)
        dayView.setDateBounds(lower: sD!, upper: eD!)
        dayView.controller.reloadData(ofConcreteType: TestEvent.self)
    }
}
