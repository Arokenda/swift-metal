//
//  ObjModelRenderer.swift
//  MetalTest
//
//  Created by Arokenda on 2023/7/24.
//

import Foundation
import MetalKit
import Metal
import simd

struct ObjModelVertex {
    var position: vector_float3
    var color: vector_float4
    var texture: vector_float2
    var normal: vector_float3
}

@objcMembers class ObjModelRenderer: BaseRenderer {
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var textures: [MTLTexture]!
    var samplerState: MTLSamplerState!
    
    var projectionMatrix: matrix_float4x4!
    var modelViewMatrix: matrix_float4x4!
    var rotation: Float = 0.0
    
    override func getShaderNamespace() -> String {
        return "ObjModel::"
    }
    
//    override func createRenderPipelineDescriptorWith(mtkView: MTKView) -> MTLRenderPipelineDescriptor {
//        defaultVertexDescriptor = MTLVertexDescriptor()
//        defaultVertexDescriptor?.attributes[0].format = .float3
//        defaultVertexDescriptor?.attributes[0].offset = 0
//        defaultVertexDescriptor?.attributes[0].bufferIndex = 0
//
//        defaultVertexDescriptor?.attributes[1].format = .float2
//        defaultVertexDescriptor?.attributes[1].offset = 12
//        defaultVertexDescriptor?.attributes[1].bufferIndex = 0
//
//        // Normals
//        defaultVertexDescriptor?.attributes[2].format = .half4;
//        defaultVertexDescriptor?.attributes[2].offset = 20;
//        defaultVertexDescriptor?.attributes[2].bufferIndex = 0;
//
//        defaultVertexDescriptor?.layouts[0].stride = 44
//        defaultVertexDescriptor?.layouts[0].stepFunction = .perVertex
//        defaultVertexDescriptor?.layouts[0].stepRate = 1
//
//        let pipelineStateDescriptor = super.createRenderPipelineDescriptorWith(mtkView: mtkView)
//        pipelineStateDescriptor.vertexDescriptor = defaultVertexDescriptor
//        return pipelineStateDescriptor
//    }
//
    override func loadBuffer() {

       let mesh = loadModel()
       self.buildBuffers(mesh: mesh)
       self.buildTextures(mesh: mesh)

       let samplerDescriptor = MTLSamplerDescriptor()
       samplerDescriptor.minFilter = .linear
       samplerDescriptor.magFilter = .linear
       samplerDescriptor.mipFilter = .linear
       self.samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
    }
    
    override func loadAssets() {
        
    }
    
