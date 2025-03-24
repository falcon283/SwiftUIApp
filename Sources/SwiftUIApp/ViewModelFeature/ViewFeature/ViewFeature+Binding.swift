import SwiftUI

public extension ViewFeature {

  nonmutating func bind<Value>(
    _ getValue: @escaping (Self) -> Value,
    onChangeNotify: @escaping (Value) -> UIEvent
  ) -> Binding<Value> {
    Binding(
      get: { getValue(self) },
      set: { newValue in self.notify(onChangeNotify(newValue)) }
    )
  }

  nonmutating func bind<Value>(
    _ getValue: @escaping (Self) -> Value,
    onChangeNotify event: UIEvent
  ) -> Binding<Value> {
    self.bind(getValue, onChangeNotify: { _ in event })
  }
}
