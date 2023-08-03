//
//  BaseViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/6/15.
//

import UIKit
import MetalKit

class BaseViewController : UIViewController {
    var renderer : BaseRenderer?
    
    override func loadView() {
        view = MTKView()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        guard let mtkView = view as? MTKView else {
            print("View is not an MTKView")
            return
        }
        
        // Do any additional setup after loading the view.
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }
        mtkView.device = device;

        renderer = createRenderer(mtkView: mtkView)
        if renderer == nil {
            fatalError("Renderer initialization failed")
        }
        
        renderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
    }
    
    func createRenderer(mtkView:MTKView) -> BaseRenderer? {
        guard let renderer = BaseRenderer(metalKitView: mtkView) else { return nil }
        return renderer
    }
}
