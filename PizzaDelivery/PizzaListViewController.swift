import UIKit

class PizzaListViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var spinner: UIActivityIndicatorView!

  let pizzaService = PizzaService()

  let pizzaCellIdentifier = "pizza"

  var data: [Pizza]?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    spinner.hidesWhenStopped = true
    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: pizzaCellIdentifier)

    tableView.isHidden = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Doing this in didAppear just to ensure audience notices the spinner
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    spinner.startAnimating()
    pizzaService.loadPizzas { [weak self] list, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      guard let `self` = self else {
        return
      }

      self.spinner.stopAnimating()
      self.tableView.isHidden = false

      guard let list = list else {
        fatalError("Handling error not implemeted yet.")
      }

      self.data = list
      self.tableView.reloadData()
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
    let cell = tableView.dequeueReusableCell(withIdentifier: pizzaCellIdentifier, for: indexPath)
    guard let data = data else {
      return cell
    }

    let pizza = data[indexPath.row]

    configure(cell, with: pizza)

    return cell
  }

  private func configure(_ cell: UITableViewCell, with pizza: Pizza) {
    cell.textLabel?.text = "\(pizza.name) ($\(pizza.price))"
  }
}
