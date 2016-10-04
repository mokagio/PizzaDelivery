import Foundation

struct JSONParser {

  private struct Keys {
    struct PizzaList {
      static let List = "pizzas"
    }

    struct Pizza {
      static let Name = "name"
      static let Price = "price"
    }
  }

  static func pizzaList(fromJSON json: JSONObject) throws -> PizzaListResponse {
    guard let list = json[Keys.PizzaList.List] as? JSONArray else {
      throw missingKey(key: Keys.PizzaList.List)
    }

    var errors = [Error]()
    var pizzas = [Pizza]()

    list.forEach { json in
      do {
        pizzas.append(try pizza(fromJSON: json))
      } catch {
        errors.append(error)
      }
    }

    if pizzas.count == 0 && errors.count > 0 {
      throw arrayParsingFailed(errors: errors)
    } else {
      return PizzaListResponse(list: pizzas)
    }
  }

  static func pizza(fromJSON json: JSONObject) throws -> Pizza {
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

  private static func arrayParsingFailed(errors: [Error]) -> NSError {
    let description = errors.map { "\($0)" }.joined(separator: " ")
    return NSError(
      domain: errorDomain,
      code: 2,
      userInfo: [NSLocalizedDescriptionKey: description]
    )
  }
}
