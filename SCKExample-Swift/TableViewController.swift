//
//  TableViewController.swift
//  ScheduleKit
//
//  Created by Guillem Servera Negre on 2/11/16.
//  Copyright © 2016 Guillem Servera. All rights reserved.
//

import Cocoa
import ScheduleKit

final class TableCellView: NSTableCellView {
    @IBAction func editButtonClicked(_ sender: AnyObject) {
        if let tableView = self.superview?.superview as? NSTableView {
            let index = tableView.row(for: self)
            let set = IndexSet(integer: index)
            tableView.selectRowIndexes(IndexSet(set), byExtendingSelection: false)
            TableViewController.shared?.performSegue(withIdentifier: .edit, sender: sender)
        }
    }
}

final class TableViewController: NSViewController {

    static weak var shared: TableViewController?

    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        TableViewController.shared = self
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        view.window?.titlebarAppearsTransparent = true
        view.window?.titleVisibility = .hidden
    }

    var colorMode: SCKEventColorMode = .byEventKind

    @IBAction func changeColorMode(_ sender: NSButton) {
        if let parent = parent as? NSSplitViewController {
            colorMode = colorMode == .byEventKind ? .byEventOwner : .byEventKind
            if let dayViewController = parent.splitViewItems[1].viewController as? DayViewController {
                dayViewController.scheduleView.colorMode = colorMode
            }
            if let dayViewController = parent.splitViewItems[2].viewController as? WeekViewController {
                dayViewController.scheduleView.colorMode = colorMode
            }
        }
    }

    @IBAction func createNewEvent(_ sender: Any) {
        let testEvent = TestEvent(kind: .generic, user: EventEngine.shared.users[0], title: "New event", duration: 60,
                                  date: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!)
        EventEngine.shared.events.append(testEvent)
        EventEngine.shared.notifyUpdates()
        tableView.reloadData()
    }

    @IBAction func deleteSelectedEvent(_ sender: Any) {
        guard tableView.selectedRow != -1 else {
            return
        }
        EventEngine.shared.events.remove(at: tableView.selectedRow)
        EventEngine.shared.notifyUpdates()
    }

    private weak var clickedEditButton: NSButton?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        clickedEditButton = sender as? NSButton

        if segue.identifier == NSStoryboardSegue.Identifier.edit {
            let destination = SegueDescriptor<EditEventViewController>(segue: segue).destination
            destination.event = EventEngine.shared.events[tableView.selectedRow]
        }
    }

    override func present(_ viewController: NSViewController, asPopoverRelativeTo positioningRect: NSRect,
                                        of positioningView: NSView, preferredEdge: NSRectEdge,
                                        behavior: NSPopover.Behavior) {
        super.present(viewController, asPopoverRelativeTo: clickedEditButton!.frame,
                                    of: clickedEditButton!.superview!, preferredEdge: NSRectEdge.maxX,
                                    behavior: .transient)
    }
}

extension TableViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return EventEngine.shared.events.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return EventEngine.shared.events[row]
    }
}
