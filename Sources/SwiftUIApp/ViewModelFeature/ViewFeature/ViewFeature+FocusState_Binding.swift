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

/// A property wrapper meant to enable ``ViewModelFeature/notify(_:)-2iw5n`` when using FocusState capabilities.
///
/// It's meant to be used as replacement of the vanilla `@FeatureState`.
/// See also `focused(adapter:equals:onFocusLost:)` and `focused(adapter:onFocusLost:)`
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@propertyWrapper
public struct FocusStateAdapter<Value>: DynamicProperty where Value: Hashable {

  private var focusState: FocusStateImp<Value>
  private var modelState: State<Value>

  /// Designated initializer for a Boolean focus state.
  public init() where Value == Bool {
    self.focusState = FocusStateImp()
    self.modelState = State(initialValue: false)
  }

  /// Designated initializer for a generic `Hashable?` focus state.
  public init<T>() where Value == T?, T: Hashable {
    self.focusState = FocusStateImp()
    self.modelState = State(initialValue: nil)
  }
  
  /// The value of the property wrapper
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
  
  /// A Wrapper helper to easily create a focused view from a @FocuseStateAdapter.
  public struct Binding {
    /// The ``FocusState`` associated
    let focusState: FocusStateImp<Value>

    /// The ``State`` associated
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

  /// Modifies this view by binding its focus state to the given state value.
  /// 
  /// Use this modifier to cause the view to receive focus whenever the
  /// the `binding` equals the `value`. Typically, you create an enumeration
  /// of fields that may receive focus, bind an instance of this enumeration,
  /// and assign its cases to focusable views.
  /// 
  /// The following example uses the cases of a `LoginForm` enumeration to
  /// bind the focus state of two `TextField` views. A sign-in button
  /// validates the fields and sets the bound `focusedField` value to
  /// any field that requires the user to correct a problem.
  ///
  /// ```swift
  ///     struct LoginForm: ViewFeature {
  ///
  ///         enum UIEvent {
  ///           case usernameDidChange(String)
  ///           case usernameFocusLost
  ///           case passwordDidChange(String)
  ///           case passwordFocusLost
  ///           case buttonSignInTapped
  ///         }
  /// 
  ///         enum Field: Hashable {
  ///             case usernameField
  ///             case passwordField
  ///         }
  /// 
  ///         @State private var username = ""
  ///         @State private var password = ""
  ///         @FocusStateAdapter private var focusedField: Field?
  /// 
  ///         func body(with bag: CancellationBag) -> some View {
  ///             Form {
  ///                 TextField("Username", text: self.bind(\.username, onChangeNotify: UIEvent.usernameDidChange))
  ///                     .focused($focusedField, equals: .usernameField) { self.notify(.usernameFocusLost, storedIn: bag) }
  ///
  ///                 SecureField("Password", text: self.bind(\.password, onChangeNotify: UIEvent.passwordDidChange))
  ///                     .focused(adapter: $focusedField, equals: .passwordField) { self.notify(.passwordFocusLost, storedIn: bag) }
  ///
  ///                 Button("Sign In") {
  ///                     self.notify(.buttonSignInTapped, storedIn: bag)
  ///                 }
  ///             }
  ///         }
  ///     }
  /// ```
  ///
  /// To control focus using a Boolean, use the `focused(adapter:)` method
  /// instead.
  /// 
  /// - Parameters:
  ///   - binding: The state binding to register. When focus moves to the
  ///     modified view, the binding sets the bound value to the corresponding
  ///     match value. If a caller sets the state value programmatically to the
  ///     matching value, then focus moves to the modified view. When focus
  ///     leaves the modified view, the binding sets the bound value to
  ///     `nil`. If a caller sets the value to `nil`, SwiftUI automatically
  ///     dismisses focus.
  ///   - value: The value to match against when determining whether the
  ///     binding should change.
  ///   - onFocusChanged: A function executed when the focus is changed from the field.
  /// - Returns: The modified view.
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

  /// Modifies this view by binding its focus state to the given Boolean state
  /// value.
  ///
  /// Use this modifier to cause the view to receive focus whenever the
  /// the `condition` value is `true`. You can use this modifier to
  /// observe the focus state of a single view, or programmatically set and
  /// remove focus from the view.
  ///
  /// In the following example, a single `TextField` accepts a user's
  /// desired `username`. The text field binds its focus state to the
  /// Boolean value `usernameFieldIsFocused`. A "Submit" button's action
  /// verifies whether the name is available. If the name is unavailable, the
  /// button sets `usernameFieldIsFocused` to `true`, which causes focus to
  /// return to the text field, so the user can enter a different name.
  ///
  /// ```swift
  ///     @State private var username: String = ""
  ///     @FocusStateAdapter private var usernameFieldIsFocused: Bool
  ///     @State private var showUsernameTaken = false
  ///
  ///     enum UIEvent {
  ///       case usernameDidChange(String)
  ///       case focusLost
  ///       case buttonSubmitTapped
  ///     }
  ///
  ///     func body(with bag: CancellationBag) -> some View {
  ///         VStack {
  ///             TextField("Choose a username.", text: self.bind(\.username, onChangeNotify: UIEvent.usernameDidChange))
  ///                 .focused($usernameFieldIsFocused) { self.notify(.focusLost, storedIn: bag) }
  ///             if showUsernameTaken {
  ///                 Text("That username is taken. Please choose another.")
  ///             }
  ///             Button("Submit") {
  ///                 self.notify(.buttonSubmitTapped, storedIn: bag)
  ///             }
  ///         }
  ///     }
  /// ```
  ///
  /// To control focus by matching a value, use the
  /// `focused(adapter:equals:)` method instead.
  ///
  /// - Parameters:
  ///   - condition: The focus state to bind. When focus moves
  ///     to the view, the binding sets the bound value to `true`. If a caller
  ///     sets the value to  `true` programmatically, then focus moves to the
  ///     modified view. When focus leaves the modified view, the binding
  ///     sets the value to `false`. If a caller sets the value to `false`,
  ///     SwiftUI automatically dismisses focus.
  ///   - onFocusChanged: A function executed when the focus changed from the field.
  ///
  /// - Returns: The modified view.
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
