import UIKit

class PizzaListViewController: UIViewController {

  enum State {
    case loading
    case loaded([Either<Pizza, Ad>])
    case errored(Error)
  }

  @IBOutlet var tableView: UITableView!
  @IBOutlet var spinner: UIActivityIndicatorView!

  @IBOutlet var errorView: UIStackView!
  @IBOutlet var errorMessageLabel: UILabel!
  @IBOutlet var errorRetryButton: UIButton!

  var state = State.loading

  let pizzaService = PizzaService()

  let pizzaCellIdentifier = "pizza"
  let adCellIdentifier = "ad"

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    configureTableView()
    errorRetryButton.addTarget(self, action: #selector(loadPizzasList), for: .touchUpInside)
    spinner.hidesWhenStopped = true

    updateView(withState: .loading)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Doing this in didAppear just to ensure audience notices the spinner
    loadPizzasList()
  }

  private func updateView(withState state: State) {
    self.state = state

    switch state {
    case .errored(let error):
      errorView.isHidden = false
      spinner.stopAnimating()
      tableView.isHidden = true
      errorMessageLabel.text = message(forError: error)

    case .loading:
      errorView.isHidden = true
      spinner.startAnimating() // starting animation shows as well
      tableView.isHidden = true

    case .loaded:
      tableView.isHidden = false
      tableView.reloadData()
      spinner.stopAnimating()
      errorView.isHidden = true
    }
  }

  internal func loadPizzasList() {
    // TODO: in a "real" app you'd use something more robust, given that the
    // network activity indicator is a shared resource
    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    pizzaService.loadPizzas { [weak self] result in
      // TODO: in a "real" app you'd use something more robust, given that the
      // network activity indicator is a shared resource
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      DispatchQueue.main.async { [weak self] in
        guard let `self` = self else { return }

        switch result {
          case .success(let list):
            self.updateView(withState: .loaded(interpose(list, withElementsFrom: Ad.dummyAds(), count: 3)))
          case .failure(let error):
            self.updateView(withState: .errored(error))
        }
      }
    }
  }

  private func configureTableView() {
    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: pizzaCellIdentifier)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: adCellIdentifier)

    tableView.tableFooterView = UIView()

    tableView.allowsSelection = false
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

extension PizzaListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch state {
    case .loaded(let data):
      return data.count
    case _:
      return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch state {
    case .loaded(let data):
      switch data[indexPath.row] {
      case .left(let pizza):
        let cell = tableView.dequeueReusableCell(withIdentifier: pizzaCellIdentifier, for: indexPath)
        configure(cell: cell, with: pizza)
        return cell
      case .right(let ad):
        let cell = tableView.dequeueReusableCell(withIdentifier: adCellIdentifier, for: indexPath)
        configure(cell: cell, with: ad)
        return cell
      }
    case _:
      return UITableViewCell()
    }
  }

  private func configure(cell: UITableViewCell, with pizza: Pizza) {
    cell.textLabel?.text = "\(pizza.name) ($\(pizza.price))"
  }

  private func configure(cell: UITableViewCell, with ad: Ad) {
    cell.textLabel?.text = ad.message
    cell.textLabel?.textAlignment = .center
    cell.textLabel?.textColor = UIColor.white
    cell.backgroundColor = ad.color
  }
}
