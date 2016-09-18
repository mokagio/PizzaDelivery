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

  var data: [Pizza]?
  var ads = Ad.dummyAds()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "🍕"

    spinner.hidesWhenStopped = true
    tableView.dataSource = self

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: pizzaCellIdentifier)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: adCellIdentifier)

    tableView.tableFooterView = UIView()

    tableView.isHidden = true
    errorView.isHidden = true

    errorRetryButton.addTarget(self, action: #selector(loadPizzasList), for: .touchUpInside)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // Doing this in didAppear just to ensure audience notices the spinner
    loadPizzasList()
  }

  func loadPizzasList() {
    tableView.isHidden = true
    errorView.isHidden = true
    spinner.startAnimating() // starting animation shows as well

    UIApplication.shared.isNetworkActivityIndicatorVisible = true

    pizzaService.loadPizzas { [weak self] list, error in
      UIApplication.shared.isNetworkActivityIndicatorVisible = false

      guard let `self` = self else {
        return
      }

      self.spinner.stopAnimating() // stop animating hides as well

      if let error = error {
        self.errorView.isHidden = false
        self.errorMessageLabel.text = error.localizedDescription
      } else if let list = list {
        self.tableView.isHidden = false
        self.data = list
        self.tableView.reloadData()
      } else {
        fatalError("Pizza service returned neither pizza list nor error")
      }
    }
  }
}

extension PizzaListViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let data = data else {
      return 0
    }

    return data.count + ads.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let data = data else {
      return UITableViewCell()
    }

    // Every x pizzas display an ad
    let interval = 4
    let displayedAds = indexPath.row / interval

    if indexPath.row < (interval - 1) || indexPath.row % interval != 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: pizzaCellIdentifier, for: indexPath)
      let pizza = data[indexPath.row - displayedAds]
      configure(cell, with: pizza)
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: adCellIdentifier, for: indexPath)
      let ad = ads[displayedAds - 1]
      cell.textLabel?.text = ad.message
      cell.textLabel?.textAlignment = .center
      cell.textLabel?.textColor = UIColor.white
      cell.backgroundColor = ad.color
      return cell
    }
  }

  private func configure(_ cell: UITableViewCell, with pizza: Pizza) {
    cell.textLabel?.text = "\(pizza.name) ($\(pizza.price))"
  }
}
