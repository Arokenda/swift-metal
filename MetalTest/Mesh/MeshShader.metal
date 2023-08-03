//
//  MeshShader.metal
//  MetalTest
//
//  Created by Arokenda on 2023/6/19.
//

#include <metal_stdlib>
#include "MeshShaderTypes.h"

using namespace metal;

namespace Mesh {
    typedef struct
    {
        float3 position [[attribute(0)]];
        float2 texCoord [[attribute(1)]];
        half3 normal    [[attribute(2)]];
        //half3 tangent   [[attribute(3)]];
        //half3 bitangent [[attribute(4)]];
    } Vertex;

    typedef struct
    {
        float4 position [[position]];
        float4 worldPos;
        float2 texCoord;
        float4 normal;
    } ColorInOut;
    
    float random1(float2 st)
    {
        return fract(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453);
    }
    
    float random2(float seed)
    {
        return fract(sin(seed) * 43758.5453);
    }

    vertex ColorInOut vertexShader(Vertex in [[ stage_in ]],
                                   constant MeshUniforms & uniforms [[ buffer(1) ]])
    {
        ColorInOut out;
        float4 position = float4(in.position, 1.0);
        out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
        out.worldPos = uniforms.modelMatrix * position;
        out.texCoord = in.texCoord;
        out.normal = normalize(uniforms.modelMatrix * float4((float3)in.normal, 0));
//        out.position = float4(random1(position.xy), random2(position.z), 0.0, 1.0);
        return out;
    }

    fragment half4 fragmentShader(ColorInOut in [[ stage_in ]],
                                  constant MeshUniforms & uniforms [[ buffer(1) ]],
                                  texture2d<half> baseColorMap [[ texture(0) ]],
                                  constant MeshFloat3Wrapper &color [[buffer(2)]])
    {
        constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
        
        half4 color_sample;
        if (baseColorMap.get_width() > 0 && baseColorMap.get_height() > 0) {
            color_sample = baseColorMap.sample(linearSampler,in.texCoord.xy);
        } else {
            half4 color_color = half4(half3(color.color.xyz), 1.0);
            if (color_color.x > 0 || color_color.y > 0 || color_color.z > 0) {
                color_sample = color_color;
            }
        }
        
        // 法线
        float3 N = in.normal.xyz;
        // 入射光方向
        float3 L = - normalize(uniforms.directionalLightDirection);
        // 视线方向
        float3 V = normalize(uniforms.cameraPos - in.worldPos.xyz);
        // 反射光方向
        float3 R = normalize(2 * fmax(dot(N, L), 0) * N - L);
        
        //环境光
        float ambient = uniforms.Ia * uniforms.Ka;
        
        // Lambert diffuse
        float diffuse = uniforms.IL * uniforms.Kd * max(dot(float3(in.normal.xyz),L),0.0);
        
        // Specular
        float specular = uniforms.IL * uniforms.Ks * pow(fmax(dot(V, R), 0), uniforms.shininess);
        
        // Phong Model
        float3 out = float3(uniforms.directionalLightColor) * float3(color_sample.xyz) * (diffuse + specular + ambient);
        
//        return half4(1.0,0.0,1.0,1.0);
        return half4(half3(out.xyz),1.0f);
//        return color_sample * uniforms.IL * uniforms.Kd;
    }
}
