import SwiftUI
import UIKit
import AVKit

extension AVPlayerViewController: AVPlayerViewControllerDelegate {
  public func playerViewController(_ playerViewController: AVPlayerViewController,
                            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    let previousOrientation = self.view.window!.windowScene!.interfaceOrientation
    coordinator.animate(alongsideTransition: nil) { transitionContext in
      if previousOrientation.isPortrait {
        OrientationManager.previousOrientation = previousOrientation
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
      }
    }
  }
  
  public func playerViewController(_ playerViewController: AVPlayerViewController,
                            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: nil) { transitionContext in
      if OrientationManager.previousOrientation != nil {
        UIDevice.current.setValue(OrientationManager.previousOrientation!.rawValue, forKey: "orientation")
      }
    }
  }
}

extension AVPlayerViewController {
  override open var prefersStatusBarHidden: Bool {
    if self.view.window?.windowScene?.interfaceOrientation.isLandscape ?? false {
      return true
    } else {
      return false
    }
  }
}

struct VideoViewController: UIViewControllerRepresentable {
  @Binding var url: URL
  @Binding var rotateOnFullscreen:  Bool
  let viewControllerHandler: (UIViewControllerType) -> Void
  typealias UIViewControllerType = AVPlayerViewController
  
  func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
    let player = AVPlayer(url: self.url)
    let viewController = AVPlayerViewController()
    if self.rotateOnFullscreen {
      let delegate =  viewController
      viewController.delegate = delegate
    }
    viewController.player = player
    viewControllerHandler(viewController)
    return viewController
  }
  
  func updateUIViewController(_: Self.UIViewControllerType, context: Self.Context) {
  }
}

struct VideoPlayer: View {
  @State var url: URL
  @State var rotateOnFullscreen = false
  let viewControllerHandler: (AVPlayerViewController) -> Void = { _ in }
  

  var body: some View {
    return GeometryReader { geometry in
      VStack {
        self.body(for: geometry.size)
      }
    }
  }
  
  func body(for dimensions: CGSize) -> some View {
    let givenWidth = dimensions.width
    let givenHeight = dimensions.height
    
    if 9 * givenWidth < 16 * givenHeight {
      return VideoViewController(url: self.$url, rotateOnFullscreen: self.$rotateOnFullscreen, viewControllerHandler: self.viewControllerHandler).frame(width: givenWidth, height: (9/16) * givenWidth)
    } else  {
      return VideoViewController(url: self.$url, rotateOnFullscreen: self.$rotateOnFullscreen, viewControllerHandler: self.viewControllerHandler).frame(width: (16/9) * givenHeight, height: givenHeight)
    }
  }
}



struct VideoViewController_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VideoPlayer(url: URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!, rotateOnFullscreen: true)
        .previewLayout(PreviewLayout.fixed(width: 414, height: 818))
        .previewDisplayName("Width less than height")

      VideoPlayer(url: URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!, rotateOnFullscreen: true)
        .previewLayout(PreviewLayout.fixed(width: 616, height: 414))
        .previewDisplayName("Width more than height")
    }
  }
}
