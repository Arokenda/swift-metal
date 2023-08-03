//
//  MTLRenderer.swift
//  MetalTest
//
//  Created by Arokenda on 2023/5/12.
//

import Foundation
import MetalKit
import Metal
import simd

extension matrix_float4x4 {
    init(rotationAngle angle: Float, axis: SIMD3<Float>) {
        let c = cos(angle)
        let s = sin(angle)
        let one_c = 1 - c

        var rotation = matrix_identity_float4x4
        
        rotation[0, 0] = c + axis.x * axis.x * one_c
        rotation[0, 1] = axis.x * axis.y * one_c - axis.z * s
        rotation[0, 2] = axis.x * axis.z * one_c + axis.y * s
        
        rotation[1, 0] = axis.y * axis.x * one_c + axis.z * s
        rotation[1, 1] = c + axis.y * axis.y * one_c
        rotation[1, 2] = axis.y * axis.z * one_c - axis.x * s

        rotation[2, 0] = axis.z * axis.x * one_c - axis.y * s
        rotation[2, 1] = axis.z * axis.y * one_c + axis.x * s
        rotation[2, 2] = c + axis.z * axis.z * one_c
        
        self = rotation
    }
    
    mutating func rotateAroundY(rotationAngle: Int, aspectRatio: Float) {
        let angle = Float(rotationAngle) * .pi / 180
        let modelMatrix = matrix_float4x4(rotationAngle: angle, axis: SIMD3<Float>(0, 1, 0))
        let viewMatrix = matrix_float4x4(rotationAngle: -Float.pi/6, axis: SIMD3<Float>(1, 0, 0))
        let projectionMatrix = matrix_float4x4(perspectiveProjectionFov: Float.pi/3, aspectRatio: aspectRatio, nearZ: -1000, farZ: 1000)
        self = projectionMatrix * viewMatrix * modelMatrix
    }
    
    init(perspectiveProjectionFov fov: Float, aspectRatio: Float, nearZ: Float, farZ: Float) {
        let ys = 1 / tanf(fov * 0.5)
        let xs = ys / aspectRatio
        let zs = farZ / (farZ - nearZ)
        
        self.init()
        columns = (
            SIMD4<Float>(xs, 0, 0, 0),
            SIMD4<Float>(0, ys, 0, 0),
            SIMD4<Float>(0, 0, zs, 1),
            SIMD4<Float>(0, 0, -nearZ * zs, 0)
        )
    }
}


@objcMembers class TriangleRenderer: BaseRenderer {
    
    private var vertexBuffer: MTLBuffer!
    private var colorBuffer: MTLBuffer!
    private var frameCounter:UInt32 = 0
    private var uniformBuffer:MTLBuffer!
    private var projectionMatrix:matrix_float4x4?
    private var rotation:Float = 0
    private var aspectRatio:Float = 0
    
    override func getShaderNamespace() -> String {
        return "Triangle::"
    }
    
    override func loadBuffer() {
            // 顶点buffer
            let vert:[SIMD4<Float>] = [
                SIMD4<Float>(-0.5, 0.5, -1, 1),
                SIMD4<Float>(-0.5, -0.5, -1, 1),
                SIMD4<Float>(0.5, -0.5, -1, 1)
            ]
            vertexBuffer = device.makeBuffer(bytes: vert, length: MemoryLayout<SIMD4<Float>>.size * vert.count, options: .storageModeShared)
            
            let color:[SIMD4<Float>] = [
                SIMD4<Float>(1, 0, 0, 1),
                SIMD4<Float>(0, 1, 0, 1),
                SIMD4<Float>(0, 0, 1, 1)
            ]
            colorBuffer = device.makeBuffer(bytes: color, length: MemoryLayout<SIMD4<Float>>.size * color.count, options: .storageModeShared)
        uniformBuffer = device.makeBuffer(length: MemoryLayout<TriangleUniforms>.stride, options: MTLResourceOptions.storageModeShared)
    }
    
    override func loadAssets() -> Void {
    }
    
    
    override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        let aspect = size.width / size.height;
        aspectRatio = Float(aspect)
        let fov = 65.0 * (.pi / 180.0);
        let nearPlane = 1.0;
        let farPlane = 1500.0;
        projectionMatrix = matrix_perspective_left_hand(Float(fov), Float(aspect), Float(nearPlane), Float(farPlane));
    }
    
    override func draw(in view: MTKView) {
        updateMatrix()
        frameCounter += 1
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "triangle"
        
//        let rotationAngle = frameCounter / 4 % 360
//        _ = Float(view.bounds.width / view.bounds.height)
//        var modelViewProjectionMatrix = rotationMatrix(angle: Float(rotationAngle) / .pi / 2)
////        modelViewProjectionMatrix.rotateAroundY(rotationAngle: Int(rotationAngle), aspectRatio: aspectRatio)
//
//        memcpy(uniformBuffer.contents(), &modelViewProjectionMatrix, MemoryLayout<float4x4>.size)
        
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor )
        renderEncoder?.label = "arokenda"
        renderEncoder?.pushDebugGroup("tirangle")
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setDepthStencilState(depthState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder?.popDebugGroup()
        renderEncoder?.endEncoding()
        guard let drawable = view.currentDrawable else {return}
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    
    func updateMatrix()
    {
        let uniformPointer = uniformBuffer?.contents().bindMemory(to: TriangleUniforms.self, capacity: 1)
//        let modelViewProjectionMatrix = perspectiveMatrix(fovyRadians: radians_from_degrees(65), aspect: aspectRatio, near: -2, far: 100)
        let fov = 65.0 * .pi / 180.0
        let modelViewProjectionMatrix = float4x4(perspectiveProjectionFov: Float(fov), aspectRatio: aspectRatio, nearZ: 0.01, farZ: 100)
        

        uniformPointer?[0].projectionMatrix = modelViewProjectionMatrix
        
        
//        uniforms.projectionMatrix = projectionMatrix ?? matrix_float4x4()
//
        let viewMatrix = matrix_multiply(matrix4x4_translation(0.0, 0, 20),
                                               matrix_multiply(matrix4x4_rotation(-0.5, SIMD3<Float>(1,0,0)),
                                                               matrix4x4_rotation(rotation, SIMD3<Float>(0,1,0) )))
        let rotationAxis = SIMD3<Float>(0, 1, 0)
        var modelMatrix = matrix4x4_rotation(0, rotationAxis)
        let translation = matrix4x4_translation(0.0, 0, 0)
        modelMatrix = matrix_multiply(modelMatrix, translation)

        uniformPointer?[0].modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);

        rotation += 0.01;
    }
    
    func perspectiveMatrix(fovyRadians: Float, aspect: Float, near: Float, far: Float) -> matrix_float4x4
    {
        let yScale = 1 / tanf(fovyRadians * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2.0 * far * near / zRange

        return matrix_float4x4(columns:(vector_float4(xScale, 0.0, 0.0, 0.0),
                                         vector_float4(0.0, yScale, 0.0, 0.0),
                                         vector_float4(0.0, 0.0, zScale, -1.0),
                                         vector_float4(0.0, 0.0, wzScale, 0.0)))
    }
    
    
    func rotationMatrix(angle:Float) -> float4x4 {
        var matrix = float4x4(1.0)
        matrix[0][0] = cos(angle);
        matrix[0][2] = -sin(angle);
        matrix[2][0] = sin(angle);
        matrix[2][2] = cos(angle);
        return matrix;
    }
}

