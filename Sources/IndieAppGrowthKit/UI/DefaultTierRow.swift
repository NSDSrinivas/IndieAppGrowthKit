import SwiftUI
import StoreKit

/// The default rendering of a single tip tier, used by ``TipJarView`` unless
/// the host app supplies its own `tierContent` view builder.
public struct DefaultTierRow: View {
    @Environment(\.tipJarTheme) private var theme
    private let product: Product

    public init(product: Product) {
        self.product = product
    }

    public var body: some View {
        HStack {
            Text(product.displayName)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.primaryText)
            Spacer()
            Text(product.displayPrice)
                .font(theme.typography.price)
                .foregroundStyle(theme.colors.accent)
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.surface, in: RoundedRectangle(cornerRadius: theme.metrics.cornerRadius))
    }
}
