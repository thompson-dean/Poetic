//
//  NotificationManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/27.
//
import SwiftUI
import UserNotifications

struct NotificationObject: Decodable {
    let author: String
    let quote: String
}

class NotificationManager: ObservableObject {
    private let notifications: [NotificationObject] = [
        NotificationObject(
            author: "Mark Twain",
            quote: "Two roads diverged in a yellow wood, And sorry I could not travel both..."
        ),
        NotificationObject(
            author: "Walt Whitman",
            quote: "Resist much, obey little..."
        ),
        NotificationObject(
            author: "William Shakespeare",
            quote: "I like this place and could willingly waste my time in it..."
        ),
        NotificationObject(
            author: "Emily Dickinson",
            quote: "If I read a book and it makes my whole body so cold no fire can warm me..."
        ),
        NotificationObject(
            author: "William Wordsworth",
            quote: "I wandered lonely as a cloud That floats on high o'er vales and hills..."
        ),
        NotificationObject(
            author: "Charlotte Bronte",
            quote: "So dark as sages say; Oft a little morning rain..."
        ),
        NotificationObject(
            author: "Edgar Allan Poe",
            quote: "Once upon a midnight dreary, while I pondered, weak and weary..."
        )
    ]

    @AppStorage("notificationsOn") var notificationOn = true

    let center = UNUserNotificationCenter.current()

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        center.requestAuthorization(options: options) { _, error in
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
        guard let randomNotification = notifications.randomElement() else { return }

        content.title = "\(randomNotification.author) awaits you"
        content.subtitle = randomNotification.quote
        content.sound = .default
        content.badge = 1

        var mondayComponents = DateComponents()
        mondayComponents.hour = 9
        mondayComponents.weekday = 2
        let mondayTrigger = UNCalendarNotificationTrigger(dateMatching: mondayComponents, repeats: true)
        let mondayRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: mondayTrigger
        )

        var fridayComponents = DateComponents()
        fridayComponents.hour = 9
        fridayComponents.weekday = 6
        let fridayTrigger = UNCalendarNotificationTrigger(dateMatching: fridayComponents, repeats: true)
        let fridayRequest = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: fridayTrigger
        )

        center.add(mondayRequest)
        center.add(fridayRequest)
    }

    func deleteNotification() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        print("All notifications removed")
    }
}
