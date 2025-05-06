public import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct FocusedValueViaBindingModifier<Value: Hashable>: ViewModifier {

  let focusState: SwiftUI.FocusState<Value?>.Binding
  let modelState: Binding<Value?>
  let equals: Value
  let onFocusChanged: (Value?) -> Void

  func body(content: Content) -> some View {
    content
      .focused(self.focusState, equals: self.equals)
      .synchronizeFocuses(
        focusState: self.focusState,
        modelState: self.modelState,
        focusLostValue: nil,
        onFocusChanged: self.onFocusChanged
      )
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct FocusedBoolViaBindingModifier: ViewModifier {

  let focusState: SwiftUI.FocusState<Bool>.Binding
  let modelState: Binding<Bool>
  let onFocusChanged: (Bool) -> Void

  func body(content: Content) -> some View {
    content
      .focused(self.focusState)
      .synchronizeFocuses(
        focusState: self.focusState,
        modelState: self.modelState,
        focusLostValue: false,
        onFocusChanged: self.onFocusChanged
      )
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension View {
  func synchronizeFocuses<Value: Hashable>(
    focusState: SwiftUI.FocusState<Value>.Binding,
    modelState: Binding<Value>,
    focusLostValue: Value,
    onFocusChanged: @escaping (Value) -> Void
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
      return self
        .onChange(of: focusState.wrappedValue) { oldValue, newValue in
          modelState.wrappedValue = newValue
          onFocusChanged(newValue)
        }
        .onChange(of: modelState.wrappedValue) { _, newValue in
          focusState.wrappedValue = newValue
        }

    } else {
      return self
        .onChange(of: focusState.wrappedValue) { newValue in
          modelState.wrappedValue = newValue
          onFocusChanged(newValue)
        }
        .onChange(of: modelState.wrappedValue) { newValue in
          focusState.wrappedValue = newValue
        }
    }
  }
}

#if canTestSwiftUI
import enum SwiftUITestSupport.TestSupport
import struct SwiftUITestSupport.FocusState
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@propertyWrapper
public struct FocusStateAdapter<Value>: DynamicProperty where Value: Hashable {

  private var focusState: FocusStateImp<Value>
  private var modelState: State<Value>

  public init() where Value == Bool {
    self.focusState = FocusStateImp()
    self.modelState = State(initialValue: false)
  }

  public init<T>() where Value == T?, T: Hashable {
    self.focusState = FocusStateImp()
    self.modelState = State(initialValue: nil)
  }

  public var wrappedValue: Value {
    get {
      self.modelState.wrappedValue
    }
    nonmutating set {
      #if canTestSwiftUI
      if TestSupport.isRunningUnitTest {
        self.focusState.wrappedValue = newValue
      }
      #endif
      self.modelState.wrappedValue = newValue
    }
  }

  public struct Binding {
    let focusState: FocusStateImp<Value>

    let modelState: State<Value>
  }

  public var projectedValue: Binding {
    Binding(focusState: self.focusState, modelState: self.modelState)
  }
}

#if canTestSwiftUI
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FocusStateImp = SwiftUITestSupport.FocusState
#else
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FocusStateImp = SwiftUI.FocusState
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {

  func focused<Value>(
    _ binding: FocusStateAdapter<Value?>.Binding,
    equals value: Value,
    onFocusChanged: @escaping (Value?) -> Void
  ) -> some View where Value : Hashable {
    self.modifier(
      FocusedValueViaBindingModifier(
        focusState: binding.focusState.projectedValue,
        modelState: Binding(get: { binding.modelState.wrappedValue }, set: { binding.modelState.wrappedValue = $0 }),
        equals: value,
        onFocusChanged: onFocusChanged
      )
    )
  }

  func focused(
    _ condition: FocusStateAdapter<Bool>.Binding,
    onFocusChanged: @escaping (Bool) -> Void
  ) -> some View {
    self.modifier(
      FocusedBoolViaBindingModifier(
        focusState: condition.focusState.projectedValue,
        modelState: Binding(get: { condition.modelState.wrappedValue }, set: { condition.modelState.wrappedValue = $0 }),
        onFocusChanged: onFocusChanged
      )
    )
  }
}
