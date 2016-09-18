import UIKit

class PizzaListViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  let pizzaService = PizzaService()

  let pizzaCellIdentifier = "pizza"

  var data: [Pizza]?

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: pizzaCellIdentifier)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Doing this in didAppear just to ensure audience notices the spinner
    pizzaService.loadPizzas { [weak self] list, error in
      guard let `self` = self else {
        return
      }
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
