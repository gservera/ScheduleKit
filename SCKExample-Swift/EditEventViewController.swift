//
//  EditEventViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 26/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa

class EditEventViewController: NSViewController {

    @objc weak var event: TestEvent!
    @IBOutlet var userPopUp: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        userPopUp.selectItem(at: EventEngine.shared.users.index(of: event.testUser)!)
    }

    @IBAction func usePopUpChanged(_ sender: NSPopUpButton) {
        let targetUser = EventEngine.shared.users[sender.indexOfSelectedItem]
        event.willChangeValue(forKey: "user")
        event.user = targetUser
        event.didChangeValue(forKey: "user")
    }
}
