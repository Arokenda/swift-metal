//
//  ObjModelViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/7/24.
//

import Foundation
import MetalKit

class ObjModelViewController: BaseViewController {
    
    override func createRenderer(mtkView: MTKView) -> BaseRenderer? {
        if let renderer = ObjModelRenderer(metalKitView: mtkView) {
            return renderer
        }
        return nil
    }
}
