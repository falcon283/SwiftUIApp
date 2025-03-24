import Testing
import Foundation
@testable import SwiftAppUtilities

@Suite
struct Given_AThreadSafe { }

extension Given_AThreadSafe {

  @Test
  func When_MultiThreadingReadValues_Then_ValuesCanBeRead() async {
    let threadSafe = ThreadSafe(10)

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<10000 {
        group.addTask { #expect(threadSafe.wrappedValue == 10) }
      }
    }
  }

  @Test
  func When_MultiThreadingWriteValues_Then_ValuesAreWritten() async {
    let threadSafe = ThreadSafe(10)

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<10000 {
        group.addTask { threadSafe.wrappedValue = .random(in: Int.min...Int.max) }
      }
    }
  }

  @Test
  func When_MultiThreadingReadWriteValues_Then_ValuesAreWrittenAndRead() async {
    let threadSafe = ThreadSafe(10)

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<10000 {
        group.addTask {
          withExtendedLifetime(threadSafe.wrappedValue) { }
          threadSafe.wrappedValue = .random(in: Int.min...Int.max)
        }
      }
    }
  }

  @Test
  func When_CheckingForEquatable_Then_ItWorksAsExpected() async {
    let threadSafe1 = ThreadSafe(10)
    let threadSafe2 = ThreadSafe(10)

    #expect(threadSafe1 == threadSafe2)

    threadSafe2.wrappedValue = 20

    #expect(threadSafe1 != threadSafe2)
  }

  @Test
  func When_CheckingForIdentifiable_Then_ItWorksAsExpected() async {

    struct TestValue: Identifiable {
      let id: Int
    }

    let threadSafe1 = ThreadSafe(TestValue(id: 10))
    let threadSafe2 = ThreadSafe(TestValue(id: 10))

    #expect(threadSafe1.id == threadSafe2.id)

    threadSafe2.wrappedValue = TestValue(id: 20)

    #expect(threadSafe1.id != threadSafe2.id)
  }

  @Test
  func When_CheckingForHashable_Then_ItWorksAsExpected() async {

    struct TestValue: Hashable {
      let id: Int
    }

    let threadSafe1 = ThreadSafe(TestValue(id: 10))
    let threadSafe2 = ThreadSafe(TestValue(id: 10))

    #expect(threadSafe1.hashValue == threadSafe2.hashValue)

    threadSafe2.wrappedValue = TestValue(id: 20)

    #expect(threadSafe1.hashValue != threadSafe2.hashValue)
  }
}
