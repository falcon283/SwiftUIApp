/// An helper function to remap a `throws(InputError)` function to a `throws(OutputError)`.
///
/// - Parameters:
///   - map: The error mapper closure.
///   - closure: The execution closure which when throws `InputError` gets remapped into the new `OutputError`.
public func withThrowingError<T, InputError: Error, OutputError: Error>(
  _ map: (InputError) -> OutputError,
  closure: () throws(InputError) -> T
) throws(OutputError) -> T {

  do { return try closure() }
  catch { throw map(error) }
}

/// An helper function to remap a `async throws(InputError)` function to an `async throws(OutputError)`.
///
/// - Parameters:
///   - map: The error mapper closure.
///   - closure: The execution closure which when throws `InputError` gets remapped into the new `OutputError`.
public func withThrowingError<T, InputError: Error, OutputError: Error>(
  _ map: (InputError) -> OutputError,
  closure: () async throws(InputError) -> T
) async throws(OutputError) -> T {

  do { return try await closure() }
  catch { throw map(error) }
}
