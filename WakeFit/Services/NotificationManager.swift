//
//  NotificationManager.swift
//  WakeFit
//
//  Service for managing all local notifications
//  Handles permission requests and scheduling 10 daily notifications
//

import Foundation
import UserNotifications

/// Manages all local notifications for discipline reminders
final class NotificationManager {

    // MARK: - Singleton

    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    /// Request notification permission from user
    /// Call this on first app launch after profile setup
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }

            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                completion(granted)
            }
        }
    }

    /// Check current notification authorization status
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Scheduling

    /// Schedule all 10 daily notifications
    func scheduleAllNotifications() {
        // Remove all existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // 1. 7:30 AM - Wake up reminder
        scheduleDailyNotification(
            hour: 7,
            minute: 30,
            title: "WakeFit",
            body: "Clock in your wake-up time.",
            identifier: "wakeup-daily"
        )

        // 2. Every 5th day 7:30 AM - Weight reminder
        scheduleWeightReminder()

        // 3. 1:30 PM - Calorie control
        scheduleDailyNotification(
            hour: 13,
            minute: 30,
            title: "Stay Controlled",
            body: "Not more than 700 calories before evening.",
            identifier: "calorie-1330"
        )

        // 4-8. 2:00 PM through 4:00 PM - Every 30 minutes (5 notifications)
        let times = [(14, 0), (14, 30), (15, 0), (15, 30), (16, 0)]
        for (hour, minute) in times {
            scheduleDailyNotification(
                hour: hour,
                minute: minute,
                title: "Calorie Check",
                body: "Stay disciplined. Track what you eat.",
                identifier: "calorie-\(hour)\(minute)"
            )
        }

        // 9. 4:30 PM - Move now
        scheduleDailyNotification(
            hour: 16,
            minute: 30,
            title: "Move Now",
            body: "Go out to play. Move now.",
            identifier: "move-1630"
        )

        // 10. 11:00 PM - Sleep reminder
        scheduleDailyNotification(
            hour: 23,
            minute: 0,
            title: "Sleep Protocol",
            body: "Start preparing to sleep. Target: before 11:50 PM.",
            identifier: "sleep-daily"
        )

        print("✅ All 10 notifications scheduled successfully")
    }

    /// Schedule a daily repeating notification
    private func scheduleDailyNotification(hour: Int, minute: Int, title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling \(identifier): \(error.localizedDescription)")
            }
        }
    }

    /// Schedule weight reminder every 5 days at 7:30 AM
    private func scheduleWeightReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Weight Check"
        content.body = "Time to log your weight. Track your progress."
        content.sound = .default

        // Create 5 separate notifications for next 30 days (every 5 days)
        let calendar = Calendar.current
        for dayOffset in stride(from: 5, through: 30, by: 5) {
            guard let triggerDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) else { continue }

            var dateComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate)
            dateComponents.hour = 7
            dateComponents.minute = 30

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "weight-day\(dayOffset)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling weight reminder: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Cancel all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }

    /// Get count of pending notifications (for debugging)
    func getPendingNotificationCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests.count)
            }
        }
    }
}
