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

  static func pizzaList(from json: JSON) -> Result<PizzaListResponse, JSONParserError> {
    switch json {
    case .object(let jsonObject):
        return JSONParser.pizzaList(fromJSON: jsonObject)
    case _:
      return Result(error: JSONParserError.notJSONDictionary)
    }
  }

  private static func pizzaList(fromJSON json: JSONObject) -> Result<PizzaListResponse, JSONParserError> {
    guard let list = json[Keys.PizzaList.List] as? JSONArray else {
      return Result(error: JSONParserError.missingKey(Keys.PizzaList.List))
    }

    let accumulation: (pizzas: [Pizza], errors: [Error]) = list
      .map { pizza(fromJSON: $0) }
      .reduce(([Pizza](), [Error]())) { accumulator, result  in
        switch result {
        case .success(let pizza): return (accumulator.0 + [pizza], accumulator.1)
        case .failure(let error): return (accumulator.0, accumulator.1 + [error])
        }
    }

    if accumulation.pizzas.count == 0 && accumulation.errors.count > 0 {
      return Result(error: JSONParserError.arrayParsingFailed(accumulation.errors))
    } else {
      return Result(value: PizzaListResponse(list: accumulation.pizzas))
    }
  }

  static func pizza(fromJSON json: JSONObject) -> Result<Pizza, JSONParserError> {
    guard let name = json[Keys.Pizza.Name] as? String else {
      return Result(error: .missingKey(Keys.Pizza.Name))
    }
    guard let price = json[Keys.Pizza.Price] as? Double else {
      return Result(error: .missingKey(Keys.Pizza.Price))
    }

    return Result(value: Pizza(price: price, name: name))
  }
}

enum JSONParserError: Error {
  case missingKey(String)
  case arrayParsingFailed([Error])
  case notJSONDictionary
}
