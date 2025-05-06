public import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct AccessibilityFocusedValueViaBindingModifier<Value: Hashable>: ViewModifier {

  let focusState: SwiftUI.AccessibilityFocusState<Value?>.Binding
  let modelState: Binding<Value?>
  let equals: Value
  let onFocusLost: () -> Void

  func body(content: Content) -> some View {
    content
      .accessibilityFocused(self.focusState, equals: self.equals)
      .synchronizeFocuses(
        focusState: self.focusState,
        modelState: self.modelState,
        focusLostValue: nil,
        onFocusLost: self.onFocusLost
      )
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct AccessibilityFocusedBoolViaBindingModifier: ViewModifier {

  let focusState: SwiftUI.AccessibilityFocusState<Bool>.Binding
  let modelState: Binding<Bool>
  let onFocusLost: () -> Void

  func body(content: Content) -> some View {
    content
      .accessibilityFocused(self.focusState)
      .synchronizeFocuses(
        focusState: self.focusState,
        modelState: self.modelState,
        focusLostValue: false,
        onFocusLost: self.onFocusLost
      )
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension View {
  func synchronizeFocuses<Value: Hashable>(
    focusState: SwiftUI.AccessibilityFocusState<Value>.Binding,
    modelState: Binding<Value>,
    focusLostValue: Value,
    onFocusLost: @escaping () -> Void
  ) -> some View {
    if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
      return self
        .onChange(of: focusState.wrappedValue) { oldValue, newValue in
          modelState.wrappedValue = newValue

          guard newValue != oldValue, newValue == focusLostValue else { return }
          onFocusLost()
        }
        .onChange(of: modelState.wrappedValue) { _, newValue in
          focusState.wrappedValue = newValue
        }

    } else {
      return self
        .onChange(of: focusState.wrappedValue) { newValue in
          let oldValue = modelState.wrappedValue
          modelState.wrappedValue = newValue

          guard newValue != oldValue, newValue == focusLostValue else { return }
          onFocusLost()
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
public struct AccessibilityFocusStateAdapter<Value>: DynamicProperty where Value: Hashable {

  private var focusState: AccessibilityFocusStateImp<Value>
  private var modelState: State<Value>


  public init() where Value == Bool {
    self.focusState = AccessibilityFocusStateImp()
    self.modelState = State(initialValue: false)
  }


  public init<T>() where Value == T?, T: Hashable {
    self.focusState = AccessibilityFocusStateImp()
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

    let focusState: AccessibilityFocusStateImp<Value>

    let modelState: State<Value>
  }

  public var projectedValue: Binding {
    Binding(focusState: self.focusState, modelState: self.modelState)
  }
}

#if canTestSwiftUI
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias AccessibilityFocusStateImp = SwiftUITestSupport.AccessibilityFocusState
#else
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias AccessibilityFocusStateImp = SwiftUI.AccessibilityFocusState
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {

  func accessibilityFocused<Value>(
    _ binding: AccessibilityFocusStateAdapter<Value?>.Binding,
    equals value: Value,
    onFocusLost: @escaping () -> Void
  ) -> some View where Value : Hashable {
    self.modifier(
      AccessibilityFocusedValueViaBindingModifier(
        focusState: binding.focusState.projectedValue,
        modelState: Binding(get: { binding.modelState.wrappedValue }, set: { binding.modelState.wrappedValue = $0 }),
        equals: value,
        onFocusLost: onFocusLost
      )
    )
  }

  func accessibilityFocused(
    _ condition: AccessibilityFocusStateAdapter<Bool>.Binding,
    onFocusLost: @escaping () -> Void
  ) -> some View {
    self.modifier(
      AccessibilityFocusedBoolViaBindingModifier(
        focusState: condition.focusState.projectedValue,
        modelState: Binding(get: { condition.modelState.wrappedValue }, set: { condition.modelState.wrappedValue = $0 }),
        onFocusLost: onFocusLost
      )
    )
  }
}
