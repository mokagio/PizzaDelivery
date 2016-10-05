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

extension Result {

  func map<T>(_ f: (Value) -> T) -> Result<T, ResultError> {
    switch self {
    case .success(let value): return Result<T, ResultError>(value: f(value))
    case .failure(let error): return Result<T, ResultError>(error: error)
    }
  }

  func mapError<NewError: Error>(_ f: (ResultError) -> NewError) -> Result<Value, NewError> {
    switch self {
    case .success(let value): return Result<Value, NewError>(value: value)
    case .failure(let error): return Result<Value, NewError>(error: f(error))
    }
  }

  func flatMap<T>(_ f: (Value) -> Result<T, ResultError>) -> Result<T, ResultError> {
    switch self {
    case .success(let value): return f(value)
    case .failure(let error): return Result<T, ResultError>(error: error)
    }
  }

  func flatMapError<NewError: Error>(_ f: (ResultError) -> Result<Value, NewError>) -> Result<Value, NewError> {
    switch self {
    case .success(let value): return Result<Value, NewError>(value: value)
    case .failure(let error): return f(error)
    }
  }
}
