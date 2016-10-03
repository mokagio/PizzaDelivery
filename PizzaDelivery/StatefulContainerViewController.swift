//
// Note: this code comes from a side project. I meant for it to be opensourced
// but I hadn't had time to polish it yet. That's why is everything in the
// same file
//

import UIKit

/// A reusable enum to use in your `UIViewController` to manage the state of its
/// view in a centralised and mutually exclusive fashion.
enum ViewState<ViewModel> {
  case loading
  //case empty
  case loaded(ViewModel)
  case errored(Error)
}

extension ViewState {
  func boxedToAny() -> ViewState<Any> {
    switch self {
    //case .empty: return .empty
    case .errored(let error): return .errored(error)
    case .loaded(let viewModel): return .loaded(viewModel)
    case .loading: return .loading
    }
  }
}

/// A view controller with the only purpose of containing another one.
/// Useful for changing the current view without touching the navigation stack.
class ContainerViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // We do this because the view is defined not defined in relation to a
    // Storyboard, so it cannot access the layout guide (at least this is what
    // I think causes it)
    // More here:
    // http://stackoverflow.com/questions/17074365/status-bar-and-navigation-bar-appear-over-my-views-bounds-in-ios-7
    if responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)) {
      edgesForExtendedLayout = UIRectEdge()
    }
  }

  func setOnlyChild(_ child: UIViewController) {
    setOnlyChild(child, inView: view)
  }
}

/// A view controller meant to contain another one, with a state enum property
/// and a function to pick the child view controller based on the state.
class StatefulContainerViewController: ContainerViewController {

  var state: ViewState<Any> = .loading {
    didSet {
      update(withState: state)
    }
  }

  var childViewControllerForState: ((ViewState<Any>) -> UIViewController)? = .none

  func update(withState state: ViewState<Any>) {
    guard let child = childViewControllerForState?(state) else {
      return
    }

    setOnlyChild(child)
    copyNavigationItem(fromChild: child)
  }

  fileprivate func copyNavigationItem(fromChild child: UIViewController) {
    // TODO: what about left item, and multiple items?
    navigationItem.rightBarButtonItem = child.navigationItem.rightBarButtonItem

    // TODO: What are the properties that we should copy? Which aren't? Should
    // we do this at all?
    if let parent = parent {
      parent.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
    }
  }
}

func containerViewController<ViewModel>(
  withInitialState state: ViewState<ViewModel>,
  childViewControllerForState: @escaping (ViewState<ViewModel>) -> UIViewController
  ) -> StatefulContainerViewController {
  let s = StatefulContainerViewController()

  // This is a trick to "box" the passed generic function using ViewModel to
  // one using Any, as expected by the view controller due to Objective-C
  // bridgin.
  s.childViewControllerForState = { state in
    switch state {
//    case .empty:
//      return childViewControllerForState(.empty)
    case .errored(let error):
      return childViewControllerForState(.errored(error))
    case .loaded(let viewModel as ViewModel):
      return childViewControllerForState(ViewState.loaded(viewModel))
    case .loaded(_):
      // TODO: fail?
      return UIViewController()
    case .loading:
      return childViewControllerForState(.loading)
    }
  }

  // Important! The state should always be set after the childViewController for
  // state function, otherwise the view controller would not know how to choose
  // the child for the given state.
  s.state = state.boxedToAny()

  return s
}

extension UIViewController {

  /// Sets the given view controller as the only child, removing any previously
  /// set one.
  internal func setOnlyChild(_ child: UIViewController, inView childView: UIView) {
    childViewControllers.forEach { c in
      c.removeFromParentViewController()
      c.view.removeFromSuperview()
    }

    addChildViewController(child)
    addView(child.view, asFullSizeSubviewOf: childView)
    child.didMove(toParentViewController: self)
  }

  // Thanks: https://spin.atomicobject.com/2015/10/13/switching-child-view-controllers-ios-auto-layout/
  internal func addView(_ view: UIView, asFullSizeSubviewOf parentView: UIView) {
    view.translatesAutoresizingMaskIntoConstraints = false
    parentView.addSubview(view)

    var viewBindingsDict = [String: AnyObject]()
    viewBindingsDict["subView"] = view
    parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                             options: [], metrics: nil, views: viewBindingsDict))
    parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                             options: [], metrics: nil, views: viewBindingsDict))
  }
}
