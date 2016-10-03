import UIKit

class LoadingViewController: UIViewController {

  init() {
    super.init(nibName: "LoadingViewController", bundle: .none)
  }

  @available(*, unavailable)
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    fatalError()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
