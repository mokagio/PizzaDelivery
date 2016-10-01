import Foundation

struct JSONParser {

  private struct Keys {
    struct Pizza {
      static let Name = "name"
      static let Price = "price"
    }
  }

  static func pizza(fromJSON json: [String: Any]) throws -> Pizza {
    guard let name = json[Keys.Pizza.Name] as? String else {
      throw missingKey(key: Keys.Pizza.Name)
    }
    guard let price = json[Keys.Pizza.Price] as? Double else {
      throw missingKey(key: Keys.Pizza.Price)
    }

    return Pizza(price: price, name: name)
  }

  private static let errorDomain = "jsondecoding"

  private static func missingKey(key: String) -> NSError {
    return NSError(
      domain: errorDomain,
      code: 1,
      userInfo: [NSLocalizedDescriptionKey: "Missing key: \(key)"]
    )
  }
}
