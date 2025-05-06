@MainActor
public protocol ViewModelFeature {

  associatedtype UIEvent = Never

  nonmutating func notify(_ event: UIEvent) async
}

public extension ViewModelFeature where UIEvent == Never {

  nonmutating func notify(_ event: UIEvent) async { }
}
