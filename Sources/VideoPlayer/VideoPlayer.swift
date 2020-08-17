import SwiftUI
import UIKit
import AVKit

class Delegate: NSObject, AVPlayerViewControllerDelegate {
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
  
  class Coordinator: NSObject, AVPlayerViewControllerDelegate {
    var parent: VideoViewController
    
    init(_ parent: VideoViewController) {
        self.parent = parent
    }
    
    public func playerViewController(_ playerViewController: AVPlayerViewController,
                                     willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      let previousOrientation = playerViewController.view.window!.windowScene!.interfaceOrientation
      coordinator.animate(alongsideTransition: nil) { transitionContext in
        if previousOrientation.isPortrait && self.parent.rotateOnFullscreen {
          OrientationManager.previousOrientation = previousOrientation
          UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
      }
    }
    
    public func playerViewController(_ playerViewController: AVPlayerViewController,
                                     willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
      coordinator.animate(alongsideTransition: nil) { transitionContext in
        if OrientationManager.previousOrientation != nil && self.parent.rotateOnFullscreen {
          UIDevice.current.setValue(OrientationManager.previousOrientation!.rawValue, forKey: "orientation")
        }
      }
    }
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  @Binding var player: AVPlayer
  @Binding var rotateOnFullscreen:  Bool
  let viewControllerHandler: (UIViewControllerType) -> Void
  typealias UIViewControllerType = AVPlayerViewController
  
  func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
    let player = self.player
    let viewController = AVPlayerViewController()
    viewController.delegate = context.coordinator
    viewController.player = player
    viewControllerHandler(viewController)
    return viewController
  }
  
  func updateUIViewController(_: Self.UIViewControllerType, context: Self.Context) {
  }
}

public struct VideoPlayer: View {
  @State var player: AVPlayer
  @State var rotateOnFullscreen: Bool
  let widthMultiplier: CGFloat
  let heightMultiplier: CGFloat
  let viewControllerHandler: (AVPlayerViewController) -> Void
  
  public init(player: AVPlayer, rotateOnFullscreen: Bool = false, widthMultiplier: CGFloat = 16, heightMultiplier: CGFloat = 9,  viewControllerHandler: @escaping (AVPlayerViewController) -> Void  =  { _ in }) {
    self._player = State(initialValue: player)
    self.widthMultiplier = widthMultiplier
    self.heightMultiplier = heightMultiplier
    self._rotateOnFullscreen = State(initialValue: rotateOnFullscreen)
    self.viewControllerHandler = viewControllerHandler
  }
  
  public var body: some View {
    return GeometryReader { geometry in
      VStack {
        self.body(for: geometry.size)
      }
    }
  }
  
  func body(for dimensions: CGSize) -> some View {
    let givenWidth = dimensions.width
    let givenHeight = dimensions.height
    
    // if the givenWidth is the limiting dimension for an aspect fit
    if self.heightMultiplier * givenWidth < self.widthMultiplier * givenHeight {
      // use that as the limiting dimension and calculate a new height
      return VideoViewController(player: self.$player, rotateOnFullscreen: self.$rotateOnFullscreen, viewControllerHandler: self.viewControllerHandler).frame(width: givenWidth, height: (self.heightMultiplier/self.widthMultiplier) * givenWidth)
    } else  {
      // else use the height as the limiting dimension
      return VideoViewController(player: self.$player, rotateOnFullscreen: self.$rotateOnFullscreen, viewControllerHandler: self.viewControllerHandler).frame(width: (self.widthMultiplier/self.heightMultiplier) * givenHeight, height: givenHeight)
    }
  }
}



struct VideoViewController_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VideoPlayer(player: AVPlayer(url: URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!), rotateOnFullscreen: true)
        .previewLayout(PreviewLayout.fixed(width: 414, height: 818))
        .previewDisplayName("Width less than height")
      
      VideoPlayer(player: AVPlayer(url:  URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!), rotateOnFullscreen: true)
        .previewLayout(PreviewLayout.fixed(width: 616, height: 414))
        .previewDisplayName("Width more than height")
    }
  }
}
