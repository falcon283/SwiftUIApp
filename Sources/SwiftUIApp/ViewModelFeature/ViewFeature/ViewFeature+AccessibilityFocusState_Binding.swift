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

/// A property wrapper meant to enable ``ViewModelFeature/notify(_:)-2iw5n`` when using FocusState capabilities.
///
/// It's meant to be used as replacement of the vanilla `@FeatureState`.
/// See also `focused(adapter:equals:onFocusLost:)` and `focused(adapter:onFocusLost:)`
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@propertyWrapper
public struct AccessibilityFocusStateAdapter<Value>: DynamicProperty where Value: Hashable {

  private var focusState: AccessibilityFocusStateImp<Value>
  private var modelState: State<Value>

  /// Designated initializer for a Boolean focus state.
  public init() where Value == Bool {
    self.focusState = AccessibilityFocusStateImp()
    self.modelState = State(initialValue: false)
  }

  /// Designated initializer for a generic `Hashable?` focus state.
  public init<T>() where Value == T?, T: Hashable {
    self.focusState = AccessibilityFocusStateImp()
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
    let focusState: AccessibilityFocusStateImp<Value>

    /// The ``State`` associated
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

  /// Modifies this view by binding its accessibility element's focus state to
  /// the given state value.
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
  ///         @AccessibilityFocusStateAdapter private var focusedField: Field?
  ///
  ///         func body(with bag: CancellationBag) -> some View {
  ///             Form {
  ///                 TextField("Username", text: self.bind(\.username, onChangeNotify: UIEvent.usernameDidChange))
  ///                     .accessibilityFocused($focusedField, equals: .usernameField) { self.notify(.usernameFocusLost, storedIn: bag) }
  ///
  ///                 SecureField("Password", text: self.bind(\.password, onChangeNotify: UIEvent.passwordDidChange))
  ///                     .accessibilityFocused(adapter: $focusedField, equals: .passwordField) { self.notify(.passwordFocusLost, storedIn: bag) }
  ///
  ///                 Button("Sign In") {
  ///                     self.notify(.buttonSignInTapped, storedIn: bag)
  ///                 }
  ///             }
  ///         }
  ///     }
  /// ```
  ///
  /// To control focus using a Boolean, use the `accessibilityFocused(adapter:)` method instead.
  ///
  /// - Parameters:
  ///   - binding: The state binding to register. When accessibility focus moves to the
  ///     accessibility element of the modified view, SwiftUI sets the bound value to the corresponding
  ///     match value. If you set the state value programmatically to the matching value, then
  ///     accessibility focus moves to the accessibility element of the modified view. SwiftUI sets
  ///     the value to `nil` if accessibility focus leaves the accessibility element associated with the
  ///     modified view, and programmatically setting the value to `nil` dismisses focus automatically.
  ///   - value: The value to match against when determining whether the
  ///     binding should change.
  ///   - onFocusLost: A function executed when the focus is lost from the field.
  /// - Returns: The modified view.
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

  /// Modifies this view by binding its accessibility element's focus state
  /// to the given boolean state value.
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
  ///     @AccessibilityFocusStateAdapter private var usernameFieldIsFocused: Bool
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
  ///                 .accessibilityFocused($usernameFieldIsFocused) { self.notify(.focusLost, storedIn: bag) }
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
  /// To control focus by matching a value, use the `accessibilityFocused(adapter:equals:)` method instead.
  ///
  /// - Parameters:
  ///   - condition: The accessibility focus state to bind. When
  ///     accessibility focus moves to the accessibility element of the
  ///     modified view, the focus value is set to `true`.
  ///     If the value is set to `true` programmatically, then accessibility
  ///     focus will move to accessibility element of the modified view.
  ///     The value will be set to `false` if accessibility focus leaves
  ///     the accessibility element of the modified view,
  ///     and accessibility focus will be dismissed automatically if the
  ///     value is set to `false` programmatically.
  ///   - onFocusLost: A function executed when the focus is lost from the field.
  ///
  /// - Returns: The modified view.
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
