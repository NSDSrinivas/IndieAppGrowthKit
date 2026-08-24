import SwiftUI

/// Cross-platform toolbar placements shared by the bundled sheets, since
/// `.topBarLeading`/`.topBarTrailing` only exist on iOS/tvOS.
var leadingButtonPlacement: ToolbarItemPlacement {
    #if os(iOS) || os(tvOS)
    .topBarLeading
    #else
    .navigation
    #endif
}

var trailingButtonPlacement: ToolbarItemPlacement {
    #if os(iOS) || os(tvOS)
    .topBarTrailing
    #else
    .primaryAction
    #endif
}
