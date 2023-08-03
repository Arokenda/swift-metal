//
//  MeshViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/19.
//

import Foundation

import MetalKit

class MeshViewController: BaseViewController {
    
    override func createRenderer(mtkView: MTKView) -> BaseRenderer? {
        if let renderer = MeshRenderer(metalKitView: mtkView) {
            return renderer
        }
        return nil
    }
}
