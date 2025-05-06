public import SwiftUI

public extension ViewModelFeature {

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

  func bind<Value>(
    _ getValue: @escaping (Self) -> Value,
    storeIn bag: CancellationBag,
    withId cancellationId: AnyHashable? = nil,
    onChangeNotify event: UIEvent
  ) -> Binding<Value> {
    self.bind(getValue, storeIn: bag, withId: cancellationId, onChangeNotify: { _ in event })
  }
}
