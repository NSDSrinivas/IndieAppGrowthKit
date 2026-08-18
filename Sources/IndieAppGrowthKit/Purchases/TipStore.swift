import StoreKit

/// Owns the tip purchase lifecycle: loading tip products, submitting
/// purchases, verifying and finishing transactions, and restoring any
/// transactions StoreKit reports as unfinished (e.g. after a crash, or a
/// purchase that was approved while the app wasn't running, such as Ask to Buy).
public actor TipStore {
    private let storeProvider: any StoreProviding
    private let productIdentifiers: [String]
    private var transactionListenerTask: Task<Void, Never>?

    public private(set) var products: [Product] = []

    public init(productIdentifiers: [String], storeProvider: any StoreProviding = StoreKitProvider()) {
        self.productIdentifiers = productIdentifiers
        self.storeProvider = storeProvider
        self.transactionListenerTask = nil
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    /// Call once at launch: begins listening for transaction updates, restores
    /// any unfinished transactions, then loads products. Throws if product
    /// loading fails (e.g. no network), so the host app can show an error
    /// state rather than silently showing an empty Tip Jar.
    public func start() async throws {
        if transactionListenerTask == nil {
            transactionListenerTask = Task { [weak self] in
                await self?.listenForTransactionUpdates()
            }
        }
        await restoreUnfinishedTransactions()
        try await loadProducts()
    }

    public func loadProducts() async throws {
        products = try await storeProvider.products(for: productIdentifiers)
    }

    public func product(withIdentifier identifier: String) -> Product? {
        products.first { $0.id == identifier }
    }

    /// Submits a purchase for the given product. Throws only for genuine
    /// failures (declined payment, network error, StoreKit verification
    /// failure); cancellation and pending (e.g. Ask to Buy) are represented
    /// as ``TipPurchaseOutcome`` values, not errors.
    @discardableResult
    public func purchase(_ product: Product) async throws -> TipPurchaseOutcome {
        let result = try await storeProvider.purchase(product)
        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            await storeProvider.finish(transaction)
            return .success
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            return .cancelled
        }
    }

    /// Submits a purchase for the tip product matching `identifier`.
    @discardableResult
    public func purchase(identifier: String) async throws -> TipPurchaseOutcome {
        guard let product = product(withIdentifier: identifier) else {
            throw TipPurchaseError.productNotFound
        }
        return try await purchase(product)
    }

    private func restoreUnfinishedTransactions() async {
        for result in await storeProvider.unfinishedTransactions() {
            if let transaction = try? Self.checkVerified(result) {
                await storeProvider.finish(transaction)
            }
        }
    }

    private func listenForTransactionUpdates() async {
        for await result in storeProvider.transactionUpdates {
            if let transaction = try? Self.checkVerified(result) {
                await storeProvider.finish(transaction)
            }
        }
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw TipPurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}
