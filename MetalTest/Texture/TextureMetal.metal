//
//  TextureMetal.metal
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

#include <metal_stdlib>
#include "TextureShaderTypes.h"

using namespace metal;

namespace Texture {
    typedef struct
    {
        float4 position [[position]];
        float2 texCoord;
    } ColorInOut;
    
    
    vertex ColorInOut vertexShader(uint vid [[vertex_id]],
                                   constant TextureVextex *vertexArr [[buffer(0)]])
    {
        ColorInOut out;
        out.position = vector_float4(vertexArr[vid].pos, 0, 1.0);
        out.texCoord = vertexArr[vid].uv;
        return out;
    }
    
    fragment half4 fragmentShader(ColorInOut in [[stage_in]], texture2d<half> mtlTexture01 [[texture(0)]])
    {
        constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
        const half4 color = mtlTexture01.sample(textureSampler, in.texCoord);
        return color;
    }
}
