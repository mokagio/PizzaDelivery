import UIKit

class ErrorViewController: UIViewController {

  @IBOutlet var errorLabel: UILabel!

  let error: Error

  init(error: Error) {
    self.error = error
    super.init(nibName: "ErrorViewController", bundle: .none)
  }

  @available(*, unavailable)
  init() {
    fatalError()
  }

  @available(*, unavailable)
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    errorLabel.text = message(forError: error)
  }

  private func message(forError error: Error) -> String {
    switch error {
    case let pizzaServiceError as PizzaDeliveryError:
      switch pizzaServiceError {
      case .wrapped(let innerError):
        return message(forError: innerError)
      case .networking(let networkingError):
        switch networkingError {
        case .httpError(let code):
          return "There has been an error while connecting to the pizza server. Code \(code)"
        default:
          return "There has been an error while connecting to the pizza server"
        }
      case .jsonDeserialization, .parsing:
        return "The pizza server got confused and returned burgers instead of pizzas"
      }
    default:
      return "An error occurred while getting the pizzas list"
    }
  }
}
