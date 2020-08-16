import UIKit

/// A singleton object for managing orientation. Used by the video player when it forces an orientation change when it transitions to fullscreen, or can be used by the scene delegate to preserve an app's forced orientation.
class OrientationManager {
  /// A singleton objects static property useful for when a scene becomes inactive. The current orientation can be stored, and then can restored when the scene becomes active again.
  static var currentOrientation: UIInterfaceOrientation?
  /// A singleton objects property that stores a previous orientation when the video player forces an orientation change to landscape, when it goes to fullscreen. If it exists when the app is switching back to an inline player, this orientation is restored
  static var previousOrientation: UIInterfaceOrientation?
  private init() {}
}


