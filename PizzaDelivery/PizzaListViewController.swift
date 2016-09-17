import UIKit

class PizzaListViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  let pizzaCellIdentifier = "pizza"

  let data = fixtureMenu()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: pizzaCellIdentifier)
  }
}

extension PizzaListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let pizza = data[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: pizzaCellIdentifier, for: indexPath)

    configure(cell, with: pizza)

    return cell
  }

  private func configure(_ cell: UITableViewCell, with pizza: Pizza) {
    cell.textLabel?.text = "\(pizza.name) ($\(pizza.price))"
  }
}
