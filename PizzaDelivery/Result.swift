//
// For a more feature rich implementation of the Result type checkout
// https://github.com/antitypical/Result
//
enum Result<Value, ResultError: Error> {
  case success(Value)
  case failure(ResultError)
}

extension Result {
  init(value: Value) {
    self = .success(value)
  }

  init(error: ResultError) {
    self = .failure(error)
  }
}
