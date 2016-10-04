import UIKit

class PizzaListViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var spinner: UIActivityIndicatorView!

  @IBOutlet var errorView: UIStackView!
  @IBOutlet var errorMessageLabel: UILabel!
  @IBOutlet var errorRetryButton: UIButton!

  let pizzaService = PizzaService()

  let pizzaCellIdentifier = "pizza"
  let adCellIdentifier = "ad"

  var data: [Either<Pizza, Ad>]?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    configureTableView()
    errorRetryButton.addTarget(self, action: #selector(loadPizzasList), for: .touchUpInside)

    spinner.hidesWhenStopped = true
    tableView.isHidden = true
    errorView.isHidden = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadPizzasList()
  }

  internal func loadPizzasList() {
    tableView.isHidden = true
    errorView.isHidden = true
    spinner.startAnimating() // starting animation shows as well

    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    pizzaService.loadPizzas { [weak self] list, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      DispatchQueue.main.async { [weak self] in
        guard let `self` = self else { return }

        self.spinner.stopAnimating() // stop animating hides as well

        switch (list, error) {
        case (.some(let list), .none):
          self.tableView.isHidden = false
          self.data = interpose(list, withElementsFrom: Ad.dummyAds(), count: 3)
          self.tableView.reloadData()
        case (.none, .some(let error)):
          self.errorView.isHidden = false
          self.errorMessageLabel.text = self.message(for: error)
        case _:
          fatalError("Pizza service returned neither pizza list nor error")
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
    case is JSONParserError:
      return "The pizza server returned gibberish"
    case is PizzaServiceError:
      return "The pizza server behaved unexpectedly"
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
    return data?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let data = data else {
      return UITableViewCell()
    }

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
