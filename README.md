[![Build Status](https://travis-ci.org/gservera/ScheduleKit.svg?branch=master)](https://travis-ci.org/gservera/ScheduleKit)
 
ScheduleKit is a new graphical event management framework for Mac OS X that provides a great way to display a set of event-like objects (with basically starting date and duration properties) either a day or week based timetable.

#Features

* Automatic event management and layout via `SCKEventManager` using a data source pattern.
* Built-in event conflict management (though there's a lot to be done here yet!)
* Support for event objects' properties being changed at any time via key-value observing. This is great for event objects that are currently stored on a network database, provided that if an event changes on a remote computer, the grid automatically repositions it if needed.
* Built-in day/week navigation support via IBAction connections, with automatic event fetching from the data source object, too.
* Built-in zooming capability, either via IBAction connections or via gestures.
* Built-in event drag & drop support with optional delegate methods that allow customization of this behavior.

![ScheduleKit](https://www.aurumcode.com/medcode/ScheduleKit.png")

#Requirements

* OS X 10.10
* Xcode 6.

#Mantainers

* [Guillem Servera](htttp://github.com/gservera) ([@guiverane](http://twitter.com/guiverane))

#License

ScheduleKit is available under the MIT license. See the LICENSE file for more info.