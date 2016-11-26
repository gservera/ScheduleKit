/*
 *  SCKEvent.swift
 *  ScheduleKit
 *
 *  Created:    Guillem Servera on 24/12/2014.
 *  Copyright:  © 2014-2016 Guillem Servera (http://github.com/gservera)
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */


/**
 *  The SCKUser protocol declares the expected interface for SCKEvent's @c user
 *  property values.
 */
@objc public protocol SCKUser: class {
    /**
     *  This method or property should return a color that will be used to draw SCKEventView's
     *  background when color mode is set to 'by user'.
     *  @return The requested NSColor object.
     */
    @objc var labelColor: ColorClass { get }
}



/** A set of values used to distinguish between different event types.
 *  Actual values are related to different events on the medical field, since this
 *  framework was first intended to be used with medical apps, but feel free to include
 *  any other event types you need (try to keep the default and special values though). */
public enum SCKEventKind: Int {
    case generic  /**< A generic type of event. */
    
    case visit
    case surgery
    
    //Feel free to add any event types you need here.
    case transitory = -1 /**< A special event type for transitory events */
}



/**
 *  The SCKEvent protocol declares the expected interface for objects being represented
 *  in any of the SCKView subclasses, that is, the set of methods needed for an object
 *  to be considered a valid ScheduleKit event.
 */
@objc public protocol SCKEvent: NSObjectProtocol {
    
    /**
     *  This method or property should return an event type that will be used to draw
     *  SCKEventView's background when color mode is set to 'by event type'
     *  @return The requested SCKEventType value
     */
    @objc var eventType: Int { get }
    
    /**
     *  This method or property should return the user object associated with the event,
     *  that is, the event's owner.
     *  @return The requested user object. It must conform to the @c SCKUser protocol.
     */
    @objc var user: SCKUser { get }
    
    /**
     *  This method or property should return the string that will be drawn inside of the
     *  SCKEventView's frame, which allows the user to better identify each event.
     *  @return The requested NSString object.
     */
    @objc var title: String { get }
    
    /**
     *  Returns the event's duration in minutes.
     *  @return A NSNumber object representing the event duration in minutes.
     */
    @objc var duration: Int { get set }
    
    /**
     *  Returns the event's date and time.
     *  @return A NSDate object representing the event's start date.
     */
    @objc var scheduledDate: Date { get set }
}
