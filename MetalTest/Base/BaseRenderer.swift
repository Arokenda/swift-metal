//
//  BaseRenderer.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

import UIKit
import MetalKit

@objcMembers class BaseRenderer: NSObject, MTKViewDelegate {
    
    var device: MTLDevice!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var depthState: MTLDepthStencilState!

    
    init?(metalKitView: MTKView) {
        super.init()
        device = metalKitView.device
        guard loadMetalWith(mtkView: metalKitView) else {return nil}
        loadBuffer()
        loadAssets()
    }
    
    func getShaderNamespace() -> String {
        return ""
    }
    
    private func loadMetalWith(mtkView: MTKView) -> Bool {
        mtkView.depthStencilPixelFormat = .depth32Float_stencil8
        mtkView.colorPixelFormat = .bgra8Unorm_srgb
        mtkView.sampleCount = 1
        
        let defaultLibrary = device.makeDefaultLibrary()
        
        let vertexFunction = defaultLibrary?.makeFunction(name: self.getShaderNamespace() + "vertexShader")
        let fragmentFunction = defaultLibrary?.makeFunction(name:self.getShaderNamespace() + "fragmentShader")
        if ((vertexFunction == nil) || (fragmentFunction == nil)) {
            print("vertext or fragment function is nil")
            return false
        }
        
        let pipelineStateDescriptor = createRenderPipelineDescriptorWith(mtkView: mtkView)
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch {
            print("Unable to compile render pipeline state.  Error info: \(error)")
            return false
        }
        
        let depthStateDesc = MTLDepthStencilDescriptor()
        depthStateDesc.depthCompareFunction = .less
        depthStateDesc.isDepthWriteEnabled = true
        depthState = device.makeDepthStencilState(descriptor: depthStateDesc)
        
        commandQueue = device.makeCommandQueue()
        
        return true
    }
    
    func createRenderPipelineDescriptorWith(mtkView: MTKView) -> MTLRenderPipelineDescriptor {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "arokenda"
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat
        return pipelineStateDescriptor
    }
    
    func loadBuffer() -> Void {
        
    }
    
    func loadAssets() -> Void {
    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        
    }
    
    //补全代理
    
    
    
    
}
