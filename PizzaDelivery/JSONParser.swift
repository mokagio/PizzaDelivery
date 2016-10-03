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

  static func pizzaList(fromJSON json: JSON) -> Result<PizzaListResponse, PizzaDeliveryError> {
    switch json {
    case .object(let object): return pizzaList(fromJSONObject: object)
    case .array: return Result(error: .parsing(.unexpectedJSONType))
    }
  }

  private static func pizzaList(fromJSONObject jsonObject: JSONObject) -> Result<PizzaListResponse, PizzaDeliveryError> {
    guard let list = jsonObject[Keys.PizzaList.List] as? JSONArray else {
      return Result(error: .parsing(.missingKey(Keys.PizzaList.List)))
    }

    var errors = [Error]()
    var pizzas = [Pizza]()

    list.forEach { json in
      switch pizza(fromJSON: json) {
      case .success(let pizza): pizzas.append(pizza)
      case .failure(let error): errors.append(error)
      }
    }

    if pizzas.count == 0 && errors.count > 0 {
      return Result(error: .parsing(.failedArrayParsing(errors)))
    } else {
      return Result(value: PizzaListResponse(list: pizzas))
    }
  }

  static func pizza(fromJSON json: JSONObject) -> Result<Pizza, PizzaDeliveryError> {
    guard let name = json[Keys.Pizza.Name] as? String else {
      return Result(error: .parsing(.missingKey(Keys.Pizza.Name)))
    }
    guard let price = json[Keys.Pizza.Price] as? Double else {
      return Result(error: .parsing(.missingKey(Keys.Pizza.Price)))
    }

    return Result(value: Pizza(price: price, name: name))
  }
}
