//
//  ShaderTypes.h
//  MetalTest
//
//  Created by Arokenda on 2023/5/15.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

//typedef struct
//{
//    vector_float4 pos;
//    vector_float4 color;
//} TriangleVertex;

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} TriangleUniforms;

#endif /* ShaderTypes_h */
