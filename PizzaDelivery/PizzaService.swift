import Foundation

class PizzaService {

  let session: URLSession
  let baseURL: URL

  init(baseURL: URL = URL(string: "http://localhost:4567")!) {
    self.session = URLSession(configuration: URLSessionConfiguration.default)
    self.baseURL = baseURL
  }

  func loadPizzas(completion: @escaping ([Pizza]?, NSError?) -> ()) {
    session.dataTask(with: baseURL.appendingPathComponent("pizzas")) { data, response, error in
      if let data = data, let _ = response {
        do {
          let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
          guard let jsonPizzas = jsonObject?["pizzas"] as? [[String: Any]] else {
            completion(.none, PizzaService.MissingContentError)
            return
          }

          let pizzas = jsonPizzas.flatMap { Pizza(jsonObject: $0) }
          completion(pizzas, .none)
        } catch let e as NSError {
          completion(.none, e)
        } catch {
          completion(.none, PizzaService.errorWrapping(error))
        }
      } else if let error = error as? NSError {
        completion(.none, error)
      } else {
        completion(.none, PizzaService.InconsistenResponseError)
      }
    }.resume()
  }

  private static let errorDomain = "pizzaservice"

  static let InconsistenResponseError = NSError(
    domain: errorDomain,
    code: 1,
    userInfo: [NSLocalizedDescriptionKey: "Inconsistent network response"]
  )

  static let MissingContentError = NSError(
    domain: errorDomain,
    code: 2,
    userInfo: [NSLocalizedDescriptionKey: "The network response is missing the expected data"]
  )

  static func errorWrapping(_ error: Error) -> NSError {
    return NSError(
      domain: errorDomain,
      code: 3,
      userInfo: [NSLocalizedDescriptionKey: "\(error)"]
    )
  }
}
