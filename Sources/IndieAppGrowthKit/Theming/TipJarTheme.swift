import SwiftUI

/// Full look-and-feel configuration for every view the SDK bundles — colors,
/// typography, shape/spacing, and all user-facing copy. Every bundled view
/// reads its appearance from a `TipJarTheme` (via the `\.tipJarTheme`
/// environment value) rather than hardcoding any of it, so a host app can
/// restyle the SDK's UI to match its own design system.
public struct TipJarTheme: Equatable, Sendable {
    public struct Colors: Equatable, Sendable {
        public var background: Color
        public var surface: Color
        public var accent: Color
        public var primaryText: Color
        public var secondaryText: Color

        public init(
            background: Color,
            surface: Color,
            accent: Color,
            primaryText: Color,
            secondaryText: Color
        ) {
            self.background = background
            self.surface = surface
            self.accent = accent
            self.primaryText = primaryText
            self.secondaryText = secondaryText
        }
    }

    public struct Typography: Equatable, Sendable {
        public var title: Font
        public var body: Font
        public var price: Font
        public var caption: Font

        public init(title: Font, body: Font, price: Font, caption: Font) {
            self.title = title
            self.body = body
            self.price = price
            self.caption = caption
        }
    }

    public struct Metrics: Equatable, Sendable {
        public var cornerRadius: CGFloat
        public var spacing: CGFloat
        public var padding: CGFloat

        public init(cornerRadius: CGFloat, spacing: CGFloat, padding: CGFloat) {
            self.cornerRadius = cornerRadius
            self.spacing = spacing
            self.padding = padding
        }
    }

    /// All user-facing copy for the bundled UI, overridable so a host app can
    /// localize or restyle wording without forking the view.
    public struct Strings: Equatable, Sendable {
        public var tipJarTitle: String
        public var tipJarSubtitle: String
        public var purchaseButtonTitle: String
        public var poweredByText: String

        public init(
            tipJarTitle: String,
            tipJarSubtitle: String,
            purchaseButtonTitle: String,
            poweredByText: String
        ) {
            self.tipJarTitle = tipJarTitle
            self.tipJarSubtitle = tipJarSubtitle
            self.purchaseButtonTitle = purchaseButtonTitle
            self.poweredByText = poweredByText
        }
    }

    public var colors: Colors
    public var typography: Typography
    public var metrics: Metrics
    public var strings: Strings

    public init(colors: Colors, typography: Typography, metrics: Metrics, strings: Strings) {
        self.colors = colors
        self.typography = typography
        self.metrics = metrics
        self.strings = strings
    }

    /// The theme every bundled view uses unless the host app supplies its own.
    public static let `default` = TipJarTheme(
        colors: Colors(
            background: Color(.sRGB, white: 1, opacity: 1),
            surface: Color(.sRGB, white: 0.95, opacity: 1),
            accent: .accentColor,
            primaryText: .primary,
            secondaryText: .secondary
        ),
        typography: Typography(
            title: .title2.bold(),
            body: .body,
            price: .headline,
            caption: .caption
        ),
        metrics: Metrics(cornerRadius: 12, spacing: 12, padding: 16),
        strings: Strings(
            tipJarTitle: "Support this app",
            tipJarSubtitle: "If you're enjoying the app, consider leaving a tip.",
            purchaseButtonTitle: "Tip",
            poweredByText: "Powered by Indie App Growth Kit"
        )
    )
}
