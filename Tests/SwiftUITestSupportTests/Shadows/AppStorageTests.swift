import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct AppStorageTests {

  // MARK: Default Value

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AppStorage_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.bool == false)
      #expect(sut.int == 0)
      #expect(sut.double == 0)
      #expect(sut.string == "")
      #expect(sut.url == URL(string: "https://test.com")!)
      #expect(sut.data == Data(repeating: 1, count: 10))
      #expect(sut.rawInt == .one)
      #expect(sut.rawString == .key)
      #expect(sut.boolOptional == nil)
      #expect(sut.intOptional == nil)
      #expect(sut.doubleOptional == nil)
      #expect(sut.stringOptional == nil)
      #expect(sut.urlOptional == nil)
      #expect(sut.dataOptional == nil)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AppStorage15_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView15()) { sut in
      #expect(sut.rawIntOptional == nil)
      #expect(sut.rawStringOptional == nil)
    }
  }

  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  @Test
  func Given_AppStorageSwiftUI_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestViewSwiftUI()) { sut in
      #expect(sut.date == .distantPast)
      #expect(sut.dateOptional == nil)
      #expect(sut.toolbarLabelStyle == .automatic)
    }
  }

  @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  @Test
  func Given_AppStorageTabViewCustomization_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestTabViewCustomization()) { sut in
      #expect(sut.tabViewCustomization[sidebarVisibility: "test"] == .automatic)
    }
  }

  // MARK: Injected Value

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AppStorage_When_Injected_Then_HasInjectedValue() async throws {

    try await given(TestView()) {
      $0.storage(true, for: "boolKey")
        .storage(1, for: "intKey")
        .storage(1.0, for: "doubleKey")
        .storage("test", for: "stringKey")
        .storage(URL(string: "https://overriden.com")!, for: "urlKey")
        .storage(Data(repeating: 2, count: 10), for: "dataKey")
        .storage(EnumInt.two, for: "rawIntKey")
        .storage(EnumString.value, for: "rawStringKey")
        .storage(false, for: "boolOptionalKey")
        .storage(1, for: "intOptionalKey")
        .storage(2.0, for: "doubleOptionalKey")
        .storage("optionalTest", for: "stringOptionalKey")
        .storage(URL(string: "https://optional.com")!, for: "urlOptionalKey")
        .storage(Data(repeating: 3, count: 10), for: "dataOptionalKey")
    } expect: { sut in
      #expect(sut.bool == true)
      #expect(sut.int == 1)
      #expect(sut.double == 1)
      #expect(sut.string == "test")
      #expect(sut.url == URL(string: "https://overriden.com")!)
      #expect(sut.data == Data(repeating: 2, count: 10))
      #expect(sut.rawInt == EnumInt.two)
      #expect(sut.rawString == EnumString.value)
      #expect(sut.boolOptional == false)
      #expect(sut.intOptional == 1)
      #expect(sut.doubleOptional == 2)
      #expect(sut.stringOptional == "optionalTest")
      #expect(sut.urlOptional == URL(string: "https://optional.com")!)
      #expect(sut.dataOptional == Data(repeating: 3, count: 10))
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AppStorage15_When_Injected_Then_HasInjectedValue() async throws {

    try await given(TestView15()) {
      $0.storage(EnumInt.two, for: "rawIntOptionalKey")
        .storage(EnumString.value, for: "rawStringOptionalKey")
    } expect: { sut in
      #expect(sut.rawIntOptional == .two)
      #expect(sut.rawStringOptional == .value)
    }
  }

  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  @Test
  func Given_AppStorageSwiftUI_When_Injected_Then_HasInjectedValue() async throws {

    try await given(TestViewSwiftUI()) {
      $0.storage(Date.distantFuture, for: "dateKey")
        .storage(Date.distantPast, for: "dateOptionalKey")
        .storage(ToolbarLabelStyle.automatic, for: "toolbarLabelStyleKey")
    } expect: { sut in
      #expect(sut.date == .distantFuture)
      #expect(sut.dateOptional == .distantPast)
      #expect(sut.toolbarLabelStyle == .automatic)
    }
  }

  @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  @Test
  func Given_AppStorageTabViewCustomization_When_Injected_Then_HasInjectedValue() async throws {

    var customization = TabViewCustomization()
    customization[sidebarVisibility: "test"] = .visible

    try await given(TestTabViewCustomization()) {
      $0.storage(customization, for: "tabViewCustomizationKey")
    } expect: { sut in
      #expect(sut.tabViewCustomization[sidebarVisibility: "test"] == .visible)
    }
  }

  // MARK: - Modified Value

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AppStorage_When_Updated_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) { sut in
      sut.bool = true
      sut.int = 1
      sut.double = 1.5
      sut.string = "test"
      sut.url = URL(string: "https://test.com.changed")!
      sut.data = Data(repeating: 2, count: 10)
      sut.rawInt = .two
      sut.rawString = .value
      sut.boolOptional = false
      sut.intOptional = 2
      sut.doubleOptional = 2.5
      sut.stringOptional = "testOptional"
      sut.urlOptional = URL(string: "https://test.com.optional")!
      sut.dataOptional = Data(repeating: 3, count: 10)

      #expect(sut.bool == true)
      #expect(sut.int == 1)
      #expect(sut.double == 1.5)
      #expect(sut.string == "test")
      #expect(sut.url == URL(string: "https://test.com.changed")!)
      #expect(sut.data == Data(repeating: 2, count: 10))
      #expect(sut.rawInt == .two)
      #expect(sut.rawString == .value)
      #expect(sut.boolOptional == false)
      #expect(sut.intOptional == 2)
      #expect(sut.doubleOptional == 2.5)
      #expect(sut.stringOptional == "testOptional")
      #expect(sut.urlOptional == URL(string: "https://test.com.optional")!)
      #expect(sut.dataOptional == Data(repeating: 3, count: 10))
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AppStorage15_When_Updated_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView15()) { sut in
      sut.rawIntOptional = .one
      sut.rawStringOptional = .key

      #expect(sut.rawIntOptional == .one)
      #expect(sut.rawStringOptional == .key)
    }
  }

  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  @Test
  func Given_AppStorageSwiftUI_When_Updated_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestViewSwiftUI()) { sut in
      sut.date = .distantFuture
      sut.dateOptional = .distantPast
      sut.toolbarLabelStyle = .automatic

      #expect(sut.date == .distantFuture)
      #expect(sut.dateOptional == .distantPast)
      #expect(sut.toolbarLabelStyle == .automatic)
    }
  }

  @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  @Test
  func Given_AppStorageTabViewCustomization_When_Updated_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestTabViewCustomization()) { sut in
      sut.tabViewCustomization[sidebarVisibility: "test"] = .hidden

      #expect(sut.tabViewCustomization[sidebarVisibility: "test"] == .hidden)
    }
  }
}

