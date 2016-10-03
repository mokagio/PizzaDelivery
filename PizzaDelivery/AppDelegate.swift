import UIKit
import GenericTableViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  var statefulContainer: StatefulContainerViewController?

  let pizzaService = PizzaService()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    let pizzaListStatefulContainer = x()
    statefulContainer = pizzaListStatefulContainer


    let navigationController = UINavigationController(rootViewController: pizzaListStatefulContainer)
    navigationController.navigationBar.isTranslucent = false

    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    // TODO: in a "real" app you'd use something more robust, given that the
    // network activity indicator is a shared resource
    UIApplication.shared.isNetworkActivityIndicatorVisible = false

    pizzaService.loadPizzas { [weak self] result in
      guard let container = self?.statefulContainer else { return }

      // TODO: in a "real" app you'd use something more robust, given that the
      // network activity indicator is a shared resource
      UIApplication.shared.isNetworkActivityIndicatorVisible = true

      DispatchQueue.main.async {
        switch result {
        case .success(let pizzas):
          let data = interpose(pizzas, withElementsFrom: Ad.dummyAds(), count: 3)
          container.state = ViewState<[Either<Pizza, Ad>]>.loaded(data).boxedToAny()
        case .failure(let error):
          container.state = ViewState<[Either<Pizza, Ad>]>.errored(error).boxedToAny()
        }
      }
    }

    return true
  }
}

func x() -> StatefulContainerViewController {

  let initialState = ViewState<[Either<Pizza, Ad>]>.loading

  let container = containerViewController(withInitialState: initialState) { (state) -> UIViewController in
    switch state {
    case .loading:
      return LoadingViewController()
    case .errored(let error):
      return ErrorViewController(error: error)
    case .loaded(let data):
      let configuration: TableViewConfiguration<Either<Pizza, Ad>> = TableViewConfiguration(
        data: data,
        rowsConfiguration: RowConfiguration<Either<Pizza, Ad>>(
          identifier: "cell",
          cellClass: UITableViewCell.self,
          configurator: { (item, cell) -> UITableViewCell in
            switch item {
            case .left(let pizza):
              cell.textLabel?.text = "\(pizza.name) ($\(pizza.price))"
            case .right(let ad):
              cell.textLabel?.text = ad.message
              cell.textLabel?.textAlignment = .center
              cell.textLabel?.textColor = UIColor.white
              cell.backgroundColor = ad.color
            }
            return cell
          }
        )
      )

      let vc = GenericTableViewController()
      vc.tableViewConfigurator = configuration.boxedToAny()

      return vc
    }
  }

  container.title = "🍕"

  return container
} 
