//
//  TextureViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

import UIKit
import MetalKit

class TextureViewController: BaseViewController {
    
    override func createRenderer(mtkView: MTKView) -> BaseRenderer? {
        if let renderer = TextureRenderer(metalKitView: mtkView) {
            return renderer
        }
        return nil
    }
}
