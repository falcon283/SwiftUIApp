public import SwiftUI

public extension ViewModelFeature {

  /// This helper function is used to create a special Binding from the `ViewModelFeature` itself.
  ///
  /// You use this function only if you decided to use the `ViewModel` pattern with SwiftUI.
  /// It must be used in replacement of regular SwiftUI Bindings derived from `@State` and similar properties.
  /// The reason behind is we want always to use ``notify(_:)-lxi5`` function to run the associated Business Logic so to enable Unidirectional Data Flow.
  ///
  /// - Parameters:
  ///   - getValue: A function returning the value to track down. Also keyPath .
  ///   - cancellationId: An optional id to keep track of the cancellation.
  ///   - bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  ///   - onChangeNotify: A closure that map the latest value received from SwiftUI to embed into an event that is sent to the `ViewModelFeature`
  ///   via `notify(_:)` function.
  /// 
  /// - Returns: The binding to pass to SwiftUI.
  /// - Note: For maximum control over cancellation and assure it's 100% deterministic it's highly recommended to inject your own `cancellationId`.
  /// If you don't pass an id, an internal one gets generated on the event basis using Mirror.
  func bind<Value>(
    _ getValue: @escaping (Self) -> Value,
    storeIn bag: CancellationBag,
    withId cancellationId: AnyHashable? = nil,
    onChangeNotify: @escaping (Value) -> UIEvent
  ) -> Binding<Value> {
    Binding(
      get: { getValue(self) },
      set: { newValue in self.notify(onChangeNotify(newValue), storeIn: bag, withId: cancellationId) }
    )
  }

  /// This helper function is used to create a special Binding from the `ViewModelFeature` itself.
  ///
  /// You use this function only if you decided to use the `ViewModel` pattern with SwiftUI.
  /// It must be used in replacement of regular SwiftUI Bindings derived from `@State` and similar properties.
  /// The reason behind is we want always to use ``notify(_:)-lxi5`` function to run the associated Business Logic so to enable Unidirectional Data Flow.
  ///
  /// - Parameters:
  ///   - getValue: A function returning the value to track down. Also keyPath .
  ///   - cancellationId: An optional id to keep track of the cancellation.
  ///   - bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  ///   - event: The event to send the `ViewModelFeature`
  ///   via `notify(_:)` function
  /// 
  /// - Returns: The binding to pass to SwiftUI.
  /// - Note: For maximum control over cancellation and assure it's 100% deterministic it's highly recommended to inject your own `cancellationId`.
  /// If you don't pass an id, an internal one gets generated on the event basis using Mirror.
  func bind<Value>(
    _ getValue: @escaping (Self) -> Value,
    storeIn bag: CancellationBag,
    withId cancellationId: AnyHashable? = nil,
    onChangeNotify event: UIEvent
  ) -> Binding<Value> {
    self.bind(getValue, storeIn: bag, withId: cancellationId, onChangeNotify: { _ in event })
  }
}
