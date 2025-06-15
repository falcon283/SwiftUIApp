#if canTestSwiftUI
public import SwiftUI

/// A dynamic property that scales a numeric value.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper public struct ScaledMetric<Value> : DynamicProperty where Value : BinaryFloatingPoint {

  private var storage: SwiftUI.ScaledMetric<Value>

  private let testValue: Value

  /// Creates the scaled metric with an unscaled value and a text style to
  /// scale relative to.
  public init(wrappedValue: Value, relativeTo textStyle: Font.TextStyle) {
    self.storage = SwiftUI.ScaledMetric(wrappedValue: wrappedValue, relativeTo: textStyle)
    self.testValue = wrappedValue
  }

  /// Creates the scaled metric with an unscaled value using the default
  /// scaling.
  public init(wrappedValue: Value) {
    self.storage = SwiftUI.ScaledMetric(wrappedValue: wrappedValue)
    self.testValue = wrappedValue
  }

  /// The value scaled based on the current environment.
  public var wrappedValue: Value {
    TestSupport.isRunningUnitTest ? self.testValue : self.storage.wrappedValue
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension ScaledMetric : Sendable where Value : Sendable {
}
#endif
