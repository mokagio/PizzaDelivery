import Foundation

class PizzaService {

  func loadPizzas(completion: @escaping ([Pizza]?, NSError?) -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      completion(fixtureMenu(), .none)
    }
  }
}
