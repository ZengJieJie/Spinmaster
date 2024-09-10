//
//  YoDazzleHomeViewController.swift
//  YoDazzleSlotMatrixNo
//
//  Created by adin on 2024/9/10.
//

import UIKit

class YoDazzleHomeViewController: UIViewController {

    @IBOutlet weak var lbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
        
        
    }
    
    

}
