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
      switch result {
      case .success(let data):
        switch JSONSerialization.yow_jsonObject(with: data) {
        case .success(let json):
          switch JSONParser.pizzaList(from: json) {
          case .success(let response):
            completion(Result(value: response.list))
          case .failure(let error):
            completion(Result(error: .wrapped(error)))
          }
        case .failure(let error):
          completion(Result(error: .wrapped(error)))
        }
      case .failure(let error):
        completion(Result(error: .wrapped(error)))
      }
    }.resume()
  }
}

enum PizzaServiceError: Error {
  case inconsistentResponse
  case missingContent
  case wrapped(Error)
}
