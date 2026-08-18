import SwiftUI

private struct TipJarThemeKey: EnvironmentKey {
    static let defaultValue = TipJarTheme.default
}

extension EnvironmentValues {
    /// The theme bundled IndieAppGrowthKit views read their appearance from.
    public var tipJarTheme: TipJarTheme {
        get { self[TipJarThemeKey.self] }
        set { self[TipJarThemeKey.self] = newValue }
    }
}

extension View {
    /// Applies a custom theme to every bundled IndieAppGrowthKit view in this
    /// view's subtree. Omit this modifier to use ``TipJarTheme/default``.
    public func tipJarTheme(_ theme: TipJarTheme) -> some View {
        environment(\.tipJarTheme, theme)
    }
}
