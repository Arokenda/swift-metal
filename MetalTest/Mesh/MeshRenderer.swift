//
//  MeshRenderer.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/19.
//

import Foundation
import MetalKit
import Metal
import simd

@objcMembers class MeshRenderer: BaseRenderer {
    
    private var meshAry:[AAPLMesh]?
    private var defaultVertexDescriptor:MTLVertexDescriptor?
    private var uniformBuffer:MTLBuffer?
    private var colorBuffer:MTLBuffer?
    private var projectionMatrix:matrix_float4x4 = matrix_float4x4()
    private var rotation:Float = 0
    
    
    override func getShaderNamespace() -> String {
        return "Mesh::"
    }
    
    override func createRenderPipelineDescriptorWith(mtkView: MTKView) -> MTLRenderPipelineDescriptor {
        defaultVertexDescriptor = MTLVertexDescriptor()
        defaultVertexDescriptor?.attributes[0].format = .float3
        defaultVertexDescriptor?.attributes[0].offset = 0
        defaultVertexDescriptor?.attributes[0].bufferIndex = 0
        
        defaultVertexDescriptor?.attributes[1].format = .float2
        defaultVertexDescriptor?.attributes[1].offset = 12
        defaultVertexDescriptor?.attributes[1].bufferIndex = 0
        
        // Normals
        defaultVertexDescriptor?.attributes[2].format = .half4;
        defaultVertexDescriptor?.attributes[2].offset = 20;
        defaultVertexDescriptor?.attributes[2].bufferIndex = 0;
        
        defaultVertexDescriptor?.layouts[0].stride = 44
        defaultVertexDescriptor?.layouts[0].stepFunction = .perVertex
        defaultVertexDescriptor?.layouts[0].stepRate = 1
        
        let pipelineStateDescriptor = super.createRenderPipelineDescriptorWith(mtkView: mtkView)
        pipelineStateDescriptor.vertexDescriptor = defaultVertexDescriptor
        return pipelineStateDescriptor
    }
    
    override func loadBuffer() {
        uniformBuffer = device.makeBuffer(length: MemoryLayout<MeshUniforms>.stride, options: MTLResourceOptions.storageModeShared)
        colorBuffer = device.makeBuffer(length: MemoryLayout<MeshFloat3Wrapper>.stride, options: MTLResourceOptions.storageModeShared)
    }
    
    override func loadAssets() {
       
        let modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(defaultVertexDescriptor ?? MTLVertexDescriptor())
        (modelIOVertexDescriptor.attributes[0] as! MDLVertexAttribute).name  = MDLVertexAttributePosition;
        (modelIOVertexDescriptor.attributes[1] as! MDLVertexAttribute).name  = MDLVertexAttributeTextureCoordinate;
        (modelIOVertexDescriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
//        (modelIOVertexDescriptor.attributes[3] as! MDLVertexAttribute).name   = MDLVertexAttributeTangent;
//        (modelIOVertexDescriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent;
//        let url = Bundle.main.url(forResource: "piper_pa18", withExtension: "obj")!
//        let url = Bundle.main.url(forResource: "Temple2", withExtension: "obj")!
        let url = Bundle.main.url(forResource: "1967-shelby-ford-mustang", withExtension: "obj")!
        
        meshAry = try? AAPLMesh .newMeshes(from: url, modelIOVertexDescriptor: modelIOVertexDescriptor, metalDevice: device)
    
    
    }
    
    override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = size.width / size.height;
        let fov = 65.0 * (.pi / 180.0);
        let nearPlane = 1.0;
        let farPlane = 3000.0;
        projectionMatrix = matrix_perspective_left_hand(Float(fov), Float(aspect), Float(nearPlane), Float(farPlane));
    }
    
