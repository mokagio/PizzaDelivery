import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping (Result<[Pizza], PizzaDeliveryError>) -> ()) {
    session.yow_dataTask(with: baseURL.appendingPathComponent("pizzas")) { (result: Result<Data, PizzaDeliveryError>) -> () in
      let x: Result<[Pizza], PizzaDeliveryError> = result
        .flatMap { data in
          return JSONSerialization.yow_jsonObject(with: data)
        }
        .flatMap { json in
          return JSONParser.pizzaList(fromJSON: json)
        }
        .map { $0.list }
      completion(x)
    }.resume()
  }
}
