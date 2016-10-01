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

  static func pizzaList(fromJSON json: JSON) -> Result<PizzaListResponse, JSONParserError> {
    switch json {
    case .object(let object): return pizzaList(fromJSONObject: object)
    case .array: return Result(error: .unexpectedJSONType)
    }
  }

  private static func pizzaList(fromJSONObject jsonObject: JSONObject) -> Result<PizzaListResponse, JSONParserError> {
    guard let list = jsonObject[Keys.PizzaList.List] as? JSONArray else {
      return Result(error: JSONParserError.missingKey(Keys.PizzaList.List))
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
      return Result(error: JSONParserError.failedArrayParsing(errors))
    } else {
      return Result(value: PizzaListResponse(list: pizzas))
    }
  }

  static func pizza(fromJSON json: JSONObject) -> Result<Pizza, JSONParserError> {
    guard let name = json[Keys.Pizza.Name] as? String else {
      return Result(error: JSONParserError.missingKey(Keys.Pizza.Name))
    }
    guard let price = json[Keys.Pizza.Price] as? Double else {
      return Result(error: JSONParserError.missingKey(Keys.Pizza.Price))
    }

    return Result(value: Pizza(price: price, name: name))
  }
}

enum JSONParserError: Error {
  case unexpectedJSONType
  case missingKey(String)
  case failedArrayParsing([Error])
}
