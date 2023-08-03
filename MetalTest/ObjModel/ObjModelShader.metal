//
//  ObjModelShader.metal
//  MetalTest
//
//  Created by Arokenda on 2023/7/24.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

namespace ObjModel {
    struct VertexIn {
        float4 position [[attribute(0)]];
        float4 color [[attribute(1)]];
        float2 texture [[attribute(2)]];
        float3 normal [[attribute(3)]];
    };

    struct VertexOut {
        float4 position [[position]];
        float4 color;
        float2 texture;
        float3 normal;
    };

    struct Uniforms {
        float4x4 mvp;
    };

    vertex VertexOut vertexShader(const device VertexIn* vertex_array [[ buffer(0) ]],
                                   constant Uniforms& uniforms [[ buffer(1) ]],
                                   uint vid [[ vertex_id ]]) {
        VertexIn in = vertex_array[vid];
        VertexOut out;
        out.position = uniforms.mvp * in.position;
        out.color = in.color;
        out.texture = in.texture;
        out.normal = in.normal;
        return out;
    }
    
//    struct FragmentIn {
//        float4 position [[position]];
//        float4 color;
//        float2 texture;
//        float3 normal;
//    };

    fragment float4 fragmentShader(const VertexOut in [[stage_in]],
                                    texture2d<float> texture [[ texture(0) ]],
                                    sampler textureSampler [[sampler(0)]]) {
        float4 surfaceColor = in.color * texture.sample(textureSampler, in.texture);
        return surfaceColor;
    }
}
