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

  let pizzaService = PizzaService()

  let pizzaCellIdentifier = "pizza"
  let adCellIdentifier = "ad"

  var state = State.loading

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    configureTableView()
    errorRetryButton.addTarget(self, action: #selector(loadPizzasList), for: .touchUpInside)
    spinner.hidesWhenStopped = true

    // This is redundant, since the state is already defined as .loading, but
    // needed to trigger the actual view drawing.
    //
    // An alternative would be to declare state a Optional, but that would mean
    // unwrap it every time, which would be more work.
    update(state: .loading)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadPizzasList()
  }

  private func update(state: State) {
    self.state = state

    switch state {
    case .loading:
      tableView.isHidden = true
      errorView.isHidden = true
      spinner.startAnimating() // starting animation shows as well
    case .loaded:
      tableView.isHidden = false
      tableView.reloadData()
      errorView.isHidden = true
      spinner.stopAnimating() // stop animating hides as well
    case .errored(let error):
      tableView.isHidden = true
      errorView.isHidden = false
      errorMessageLabel.text = message(for: error)
      spinner.stopAnimating() // stop animating hides as well
    }
  }

  internal func loadPizzasList() {
    update(state: .loading)

    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    pizzaService.loadPizzas { [weak self] result in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      DispatchQueue.main.async { [weak self] in
        switch result {
        case .success(let list):
          self?.update(state: .loaded(interpose(list, withElementsFrom: Ad.dummyAds(), count: 3)))
        case .failure(let error):
          self?.update(state: .errored(error))
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

  private func message(for error: Error) -> String {
    switch error {
    case let pizzaError as PizzaDeliveryError:
      switch pizzaError {
      case .jsonParsing:
        return "The pizza server returned gibberish"
      case .pizzaService:
        return "The pizza server behaved unexpectedly"
      case .wrapped(let error):
        return message(for: error)
      case _:
        return "Something failed, but we're too lazy to tell you what"
      }
    case _:
      return error.localizedDescription
    }
  }
}

extension PizzaListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch state {
    case .loaded(let data): return data.count
    case _: return 0
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
    case _: return UITableViewCell()
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
