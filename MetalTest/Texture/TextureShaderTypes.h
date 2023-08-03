//
//  TextureShaderTypes.h
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

#ifndef TextureShaderTypes_h
#define TextureShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef struct{
    vector_float2 pos;
    vector_float2 uv;
} TextureVextex;

#endif /* TextureShaderTypes_h */
