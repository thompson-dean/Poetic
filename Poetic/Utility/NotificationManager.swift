//
//  NotificationManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/27.
//
import SwiftUI
import UserNotifications


class NotificationManager: ObservableObject {
    private let authors: Authors = Bundle.main.decode("Authors.json")
    
    @AppStorage("notificationOn") var notificationOn = true
    
    let center = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { success, error in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            } else {
                self.deleteNotification()
                self.addNotification()
            }
        }
    }
    
    
    func addNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(authors.authors.randomElement() ?? Constants.appName) awaits you"
        content.subtitle = "Come read some poems."
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
 
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger)
        
        center.add(request)
        
    }
    
    func deleteNotification() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
}
