import UIKit

struct Ad {
  let message: String
  let color: UIColor
}

extension Ad {

  static func dummyAds() -> [Ad] {
    return [
      Ad(message: "Ad Message #1", color: UIColor.blue),
      Ad(message: "Ad Message #2", color: UIColor.orange),
      Ad(message: "Ad Message #3", color: UIColor.purple),
    ]
  }
}
