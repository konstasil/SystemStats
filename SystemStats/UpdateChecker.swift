import Foundation
import Combine
import AppKit
import UserNotifications

class UpdateChecker: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var hasUpdate = false
    @Published var latestVersion = ""
    @Published var downloadURL = ""

    private let repoOwner = "konstasiil"
    private let repoName = "SystemStats"
    private let currentVersion = "1.0"

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermission()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func checkForUpdates() {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String else {
                return
            }

            let latestVersion = tagName.replacingOccurrences(of: "v", with: "")

            DispatchQueue.main.async {
                self.latestVersion = latestVersion
                self.hasUpdate = self.isNewerVersion(latestVersion)

                if let assets = json["assets"] as? [[String: Any]],
                   let dmg = assets.first(where: { ($0["name"] as? String ?? "").hasSuffix(".dmg") }),
                   let url = dmg["browser_download_url"] as? String {
                    self.downloadURL = url
                }

                if self.hasUpdate {
                    self.showUpdateNotification()
                }
            }
        }.resume()
    }

    private func isNewerVersion(_ remoteVersion: String) -> Bool {
        let current = currentVersion.split(separator: ".").map { Int($0) ?? 0 }
        let remote = remoteVersion.split(separator: ".").map { Int($0) ?? 0 }

        for i in 0..<max(current.count, remote.count) {
            let c = i < current.count ? current[i] : 0
            let r = i < remote.count ? remote[i] : 0
            if r > c { return true }
            if r < c { return false }
        }
        return false
    }

    private func showUpdateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "SystemStats"
        content.body = String(format: NSLocalizedString("update.notification.body", comment: ""), latestVersion)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "update-available",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func openDownloadPage() {
        let urlString: String
        if !downloadURL.isEmpty {
            urlString = downloadURL
        } else {
            urlString = "https://github.com/\(repoOwner)/\(repoName)/releases/latest"
        }

        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "open" {
            openDownloadPage()
        }
        completionHandler()
    }
}
