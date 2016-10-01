/// Every `count` elements of the first array insert one element from the
/// second, as long as element from the second can be picked.
/// Return an array of elements of either types from the input arrays.
func interpose<A, B>(_ left: [A], withElementsFrom right: [B], count: Int) -> [Either<A, B>] {
  var interposed = [Either<A, B>]()
  var fillers = Array(right.reversed())

  left.enumerated().forEach { (index, element) in
    if index % count == 0 && index != 0 {
      if let filler = fillers.popLast()  {
        interposed.append(Either<A, B>.right(filler))
      }
    }

    interposed.append(Either<A, B>.left(element))
  }

  return interposed
}
