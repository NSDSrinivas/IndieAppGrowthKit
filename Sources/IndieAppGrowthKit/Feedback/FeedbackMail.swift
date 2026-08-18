import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Opens the user's default mail client with a feedback email pre-addressed
/// and pre-filled, via a `mailto:` link. Deliberately not built on
/// `MFMailComposeViewController` (which requires Message UI entitlements,
/// only works when Mail is configured, and needs a `UIViewControllerRepresentable`
/// + delegate to bridge into SwiftUI): a `mailto:` link works everywhere the
/// user has *any* mail app configured, on both platforms, with a much smaller
/// surface for bugs — the tradeoff is it hands off to the Mail app rather
/// than composing in-place.
public enum FeedbackMail {
    /// Opens a mail composer addressed to `email`, with `subject` and `body`
    /// pre-filled. Returns `false` if no URL could be constructed or the
    /// platform couldn't open it (e.g. no mail app configured).
    @discardableResult
    @MainActor
    public static func openComposer(to email: String, subject: String, body: String) -> Bool {
        guard let url = composeURL(to: email, subject: subject, body: body) else { return false }
        #if canImport(UIKit)
        UIApplication.shared.open(url)
        return true
        #elseif canImport(AppKit)
        return NSWorkspace.shared.open(url)
        #else
        return false
        #endif
    }

    static func composeURL(to email: String, subject: String, body: String) -> URL? {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=")
        guard let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: allowed),
              let encodedBody = body.addingPercentEncoding(withAllowedCharacters: allowed) else {
            return nil
        }
        return URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)")
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
