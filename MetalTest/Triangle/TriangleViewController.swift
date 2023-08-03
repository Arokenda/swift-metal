//
//  ViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/5/12.
//

import UIKit
import MetalKit

class TriangleViewController: BaseViewController {

    override func createRenderer(mtkView: MTKView) -> BaseRenderer? {
        if let renderer = TriangleRenderer(metalKitView: mtkView) {
            return renderer
        }
        return nil
    }
}

