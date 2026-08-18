import SwiftUI
import StoreKit

/// The bundled Tip Jar screen: loads tip products from a ``TipStore``, lets
/// the user pick and purchase one, and reports the outcome. Fully themeable
/// via `.tipJarTheme(_:)`; tier row rendering can be fully replaced via the
/// `tierContent` view builder.
public struct TipJarView<TierContent: View>: View {
    @Environment(\.tipJarTheme) private var theme
    @State private var loadState: LoadState = .loading
    @State private var purchasingIdentifier: String?
    @State private var showConfetti = false

    private let store: TipStore
    private let onCompletion: (TipJarCompletion) -> Void
    private let tierContent: (Product) -> TierContent

    private enum LoadState {
        case loading
        case loaded([Product])
        case failed(String)
    }

    /// - Parameters:
    ///   - store: The purchase engine to drive this view (typically `IndieAppGrowthKit.tipStore`).
    ///   - onCompletion: Called once per purchase attempt with its outcome.
    ///   - tierContent: Renders a single tip tier. Defaults to ``DefaultTierRow``.
    public init(
        store: TipStore,
        onCompletion: @escaping (TipJarCompletion) -> Void = { _ in },
        @ViewBuilder tierContent: @escaping (Product) -> TierContent
    ) {
        self.store = store
        self.onCompletion = onCompletion
        self.tierContent = tierContent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.metrics.spacing) {
            Text(theme.strings.tipJarTitle)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text(theme.strings.tipJarSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.secondaryText)

            content

            poweredByLink
        }
        .padding(theme.metrics.padding)
        .background(theme.colors.background)
        .overlay {
            if showConfetti {
                ConfettiView()
            }
        }
        .task { await load() }
    }

    @ViewBuilder
    private var content: some View {
        switch loadState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
        case .failed(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondaryText)
        case .loaded(let products):
            VStack(spacing: theme.metrics.spacing) {
                ForEach(products, id: \.id) { product in
                    Button {
                        Task { await purchase(product) }
                    } label: {
                        tierContent(product)
                    }
                    .buttonStyle(.plain)
                    .disabled(purchasingIdentifier != nil)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text(product.displayName))
                    .accessibilityValue(Text(product.displayPrice))
                    .accessibilityHint(Text(theme.strings.purchaseButtonTitle))
                }
            }
        }
    }

    private var poweredByLink: some View {
        Link(theme.strings.poweredByText, destination: IndieAppGrowthKitLinks.repository)
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.secondaryText)
    }

    private func load() async {
        do {
            try await store.start()
            loadState = .loaded(await store.products)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func purchase(_ product: Product) async {
        purchasingIdentifier = product.id
        defer { purchasingIdentifier = nil }
        do {
            let outcome = try await store.purchase(product)
            switch outcome {
            case .success:
                SuccessHaptic.play()
                showConfetti = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    showConfetti = false
                }
                onCompletion(.success(productIdentifier: product.id))
            case .cancelled:
                onCompletion(.cancelled)
            case .pending:
                onCompletion(.pending)
            }
        } catch {
            onCompletion(.failed(error.localizedDescription))
        }
    }
}

extension TipJarView where TierContent == DefaultTierRow {
    /// Convenience initializer using ``DefaultTierRow`` for tier rendering.
    public init(store: TipStore, onCompletion: @escaping (TipJarCompletion) -> Void = { _ in }) {
        self.init(store: store, onCompletion: onCompletion) { product in
            DefaultTierRow(product: product)
        }
    }
}
