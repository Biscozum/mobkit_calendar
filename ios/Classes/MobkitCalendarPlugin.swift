import Flutter
import UIKit
import EventKitUI

public class MobkitCalendarPlugin: NSObject, FlutterPlugin {
    static let shared = MobkitCalendarPlugin()
    let calendarManager = CalendarManager()
    let dateFormatter = DateFormatter()
    let eventStore = EKEventStore()
    private var permissionResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mobkit_calendar", binaryMessenger: registrar.messenger())
        let instance = MobkitCalendarPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    
    private func hasPermissions() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        if #available(iOS 17, *) {
            return status == EKAuthorizationStatus.fullAccess
        } else {
            return status == EKAuthorizationStatus.authorized
        }
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        var isGranted = false
        var permissionGranted = false
        if hasPermissions() {
            completion(true)
            return
        }
        if #available(iOS 17, *) {
            eventStore.requestFullAccessToEvents {
                (granted: Bool, _: Error?) in
                isGranted = granted
                permissionGranted = true
            }
            while !permissionGranted {
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
            }
            completion(isGranted)
        } else {
            eventStore.requestAccess(to: .event, completion: {
                (granted: Bool, _: Error?) in
                isGranted = granted
                permissionGranted = true
            })
            while !permissionGranted {
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.1))
            }
            completion(isGranted)
        }
    }
    
    private func getSource() -> EKSource? {
        let localSources = eventStore.sources.filter { $0.sourceType == .local }
        
        if (!localSources.isEmpty) {
            return localSources.first
        }
        
        if let defaultSource = eventStore.defaultCalendarForNewEvents?.source {
            return defaultSource
        }
        
        let iCloudSources = eventStore.sources.filter { $0.sourceType == .calDAV && $0.sourceIdentifier == "iCloud" }
        
        if (!iCloudSources.isEmpty) {
            return iCloudSources.first
        }
        
        return nil
    }
    private func createCalendar(_ call: FlutterMethodCall, _ result: FlutterResult) {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let calendar = EKCalendar.init(for: EKEntityType.event, eventStore: eventStore)
        do {
            calendar.title = arguments["calendarName"] as! String
            let calendarColor = arguments["calendarColor"] as? String
            
            if (calendarColor != nil) {
                calendar.cgColor = UIColor(named: calendarColor!)?.cgColor
            }
            else {
                calendar.cgColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0).cgColor // Red colour as a default
            }
            
            guard let source = getSource() else {
                result(false)
                return
            }
            
            calendar.source = source
            
            try eventStore.saveCalendar(calendar, commit: true)
            result(!calendar.calendarIdentifier.isEmpty)
        }
        catch {
            eventStore.reset()
            result(false)
        }
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "addCalendar":
            createCalendar(call, result)
        case "requestPermissions":
            if(!hasPermissions()) {
                requestPermissions(completion: result )
            }
            result(hasPermissions())
        case "addNativeEvent":
            let arguments = call.arguments as! Dictionary<String, AnyObject>
            let argCalendarId = arguments["calendarId"] as! String
            let argEventId = arguments["eventId"] as? String
            let argTitle = arguments["title"] as! String
            let argDescription = arguments["desc"] as! String
            let argStartDate = arguments["startDate"] as! Int64
            let argEndDate = arguments["endDate"] as! Int64
            let argLocation = arguments["location"] as? String
            let argIsAllDay = arguments["allDay"] as! Bool
            let argUrl = arguments["url"] as? String
            var eventId = argEventId
            let title = argTitle
            let description = argDescription
            let startDate = Date (timeIntervalSince1970: Double(argStartDate) / 1000.0)
            let endDate = Date (timeIntervalSince1970: Double(argEndDate) / 1000.0)
            let location = argLocation
            let isAllDay = argIsAllDay
            let ekCalendar = self.eventStore.calendar(withIdentifier: argCalendarId)
            let url = argUrl
            var ekEvent: EKEvent?
            if(eventId == nil) {
                ekEvent = EKEvent.init(eventStore: self.eventStore)
            } else {
                ekEvent = self.eventStore.event(withIdentifier: eventId!)
            }
            ekEvent!.title = title
            ekEvent!.notes = description
            ekEvent!.startDate = startDate
            ekEvent!.endDate = endDate
            ekEvent!.calendar = ekCalendar!
            ekEvent!.isAllDay = isAllDay
            
            if(location != nil) {
                ekEvent!.location = location
            }
            
            if(url != nil) {
                ekEvent!.url = URL(string: url ?? "")
            }
            
            do {
                try self.eventStore.save(ekEvent!, span: .futureEvents)
                eventId = ekEvent!.eventIdentifier
            } catch {
                self.eventStore.reset()
            }
            result(eventId != nil)
        case "openEventDetail":
            if let args = call.arguments as? Dictionary<String, Any>
            {
                calendarManager.openEventDetail(isoDate: (args["isoDate"] as! String))
                result(true)
            }
        case "requestCalendarAccess":
            calendarManager.requestCalendarAccess { granted in
                result(String(granted))
            }
        case "getEventList":
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            
            if let args = call.arguments as? Dictionary<String, Any>
            {
                let startDate = dateFormatter.date(from: args["startDate"] as! String);
                let endDate = dateFormatter.date(from: args["endDate"] as! String);
                calendarManager.fetchCalendarEvents(startDate: startDate!, endDate: endDate!, selectedIdList: args["idlist"] as! [String]) { events in
                    let mappedEvents = events.map { event in
                        var mappedEvent: [String: Any] = [:]
                        mappedEvent["nativeEventId"] = event.eventIdentifier
                        mappedEvent["fullName"] = event.title
                        mappedEvent["startDate"] = self.dateFormatter.string(for: event.startDate)
                        mappedEvent["endDate"] = self.dateFormatter.string(for:event.endDate)
                        mappedEvent["description"] = event.description
                        mappedEvent["isFullDayEvent"] = event.isAllDay
                        return mappedEvent
                    }
                    let events : [String : Any] = ["events" : mappedEvents];
                    result(String(decoding: try! JSONSerialization.data(withJSONObject: events	),as: UTF8.self))}
            }
        case "getAccountList":
            calendarManager.fetchCalendarAccounts { calendars in
                let mappedCalendars = calendars.map { calendar in
                    var mappedCalendar: [String: Any] = [:]
                    mappedCalendar["groupName"] = calendar.source.title;
                    mappedCalendar["accountId"] = calendar.calendarIdentifier;
                    mappedCalendar["accountName"] = calendar.title;
                    mappedCalendar["isChecked"] = false;
                    return mappedCalendar
                }
                let accounts : [String : Any] = ["accounts" : mappedCalendars];
                
                
                result(String(decoding: try! JSONSerialization.data(withJSONObject: accounts),as: UTF8.self))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class CalendarManager {
    let eventStore = EKEventStore()
    
    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            completion(granted)
        }
    }
    
    func fetchCalendarEvents(startDate: Date, endDate: Date, selectedIdList : [String], completion: @escaping ([EKEvent]) -> Void) {
        let calendars = eventStore.calendars(for: .event)
        let startDate = startDate
        let endDate = endDate
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars.filter {
            selectedIdList.contains($0.calendarIdentifier)
        })
        let events = eventStore.events(matching: predicate)
        completion(events)
    }
    func fetchCalendarAccounts(completion: @escaping ([EKCalendar]) -> Void) {
        let calendars = eventStore.calendars(for: .event)
        completion(calendars)
    }
    func openEventDetail(isoDate: String) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = ISO8601DateFormatter.Options.withInternetDateTime.subtracting(.withTimeZone)
        if let date = dateFormatter.date(from:isoDate) {
            let interval = date.timeIntervalSinceReferenceDate
            guard let url = URL(string: "calshow:\(interval)") else {return}
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else
        {return}
    }
}