// MARK: - Test Objects

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private typealias AppStorage = SwiftUITestSupport.AppStorage

private enum EnumInt: Int {
  case one
  case two
}

private enum EnumString: String {
  case key
  case value
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @AppStorage("boolKey")
  var bool: Bool = false

  @AppStorage("intKey")
  var int: Int = 0

  @AppStorage("doubleKey")
  var double: Double = 0

  @AppStorage("stringKey")
  var string: String = ""

  @AppStorage("urlKey")
  var url: URL = URL(string: "https://test.com")!

  @AppStorage("dataKey")
  var data: Data = Data(repeating: 1, count: 10)

  @AppStorage("rawIntKey")
  var rawInt: EnumInt = .one

  @AppStorage("rawStringKey")
  var rawString: EnumString = .key

  @AppStorage("boolOptionalKey")
  var boolOptional: Bool?

  @AppStorage("intOptionalKey")
  var intOptional: Int?

  @AppStorage("doubleOptionalKey")
  var doubleOptional: Double?

  @AppStorage("stringOptionalKey")
  var stringOptional: String?

  @AppStorage("urlOptionalKey")
  var urlOptional: URL?

  @AppStorage("dataOptionalKey")
  var dataOptional: Data?

  var body: some View { EmptyView() }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView15: View {

  @AppStorage("rawIntOptionalKey")
  var rawIntOptional: EnumInt?

  @AppStorage("rawStringOptionalKey")
  var rawStringOptional: EnumString?

  var body: some View { EmptyView() }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct TestViewSwiftUI: View {

  @AppStorage("dateKey")
  var date: Date = .distantPast

  @AppStorage("dateOptionalKey")
  var dateOptional: Date?

  @AppStorage("toolbarLabelStyleKey")
  var toolbarLabelStyle: ToolbarLabelStyle

  var body: some View { EmptyView() }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct TestTabViewCustomization: View {

  @AppStorage("tabViewCustomizationKey")
  var tabViewCustomization: TabViewCustomization

  var body: some View { EmptyView() }
}
