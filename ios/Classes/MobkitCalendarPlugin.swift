import Flutter
import UIKit
import EventKitUI

public class MobkitCalendarPlugin: NSObject, FlutterPlugin {
    static let shared = MobkitCalendarPlugin()
    let calendarManager = CalendarManager()
    let dateFormatter = DateFormatter()
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mobkit_calendar", binaryMessenger: registrar.messenger())
      let instance = MobkitCalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
      
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
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
