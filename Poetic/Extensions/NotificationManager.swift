//
//  NotificationManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/27.
//
import SwiftUI
import UserNotifications


class NotificationManager: ObservableObject {
    
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    func addNotification() {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Come read some poems!"
            content.subtitle = "Thousands of poems at the tip of your fingers."
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    }
                }
            }
        }
    }
    
}
