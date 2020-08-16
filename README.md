# VideoPlayer

[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) 

A video player written in SwiftUI that provides access to the underlying AVPlayerViewController. It allows you to pass a custom closure to the AVPlayerViewController, and to obtain access to its delegate. Accepts an additional argument that allows the player to automatically rotate to landscape when going into fullscreen (this works on iPhones only).

By default this SwiftUI view will try to fit the the all the available space provided to it with a 16:9 ratio when the underlying AVPlayer is not fullscreen. It is centered in the provided container.
