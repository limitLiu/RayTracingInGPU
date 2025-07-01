import Cocoa
import MetalKit

class ViewController: NSViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    (view as? MetalView)?.delegate = self
  }

  override var representedObject: Any? {
    didSet {}
  }
}

extension ViewController: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

  func draw(in view: MTKView) {
    if let v = view as? PathTracer {
      v.render()
    }
  }
}
