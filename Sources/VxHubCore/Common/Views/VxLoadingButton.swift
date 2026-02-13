#if canImport(UIKit)
//import UIKit
//
//public protocol Loadable {
//  func showLoadingView()
//  func hideLoadingView()
//}
//
//// MARK: - UIButton
//public extension Loadable where Self: UIButton {
//
//  func showLoadingView() {
//    let activityIndicator = UIActivityIndicatorView(style: .medium)
//    addSubview(activityIndicator)
//    addSubview(activityIndicator)
//    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//    activityIndicator.startAnimating()
//    activityIndicator.tag = ConstantsLoadable.loadingViewTag
//    isUserInteractionEnabled = false
//  }
//
//  func hideLoadingView() {
//    subviews.forEach { subview in
//      if subview.tag == ConstantsLoadable.loadingViewTag {
//        subview.removeFromSuperview()
//      }
//    }
//    isUserInteractionEnabled = true
//  }
//}
#endif
