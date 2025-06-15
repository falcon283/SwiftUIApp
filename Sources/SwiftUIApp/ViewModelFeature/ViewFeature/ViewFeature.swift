private import Foundation
private import SwiftAppUtilities
public import SwiftUI

/// A protocol suitable to build a SwiftUI `View` Feature.
///
/// This protocol extends ``ViewModelFeature`` by adding a new ``body(with:)`` method.
/// It comes with a SwiftUI `View.body` default implementation which call the ``body(with:)`` function passing a proper bag in it.
///
/// The `bag` is needed so that in synchronous contexts, such `Button` or `onTapGesture(count:perform:)` action closures, you have the proper `bag`
/// that can be used in methods like ``ViewModelFeature/notify(_:storeIn:withId:)``.
///
/// - Warning: You must implement your View in ``body(with:)`` instead. Do not replace the `ViewFeature.body` protocol default implementation.
public protocol ViewFeature: ViewModelFeature, View where Body == CancellationBagView<BagViewBody>  {

  /// The `View` Type which will be embedded into the ``CancellationBagView``
  associatedtype BagViewBody: View
  
  /// A function that build a SwiftUI `View` which is automatically installed into the SwiftUI `View.body`
  ///
  /// You implement this function as replacement of SwiftUI `View.body`. The `ViewFeature` gives you a default `body` implementation which call this function
  /// providing you the proper `bag` to use.
  ///
  /// The bag is meant to be used when calling the following methods:
  /// - ``ViewModelFeature/notify(_:storeIn:withId:)``
  /// - ``ViewModelFeature/bind(_:storeIn:withId:onChangeNotify:)-(_,_,_,UIEvent)``
  /// - ``ViewModelFeature/bind(_:storeIn:withId:onChangeNotify:)-(_,_,_,(Value) -> UIEvent)``
  ///
  /// - Parameter bag: The bag required to be used when
  /// - Returns: The view installed into the SwiftUI `body`.
  @ViewBuilder @MainActor func body(with bag: CancellationBag) -> BagViewBody
}

public extension ViewFeature {

  /// The `ViewFeature` `body` View default implementation.
  ///
  /// You must not implement the body on your own.
  /// Since your synchronous call to ``ViewModelFeature/notify(_:storeIn:withId:)`` requires a bag owned by a different view, the default body implementation will
  /// provide you a `CancellationBagView<BagViewBody>` which will use ``body(with:)`` as content.
  ///
  /// You are expected to implement ``body(with:)`` as replacement of `body` implementation.
  var body: CancellationBagView<BagViewBody> {
    CancellationBagView(contentView: self.body(with:))
  }
}
