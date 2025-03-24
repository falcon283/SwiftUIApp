private import SwiftAppUtilities
public import SwiftUI

public protocol ViewFeature: View {

  associatedtype UIEvent = Never

  nonmutating func notify(_ event: UIEvent) async
}

public extension ViewFeature {

  nonmutating func notify(_ event: UIEvent) {
    Task { await self.notify(event) }
  }
}

