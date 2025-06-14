#if os(iOS) || os(macOS)
import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
extension MyView: View {

  func body(with bag: CancellationBag) -> some View {
    VStack {
      Text(self.writable)
      Text("\(self.colorScheme)")
      Text("First Focused: \(self.focus1)")
      Text("Second Focused: \(self.focus2)")
      TextField("Test1", text: self.bind(\.writable, storeIn: bag, onChangeNotify: UIEvent.textField1Changed))
        .textFieldStyle(.plain)
        .focused(self.$focus1) { self.notify(.textField1Focused($0), storeIn: bag) }
        .padding()
      TextField("Test2", text: self.bind(\.writable2, storeIn: bag, onChangeNotify: UIEvent.textField2Changed))
        .textFieldStyle(.plain)
        .focused(self.$focus2) { self.notify(.textField2Focused($0), storeIn: bag) }
        .padding()
      Button {
        self.notify(.buttonTap, storeIn: bag)
      } label: {
        Text("Press")
      }
      Button {
        self.notify(.presentModalTap, storeIn: bag)
      } label: {
        Text("Present")
      }
      Button {
        self.notify(.closeButtonTap, storeIn: bag)
      } label: {
        Text("Close Modal")
      }
    }
    .background { self.backgroundColor }
//    .fullScreenCover(isPresented: self.bind(\.presenting, storeIn: bag, onChangeNotify: .modalClosed)) {
//      MyView()
//    }
  }
}

#Preview {
  if #available(iOS 15.0, macOS 12.0, *) {
    MyView()
  } else {
    // Fallback on earlier versions
  }
}
#endif
