import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Opens the user’s email client via `mailto:`. The host app owns the button or settings entry.
public enum FeedbackMail {
    /// Opens email support using the configured recipient. No-op if none was provided.
    /// Returns whether the request was handed to the system, not whether email was sent.
    @discardableResult
    @MainActor
    public static func openComposer(subject: String = "Feedback", body: String = "") -> Bool {
        openComposer(to: IndieAppGrowthKit.supportEmail, subject: subject, body: body)
    }

    /// Opens email support using an explicitly supplied recipient.
    /// Returns false for missing/invalid recipients or an unavailable mail client.
    @discardableResult
    @MainActor
    public static func openComposer(to email: String?, subject: String = "Feedback", body: String = "") -> Bool {
        guard let url = composeURL(to: email, subject: subject, body: body) else { return false }
        #if canImport(UIKit)
        guard UIApplication.shared.canOpenURL(url) else { return false }
        UIApplication.shared.open(url)
        return true
        #elseif canImport(AppKit)
        return NSWorkspace.shared.open(url)
        #else
        return false
        #endif
    }

    static func composeURL(to email: String?, subject: String, body: String) -> URL? {
        guard let email = email?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else { return nil }
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, parts.allSatisfy({ !$0.isEmpty }),
              email.rangeOfCharacter(from: .whitespacesAndNewlines) == nil,
              email.rangeOfCharacter(from: .controlCharacters) == nil,
              email.rangeOfCharacter(from: CharacterSet(charactersIn: "?,;<>")) == nil else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = email
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }

    /// A default feedback body prefilled with app/device diagnostics, so the
    /// user doesn't have to type their app version/OS version themselves.
    public static func diagnosticsBody(extra: String = "") -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        #if canImport(UIKit)
        let osVersion = UIDevice.current.systemVersion
        let osName = UIDevice.current.systemName
        #else
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let osName = "macOS"
        #endif
        var body = extra
        if !body.isEmpty { body += "\n\n" }
        body += "---\nApp version: \(appVersion) (\(buildNumber))\nOS: \(osName) \(osVersion)"
        return body
    }
}
