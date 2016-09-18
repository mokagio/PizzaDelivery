//
// For a more feature rich implementation of the Either type checkout
// https://github.com/robrix/Either
//
enum Either<A, B> {
  case left(A)
  case right(B)

  init(left value: A) {
    self = .left(value)
  }

  init(right value: B) {
    self = .right(value)
  }
}
