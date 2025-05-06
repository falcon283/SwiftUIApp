private import Foundation
private import SwiftAppUtilities
public import SwiftUI

public protocol ViewFeature: ViewModelFeature, View where Body == CancellationBagView<BagViewBody>  {

  associatedtype BagViewBody: View

  @ViewBuilder @MainActor func body(with bag: CancellationBag) -> BagViewBody
}

public extension ViewFeature {

  var body: CancellationBagView<BagViewBody> {
    CancellationBagView(contentView: self.body(with:))
  }
}
