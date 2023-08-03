//
//  MeshShaderTypes.h
//  MetalTest
//
//  Created by Arokenda on 2023/6/20.
//

#ifndef MeshShaderTypes_h
#define MeshShaderTypes_h
#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    
    vector_float3 directionalLightDirection;
    vector_float3 directionalLightColor;
    
    float IL;   //光源强度
    float Kd;   //漫反射系数
    float Ks; // 镜面反射系数
    float shininess; // 镜面反射高光指数
    float Ia;   //环境光强度
    float Ka;   //环境光系数
    
    vector_float3 cameraPos; // 相机世界坐标
} MeshUniforms;

typedef struct{
    vector_float3 color;
} MeshFloat3Wrapper;

#endif /* MeshShaderTypes_h */
