//
//  MainViewController.swift
//  MetalTest
//
//  Created by Arokenda on 2023/5/17.
//

import Foundation
import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView:UITableView!
    
    var vcList: [AnyClass] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vcList.append(TriangleViewController.self)
        vcList.append(TextureViewController.self)
        vcList.append(MeshViewController.self)
        vcList.append(ObjModelViewController.self)
    }
    
    //delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //来自青春不老哥教导
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") else {return UITableViewCell () }
        cell.textLabel?.text="第\(indexPath.row):\(type (of:vcList[indexPath.row]))"
        
        //摒弃OC风代码
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier");
//        cell?.textLabel?.text = "第" + String(indexPath.row) + ":" + String(describing: type(of: vcList[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cls: AnyClass = vcList[indexPath.row]
        var vc = cls.alloc() as? UIViewController
        vc = type(of: vc ?? UIViewController()).init()
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
        
    }
}
