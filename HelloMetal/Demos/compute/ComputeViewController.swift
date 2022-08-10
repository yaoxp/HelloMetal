//
//  ComputeViewController.swift
//  HelloMetal
//
//  Created by yaoxp on 2022/8/10.
//

import UIKit

class ComputeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onComputeAction(_ sender: Any) {
        logger.debug("on compute button.")
        guard let metalDevice = MTLCreateSystemDefaultDevice() else {
            logger.error("not support Metal.")
            return
        }
        guard let metalAdder = ComputeAdder(with: metalDevice) else { return }
        DispatchQueue.global().async {
            metalAdder.testCPUCompute()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            metalAdder.testGPUCompute()
        }
    }
    

}
