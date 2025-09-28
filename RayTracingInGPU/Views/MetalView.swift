import MetalKit

class MetalView: MTKView {
  required init(coder: NSCoder) {
    super.init(coder: coder)
    device = MTLCreateSystemDefaultDevice()
    _queue = device?.makeCommandQueue()
    createPipeline()
    // default mode
    // isPaused = false
    // enableSetNeedsDisplay = false
  }
  private var _queue: (any MTLCommandQueue)?
  private var _pipeline: (any MTLRenderPipelineState)?
}

extension MetalView: PathTracer {
  var queue: (any MTLCommandQueue)? { _queue }
  var pipeline: (any MTLRenderPipelineState)? { _pipeline }
}

extension MetalView {
  private func createPipeline() {
    if let device, let library = device.makeDefaultLibrary() {
      let renderPipelineDesc = MTLRenderPipelineDescriptor()
      renderPipelineDesc.vertexFunction = library.makeFunction(name: "vertexFn")
      renderPipelineDesc.fragmentFunction = library.makeFunction(name: "fragmentFn")
      renderPipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
      _pipeline = try? device.makeRenderPipelineState(descriptor: renderPipelineDesc)
    }
  }

  func render() {
    guard let device = device else { fatalError("Failed to find default device.") }
    let vertexData: [Float] = [
      -1.0, 1.0,
      -1.0, -1.0,
      1.0, 1.0,
      1.0, 1.0,
      -1.0, -1.0,
      1.0, -1.0,
    ]
    let dataSize = vertexData.count * MemoryLayout<Float>.size
    let vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    var uniforms = Uniforms(width: UInt32(drawableSize.width), height: UInt32(drawableSize.height))
    let uniformBuffer = device.makeBuffer(bytes: &uniforms, length: MemoryLayout<Uniforms>.stride)
    let renderPassDesc = MTLRenderPassDescriptor()
    if let currentDrawable {
      renderPassDesc.colorAttachments[0].texture = currentDrawable.texture
      renderPassDesc.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0, alpha: 1.0)
      renderPassDesc.colorAttachments[0].loadAction = .clear
      guard let queue else { fatalError("Failed to make command queue.") }
      let commandBuffer = queue.makeCommandBuffer()
      guard let commandBuffer else { fatalError("Failed to make command buffer.") }
      let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)
      guard let encoder = encoder else { fatalError("Failed to make render command encoder.") }
      if let pipeline {
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6, instanceCount: 2)
        encoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
      }
    }
  }
}
