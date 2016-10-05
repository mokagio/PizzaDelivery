import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping (Result<[Pizza], PizzaDeliveryError>) -> ()) {
    session.yow_dataTask(with: baseURL.appendingPathComponent("pizzas")) { (result: Result<Data, PizzaDeliveryError>) in
      let transformedResult: Result<[Pizza], PizzaDeliveryError> = result
        .flatMap(JSONSerialization.yow_jsonObject)
        .flatMap(JSONParser.pizzaList)
        .map { $0.list }

      completion(transformedResult)
    }.resume()
  }
}
