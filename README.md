<p align="center" >
 <img style="max-width:100%" src="https://gservera.com/cdn/sck/ScheduleKit2.png" alt="ScheduleKit" title="ScheduleKit">
 </p>
 
# ScheduleKit
 
![Platforms](https://img.shields.io/badge/platforms-macOS-blue.svg)
[![GitHub release](https://img.shields.io/github/release/gservera/schedulekit.svg)](https://github.com/gservera/ScheduleKit/releases) 
[![Build Status](https://travis-ci.org/gservera/ScheduleKit.svg?branch=master)](https://travis-ci.org/gservera/ScheduleKit) 
[![codecov.io](https://codecov.io/github/gservera/ScheduleKit/coverage.svg?branch=master)](https://codecov.io/github/gservera/ScheduleKit?branch=master)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/gservera/ScheduleKit/master/LICENSE.md) 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift version](https://img.shields.io/badge/swift-3.0-orange.svg)
 
ScheduleKit is a powerful graphical event management framework for macOS that provides a great way to display a set of event-like objects in either a day or week based timetable.

> ScheduleKit 2.0 has been completely rewritten and its workflow is way different in relation to the one present in previous releases. If you need source compatibility, please keep using the 1.0 release.

## Features

* **Easy and intuitive**. The `SCKViewController` class, which works like any other NSViewController, provides automatic event management with conflict handling. Just implement the `SCKEventManaging` protocol to add a bunch of events!
* **Change aware**. The schedule view observes the inserted events' date and duration using KVO, and repositions them whenever a change in these properties is observed.
* **Asynchronous, if you want**. `SCKViewController` supports asynchronously loading events by just changing the value of a property and implementing the appropiate method.
* **Built-in day/week navigation via IBAction connections** and **zooming** capability, either via IBAction connections and/or magnification gestures.
* **Customizable drag & drop** for events, with optional delegate methods that allow a more granular control over this feature.
* Plenty of customization points to allow even more customization, including unavailable time intervals, event coloring and more.

## How To Get Started

- [Download ScheduleKit](https://github.com/gservera/ScheduleKit/archive/master.zip) or install it using Carthage.
- Check out the [Documentation](https://gservera.com/docs/ScheduleKit/) for the SCKScheduleViewController class or just read the following section to begin quickly.


## First steps

### 🔶 Working with a Swift target

In a swift target, you may choose between creating a `SCKViewController` subclass or using the `SCKViewController` class itself as a child view controller of another view controller of your own. Just choose the approach that feels more confortable to you.

#### The subclassing approach

1. Create a new `SCKViewController` subclass. You can either use it programatically or add it to an Interface Builder storyboard or XIB file. You don't have to insert any `SCKView` instance nor any NSScrollView, that will be done automatically for you.
2. If you want to use a week view from the start (defaults is a day view), override the `loadView()` method to set your preference before the view is set up.
3. Override `viewWillAppear()` and:
   1. Set yourself as the controller's event manager.
   2. Set the initial date/time interval for your view.
   3. Optionally set yourself as the view's delegate.
   4. Add a call to either `reloadData()` if you are using multiple event classes or `reloadData(ofConcreteType)` for an easier implementation if you're using a single event class.
5. Implement the `SCKEventManaging` (or `SCKConcreteEventManaging`) data source method to provide events to the view. The choice will depend on the reload data method you're using in step 3.4. Check the documentation to learn more.

```swift
override func loadView() {
    mode = .week
    super.loadView()
}

override func viewWillAppear() {
    super.viewWillAppear()
    
    self.eventManager = self
    
    let calendar = Calendar.current
    let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
    let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
    scheduleView.dateInterval = DateInterval(start: start, end: end)
    
	scheduleView.delegate = self
	 
    reloadData(ofConcreteType: MyEventType.self)
}

let allEvents: [MyEventType] = [/* Some cool events */]

func concreteEvents(in dateInterval: DateInterval, 
                    for controller: SCKViewController) -> [MyEventType] {
    let filtered = allEvents.filter {$0.scheduledDate > dateInterval.start && $0.scheduledDate <= dateInterval.end}
    return filtered 
}
```

#### The child view controller approach

1. Add a `SCKViewController` instance as a child view controller of some other view controller. You can either do it programatically or add it to an Interface Builder storyboard or XIB file. If you do it in IB, be sure to add a blank NSView and configure it as its view, too.
2. If you want to use a week view from the start (defaults is a day view), make sure you set the `mode` property on the `SCKViewController` from your own view controller before the SCKViewController's view loads.
3. In your controller's `viewWillAppear()`, do the following:
   1. Set yourself as the controller's event manager.
   2. Set the initial date/time interval for your view.
   3. Optionally set yourself as the view's delegate.
   4. Add a call to either `reloadData()` if you are using multiple event classes or `reloadData(ofConcreteType)` for an easier implementation if you're using a single event class.
5. Implement the `SCKEventManaging` (or `SCKConcreteEventManaging`) data source method to provide events to the view. The choice will depend on the reload data method you're using in step 3.4. Check the documentation to learn more.

```swift
@IBOutlet weak var scheduleController: SCKViewController!

override func viewWillAppear() {
    super.viewWillAppear()
    
    scheduleController.eventManager = self
    
    let calendar = Calendar.current
    let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))!
    let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
    scheduleController.scheduleView.dateInterval = DateInterval(start: start, end: end)
    
	scheduleController.scheduleView.delegate = self
	 
    scheduleController.reloadData()
}

let meetings: [Meeting] = [/* Some cool events */]
let otherEvents: [OtherEvent] = [/* Some cool events */]

func events(in dateInterval: DateInterval, 
            for controller: SCKViewController) -> [SCKEvent] {
    let filteredMeetings = meetings.filter {$0.scheduledDate > dateInterval.start && $0.scheduledDate <= dateInterval.end}
    let filteredOther = otherEvents.filter {$0.scheduledDate > dateInterval.start && $0.scheduledDate <= dateInterval.end}
    return filteredMeetings + filteredOther
}
```


### 🔷 Working with an Objective-C target

ScheduleKit is written Swift but you can use it in your Objective-C targets taking a few considerations into account:

* You cannot use the subclassing approach, since Swift classes cannot be subclassed in Objective-C. Sorry for that :(
* You can't set the `SCKViewController`'s event manager using the `eventManager` property. Please use the `-setObjCDelegate:` method instead. 
* The `SCKConcreteEventManaging` protocol uses Swift generics and is not available.

```objc

- (void)viewWillAppear {
    [super viewWillAppear];
    
    [_scheduleController setObjCDelegate:self];
    [_scheduleController.scheduleView setDelegate:self];
    [self addChildViewController:_scheduleController];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSDate *dayStart = [cal dateBySettingHour:0 minute:0 second:0 ofDate:today options:0];
    NSDate *dayEnd = [cal dateBySettingHour:23 minute:59 second:59 ofDate:today options:0];
    NSDateInterval *interval = [[NSDateInterval alloc] initWithStartDate:dayStart endDate:dayEnd];
    [_scheduleController.scheduleView setDateInterval:interval];

    [_scheduleController reloadData];
}

@property (strong) IBOutlet SCKViewController * scheduleController;
```

## Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate ScheduleKit into your Xcode project using Carthage, specify it in your `cartfile`:

```ogdl
github "gservera/ScheduleKit" "master"
```

Run `carthage update` on your project's directory to build the framework and drag the built `ScheduleKit.framework` into your Xcode project.
 
##Ideas for the future
 
* Ability to create an event by clicking and dragging on a region of the view (thus, setting the corresponding start and end date values), as suggested by @ronnyek

## Requirements

* **Xcode**: 8.1 or greater.
* **Deployment target**: macOS 10.12

## Unit Tests

ScheduleKit includes a suite of unit tests within the ScheduleKitTests subdirectory. These tests can be run simply be executed the test action on the platform framework you would like to test.

## ☕️ Author

Guillem Servera, [https://gservera.com](https://gservera.com)

## License

ScheduleKit is released under the MIT license. See [LICENSE](https://github.com/gservera/ScheduleKit/blob/master/LICENSE.md) for details.
