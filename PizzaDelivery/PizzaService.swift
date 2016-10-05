import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping ([Pizza]?, Error?) -> ()) {
    session.dataTask(with: baseURL.appendingPathComponent("pizzas")) { data, response, error in
      switch (data, response, error) {
      case (.some(let data), .some, _):
        switch JSONSerialization.yow_jsonObject(with: data) {
        case .success(let json):
          switch JSONParser.pizzaList(from: json) {
          case .success(let response):
            completion(response.list, .none)
          case .failure(let error):
            completion(.none, error)
          }
        case .failure(let error):
          completion(.none, error)
        }
      case (_, _, .some(let error)):
        completion(.none, error)
      case _:
        completion(.none, PizzaServiceError.inconsistentResponse)
      }
    }.resume()
  }
}

enum PizzaServiceError: Error {
  case inconsistentResponse
  case missingContent
}
