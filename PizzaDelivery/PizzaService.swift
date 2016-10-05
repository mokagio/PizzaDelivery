import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping (Result<[Pizza], PizzaServiceError>) -> ()) {
    session.yow_dataTask(with: baseURL.appendingPathComponent("pizzas")) { (result: Result<Data, NetworkingError>) in
      let transformedResult: Result<[Pizza], PizzaServiceError> = result
        .mapError { PizzaServiceError.wrapped($0) }
        .flatMap { data in
          return JSONSerialization.yow_jsonObject(with: data)
            .mapError { PizzaServiceError.wrapped($0) }
        }
        .flatMap { json in
          return JSONParser.pizzaList(from: json)
            .mapError { PizzaServiceError.wrapped($0) }
        }
        .map { $0.list }

      completion(transformedResult)
    }.resume()
  }
}

enum PizzaServiceError: Error {
  case inconsistentResponse
  case missingContent
  case wrapped(Error)
}
