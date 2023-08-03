//
//  vertext.metal
//  MetalTest
//
//  Created by Arokenda on 2023/5/12.
//

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "TriangleShaderTypes.h"

using namespace metal;

namespace Triangle {
    
    typedef struct
    {
        float4 position [[position]];
        float4 color;
    } ColorInOut;
    
    struct Uniforms {
        float4x4 modelViewProjectionMatrix;
    };
    
    vertex ColorInOut vertexShader(uint vid [[vertex_id]],
                                   constant float4 *position [[buffer(0)]],
                                   constant float4 *color [[ buffer(1) ]],
                                   constant TriangleUniforms &uniforms [[buffer(2)]])
    {
        
        // 定义平移矩阵
        float4x4 translationMatrix = float4x4(1.0);
        translationMatrix.columns[3].z = 1;
        
        ColorInOut out;
        out.position = position[vid];
        out.color = color[vid];
        out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * translationMatrix * out.position;
        
        return out;
    }
    
    fragment float4 fragmentShader(ColorInOut in [[stage_in]])
    {
        //    return float4(1.0, 0.0, 0.0, 1.0);
        return in.color * float4(0.5, 0.5, 0.5, 1.0);
    }
}