    override func draw(in view: MTKView) {
        updateMatrix()
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "mesh"
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor )
        renderEncoder?.label = "arokenda"
        renderEncoder?.pushDebugGroup("mesh")
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthState)
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderEncoder?.setFragmentBuffer(uniformBuffer, offset: 0, index: 1)
        drawMeshes(renderEncoder: renderEncoder)
   
        renderEncoder?.popDebugGroup()
        renderEncoder?.endEncoding()
        guard let drawable = view.currentDrawable else {return}
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    func updateMatrix()
    {
//        var uniformPointer = uniformBuffer?.contents().bindMemory(to: MeshUniforms.self, capacity: 1)[0]
//        uniformPointer?.projectionMatrix = projectionMatrix
        guard let uniformPointer = uniformBuffer?.contents().bindMemory(to: MeshUniforms.self, capacity: 1) else {return}
        
        //P
        uniformPointer[0].projectionMatrix = projectionMatrix
        
        //V
//        uniformPointer[0].viewMatrix = matrix_multiply(matrix4x4_translation(0.0, -100, 2500),
//                                                       matrix4x4_rotation(-0.5, SIMD3<Float>(1,0,0)))
        //V
        uniformPointer[0].viewMatrix = matrix_multiply(matrix4x4_translation(0.0, 0, 20),
                            matrix4x4_rotation(-0.5, SIMD3<Float>(1,0,0)))
        
        //M
        uniformPointer[0].modelMatrix = matrix_multiply(matrix4x4_rotation(rotation, SIMD3<Float>(0,1,0)),
                            matrix4x4_translation(0, 0, 0))
        
        //MV
        uniformPointer[0].modelViewMatrix = matrix_multiply((uniformPointer[0].viewMatrix),
                            (uniformPointer[0].modelMatrix))
        
        // 平行光
        uniformPointer[0].directionalLightDirection = SIMD3<Float>(-1.0,-1.0,-1.0)
        uniformPointer[0].directionalLightColor = SIMD3<Float>(0.8,0.8,0.8)
        uniformPointer[0].IL = 10.0;
        uniformPointer[0].Kd = 0.1;
        uniformPointer[0].Ks = 0.9;
        uniformPointer[0].shininess = 15;
        uniformPointer[0].Ia = 3.0;
        uniformPointer[0].Ka = 0.1;
        
        uniformPointer[0].cameraPos = SIMD3<Float>(0,100,-1100)

        rotation += 0.01;
    }
    
    
    /// Draw the mesh objects with the given render command encoder.
    func drawMeshes(renderEncoder : MTLRenderCommandEncoder?)
    {
        //遍历meshAry
        
        for mesh in meshAry! {
            let metalKitMesh = mesh.metalKitMesh

            // Set the mesh's vertex buffers.
            for bufferIndex in 0..<metalKitMesh.vertexBuffers.count {
                let vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
                renderEncoder?.setVertexBuffer(vertexBuffer.buffer, offset: vertexBuffer.offset, index: bufferIndex)
            }

            // Draw each submesh of the mesh.
            for submesh in mesh.submeshes  {
                // Set any textures that you read or sample in the render pipeline.
                if let texture = submesh.colorTexture as MTLTexture? {
                    renderEncoder?.setFragmentTexture(texture, index: 0)
                }
                let colorPointer = colorBuffer?.contents().bindMemory(to: MeshFloat3Wrapper.self, capacity: 1)
                colorPointer?[0].color =  submesh.color
                renderEncoder?.setFragmentBuffer(colorBuffer, offset: 0, index: 2)
//                if let texture1 = submesh.textures[1] as? MTLTexture {
//                    renderEncoder?.setFragmentTexture(texture1, index: 1)
//                }
//                if let texture2 = submesh.textures[2] as? MTLTexture {
//                    renderEncoder?.setFragmentTexture(texture2, index: 2)
//                }

                let metalKitSubmesh = submesh.metalKitSubmmesh;

                renderEncoder?.drawIndexedPrimitives(type: metalKitSubmesh.primitiveType, indexCount: metalKitSubmesh.indexCount, indexType: metalKitSubmesh.indexType, indexBuffer: metalKitSubmesh.indexBuffer.buffer, indexBufferOffset: metalKitSubmesh.indexBuffer.offset)
            }
        }
    }

}
