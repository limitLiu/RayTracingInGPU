import Metal

protocol PathTracer {
  var device: (any MTLDevice)? { get }
  var queue: (any MTLCommandQueue)? { get }
  var pipeline: (any MTLRenderPipelineState)? { get }

  func render()
}
