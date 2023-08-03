//
//  TextureRenderer.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

import Foundation
import MetalKit
import Metal

@objcMembers class TextureRenderer: BaseRenderer {
    
    private var vertexBuffer: MTLBuffer!
    private var colorBuffer: MTLBuffer!
    private var texture: MTLTexture!
    
    override func getShaderNamespace() -> String {
        return "Texture::"
    }
    
    override func loadAssets() {
        // 顶点buffer
        let vert:[SIMD2<Float>] = [
            SIMD2<Float>(-1.0, -1.0),SIMD2<Float>(0.0, 1.0),
            SIMD2<Float>(-1.0, 1.0),SIMD2<Float>(0.0, 0.0),
            SIMD2<Float>(1.0, -1.0),SIMD2<Float>(1.0, 1.0),
            SIMD2<Float>(1.0, 1.0),SIMD2<Float>(1.0,0.0)
        ]
        
        vertexBuffer = device.makeBuffer(bytes: vert, length: MemoryLayout<SIMD4<Float>>.size * vert.count, options: .storageModeShared)
        
        let textureLoader = MTKTextureLoader(device: device)
        let textureLoaderOptions = [
            MTKTextureLoader.Option.textureUsage: NSNumber(value: MTLTextureUsage.shaderRead.rawValue),
            MTKTextureLoader.Option.textureStorageMode : NSNumber(value: MTLStorageMode.private.rawValue)
        ]

        texture = try! textureLoader.newTexture(name: "lyf", scaleFactor: 1.0, bundle: nil, options: textureLoaderOptions)
        
    }
    
    override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    override func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "texture"
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor )
        renderEncoder?.label = "arokenda"
        renderEncoder?.pushDebugGroup("texture")
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthState)
        renderEncoder?.setFragmentTexture(texture, index: 0)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertexBuffer.length, instanceCount: 1)
        renderEncoder?.popDebugGroup()
        renderEncoder?.endEncoding()
        guard let drawable = view.currentDrawable else {return}
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
