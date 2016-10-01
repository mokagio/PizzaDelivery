import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping ([Pizza]?, PizzaServiceError?) -> ()) {
    session.dataTask(with: baseURL.appendingPathComponent("pizzas")) { data, response, error in
      if let data = data, let _ = response {
        do {
          guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? JSONObject else {
            completion(.none, PizzaServiceError.missingContent)
            return
          }

          let pizzaListResponse = try JSONParser.pizzaList(fromJSON: jsonObject)
          completion(pizzaListResponse.list, .none)
        } catch {
          completion(.none, PizzaServiceError.wrapped(error))
        }
      } else if let error = error {
        completion(.none, PizzaServiceError.wrapped(error))
      } else {
        completion(.none, PizzaServiceError.inconsistenResponse)
      }
    }.resume()
  }
}

enum PizzaServiceError: Error {
  case inconsistenResponse
  case missingContent
  case wrapped(Error)
}
