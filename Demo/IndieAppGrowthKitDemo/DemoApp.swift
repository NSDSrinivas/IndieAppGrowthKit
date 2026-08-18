import SwiftUI
import IndieAppGrowthKit

@main
struct DemoApp: App {
    init() {
        IndieAppGrowthKit.configure(
            .init(
                tipProductIdentifiers: [
                    "com.indieappgrowthkit.demo.tip.small",
                    "com.indieappgrowthkit.demo.tip.medium",
                    "com.indieappgrowthkit.demo.tip.large",
                ],
                appStoreID: "0000000000"
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