    override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.projectionMatrix = matrix_perspective_left_hand(Float.pi / 4, Float(size.width) / Float(size.height), 0.1, 100.0)
    }
    
    override func draw(in view: MTKView) {
        updateMatrix()
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "objModel"
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor )
        renderEncoder?.label = "arokenda"
        renderEncoder?.pushDebugGroup("mesh")
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthState)
        
        renderEncoder?.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(self.indexBuffer, offset: 0, index: 1)

        for chunk in 0..<self.indexBuffer.length/MemoryLayout<UInt16>.size/3 {
            renderEncoder?.setFragmentTexture(self.textures[chunk], index: 0)
            renderEncoder?.setFragmentSamplerState(self.samplerState, index: 0)

            var modelViewProjectionMatrix = matrix_identity_float4x4
            modelViewProjectionMatrix = matrix_multiply(projectionMatrix, modelViewProjectionMatrix)
            modelViewProjectionMatrix = matrix_multiply(modelViewMatrix, modelViewProjectionMatrix)

            renderEncoder?.setVertexBytes(&modelViewProjectionMatrix, length: MemoryLayout<float4x4>.stride, index: 2)

            let range = chunk * 3..<chunk * 3 + 3
            renderEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: 3, indexType: .uint16, indexBuffer: self.indexBuffer, indexBufferOffset: MemoryLayout<UInt16>.size * range.startIndex)
        }
        
        renderEncoder?.popDebugGroup()
        renderEncoder?.endEncoding()
        guard let drawable = view.currentDrawable else {return}
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    //Mark: - private methods
    
    
    func updateMatrix()
    {
//        guard let uniformPointer = uniformBuffer?.contents().bindMemory(to: MeshUniforms.self, capacity: 1) else {return}
//
//        //P
//        uniformPointer[0].projectionMatrix = projectionMatrix
//
//        //V
//        uniformPointer[0].viewMatrix = matrix_multiply(matrix4x4_translation(0.0, -100, 1100),
//                                                       matrix4x4_rotation(-0.5, SIMD3<Float>(1,0,0)))
//
//        //M
//        uniformPointer[0].modelMatrix = matrix_multiply(matrix4x4_rotation(rotation, SIMD3<Float>(0,1,0)),
//                                                         matrix4x4_translation(0, 0, 0))
//
//        //MV
//        uniformPointer[0].modelViewMatrix = matrix_multiply((uniformPointer[0].viewMatrix), (uniformPointer[0].modelMatrix))
//
////        let viewMatrix = matrix_multiply(matrix4x4_translation(0.0, 0, 1000),
////                                        matrix_multiply(matrix4x4_rotation(-0.5, SIMD3<Float>(1,0,0)),
////                                        matrix4x4_rotation(rotation, SIMD3<Float>(0,1,0) )))
////        let rotationAxis = SIMD3<Float>(0, 1, 0)
////        var modelMatrix = matrix4x4_rotation(0, rotationAxis)
////        let translation = matrix4x4_translation(0.0, 0, 0)
////        modelMatrix = matrix_multiply(modelMatrix, translation)
////
////        uniformPointer?[0].modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);
//
//        // 平行光
//        uniformPointer[0].directionalLightDirection = SIMD3<Float>(-1.0,-1.0,-1.0)
//        uniformPointer[0].directionalLightColor = SIMD3<Float>(0.8,0.8,0.8)
//        uniformPointer[0].IL = 10.0;
//        uniformPointer[0].Kd = 0.1;
//        uniformPointer[0].Ks = 0.9;
//        uniformPointer[0].shininess = 15;
//        uniformPointer[0].Ia = 3.0;
//        uniformPointer[0].Ka = 0.1;
//
//        uniformPointer[0].cameraPos = SIMD3<Float>(0,100,-1100)
//
//        rotation += 0.01;
    }
    
    func loadModel() -> MDLMesh {
         let allocator = MTKMeshBufferAllocator(device: self.device)

         let assetURL = Bundle.main.url(forResource: "piper_pa18", withExtension: "obj")!
        
        let defaultVertexDescriptor = MTLVertexDescriptor()
        defaultVertexDescriptor.attributes[0].format = .float3
        defaultVertexDescriptor.attributes[0].offset = 0
        defaultVertexDescriptor.attributes[0].bufferIndex = 0

        defaultVertexDescriptor.attributes[1].format = .float2
        defaultVertexDescriptor.attributes[1].offset = 12
        defaultVertexDescriptor.attributes[1].bufferIndex = 0

        // Normals
        defaultVertexDescriptor.attributes[2].format = .half4;
        defaultVertexDescriptor.attributes[2].offset = 20;
        defaultVertexDescriptor.attributes[2].bufferIndex = 0;

        defaultVertexDescriptor.layouts[0].stride = 44
        defaultVertexDescriptor.layouts[0].stepFunction = .perVertex
        defaultVertexDescriptor.layouts[0].stepRate = 1
        let vertexDescriptor = MTKModelIOVertexDescriptorFromMetal(defaultVertexDescriptor)
         let asset = MDLAsset(url: assetURL,
                              vertexDescriptor: vertexDescriptor,
                              bufferAllocator: allocator)
         let mesh = asset.object(at: 0) as! MDLMesh
         return mesh
     }
    
    func buildBuffers(mesh: MDLMesh) {
        let vertexBuffer = self.buildVertexBuffer(mesh: mesh)

        self.vertexBuffer = vertexBuffer.buffer
        self.indexBuffer = vertexBuffer.indexBuffer
    }

    func buildTextures(mesh: MDLMesh) {
        let textureLoader = MTKTextureLoader(device: device)

        textures = []
        mesh.submeshes?.forEach({subMesh in
            let material = (subMesh as! MDLSubmesh).material
            var texture: MTLTexture?
            if let baseColor = material?.property(with: .baseColor),
                baseColor.type == .string,
                let baseColorString = baseColor.stringValue,
                let baseColorURL = Bundle.main.url(forResource: baseColorString, withExtension: nil) {
                texture = try? textureLoader.newTexture(URL: baseColorURL, options: nil)
            }
            if texture == nil {
                let dummyTexture = UIImage(named: "parts1")!
                texture = try? textureLoader.newTexture(cgImage: dummyTexture.cgImage!, options: nil)
            }
            textures!.append(texture!)
        })
    }

    func buildVertexBuffer(mesh: MDLMesh) -> (buffer: MTLBuffer, indexBuffer: MTLBuffer) {
        var vertices: [ObjModelVertex] = []
        var indices: [UInt16] = []
        let vertexBuffer = mesh.vertexBuffers[0]
        let subMesh = mesh.submeshes?.firstObject as! MDLSubmesh
        let indexBuffer = subMesh.indexBuffer
        
        for _ in 0..<mesh.vertexCount {
            let vert = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                          format: .float3,
                                          offset: 0,
                                          bufferIndex: 0)
            let vertexData = vertexBuffer.map().bytes.advanced(by: vert.offset)
            let position = vertexData.assumingMemoryBound(to: Float.self)
            let normal = vector_float3(0, 0, 1)
            var texCoord = vector_float2(0, 0)
            if let texCoords = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributeTextureCoordinate),
                texCoords.format == .float2,
                let texCoordData = texCoords.dataStart as UnsafeMutableRawPointer? {
                texCoord = UnsafeRawPointer(texCoordData + texCoords.stride).bindMemory(to: vector_float2.self, capacity: 1).pointee
            }
            let vertex = ObjModelVertex(position: vector_float3(position[0], position[1], position[2]),
                                color: vector_float4(1.0, 1.0, 1.0, 1.0),
                                texture: texCoord,
                                normal: normal)
            vertices.append(vertex)
        }

        var i = 0
        indexBuffer.map().bytes.bindMemory(to: UInt16.self, capacity: indexBuffer.length / MemoryLayout<UInt16>.stride).debugDescription.forEach { index in
            indices.append(UInt16(index.unicodeScalars.first!.value))
            i += 1
        }

        let vertexLength = vertices.count * MemoryLayout<ObjModelVertex>.size
        let vbuffer = device.makeBuffer(bytes: vertices, length: vertexLength, options: [])

        let indexLength = indices.count * MemoryLayout<UInt16>.size
        let iBuffer = device.makeBuffer(bytes: indices, length: indexLength, options: [])

        return (buffer: vbuffer!, indexBuffer: iBuffer!)
    }
}
