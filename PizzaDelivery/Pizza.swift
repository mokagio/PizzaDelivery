struct Pizza {
  let price: Double
  let name: String
}

extension Pizza {
  init?(jsonObject: [String: Any]) {
    guard
      let name = jsonObject["name"] as? String,
      let price = jsonObject["price"] as? Double
      else {
        return nil
    }

    self.init(price: price, name: name)
  }
}
