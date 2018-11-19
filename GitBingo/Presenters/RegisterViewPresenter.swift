//
//  RegisterViewPresenter.swift
//  GitBingo
//
//  Created by 이동건 on 03/09/2018.
//  Copyright © 2018 이동건. All rights reserved.
//

import UIKit
import UserNotifications

protocol RegisterNotificationProtocol: class {
    func showAlert(alertState: GitBingoAlertState)
    func updateDescriptionLabel(with text: String)
    func dismissVC()
}

class RegisterViewPresenter {
    //MARK: Properties
    private weak var vc: RegisterNotificationProtocol?
    private let center = UNUserNotificationCenter.current()
    private var time: String
    private var removeNotificationCompletion: ((UIAlertAction)->())?
    
    private var hasScheduledNotification: Bool {
        guard let _ = GroupUserDefaults.shared.load(of: .notification) else { return false }
        return true
    }
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    //MARK: Life Cycle
    init() {
        self.time = dateFormatter.string(from: Date())
    }
    
    //MARK: Methods
    func attachView(_ vc: RegisterNotificationProtocol?) {
        self.vc = vc
    }
    
    func detatchView() {
        self.vc = nil
    }
    
    func setupTime(with date: Date) {
        self.time = dateFormatter.string(from: date)
    }
    
    func showAlert() {
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                let register = GitBingoAlertState.register(self.hasScheduledNotification, self.time, { _ in
                    self.vc?.dismissVC()
                    self.generateNotification()
                })
                self.vc?.showAlert(alertState: register)
            }else {
                self.vc?.showAlert(alertState: .unauthorized)
            }
        }
    }
    
    func updateScheduledNotificationIndicator() {
        if let time = GroupUserDefaults.shared.load(of: .notification) as? String {
            vc?.updateDescriptionLabel(with: "Scheduled at %@".localized(with: time))
            return
        }
        
        vc?.updateDescriptionLabel(with: "No Scheduled Notification so far".localized)
    }
    
    private func generateNotification() {
        guard let times = pasreTime(from: time) else { return }
        let content = UNMutableNotificationContent()
        content.title = "Wait!".localized
        content.body = "Did You Commit?🤔".localized
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        let userCalendar = Calendar.current
        var components = userCalendar.dateComponents([.hour, .minute], from: Date())
        
        components.hour = times.hour
        components.minute = times.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "GitBingo", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if ((error) != nil){
                self.vc?.showAlert(alertState: .registerFailed)
            }
            GroupUserDefaults.shared.save(self.time, of: .notification)
        }
    }
    
    func removeNotification() {
        if hasScheduledNotification {
            let remove = GitBingoAlertState.removeNotification { (_) in
                self.center.removeAllPendingNotificationRequests()
                GroupUserDefaults.shared.remove(of: .notification)
                self.updateScheduledNotificationIndicator()
            }
            
            self.vc?.showAlert(alertState: remove)
        }
    }
    
    private func pasreTime(from time: String) -> (hour: Int, minute: Int)? {
        let times = self.time.split(separator: ":").map {String($0)}
        guard let hour = Int(times[0]) else { return nil }
        guard let minute = Int(times[1]) else { return nil }
        return (hour, minute)
    }
}
