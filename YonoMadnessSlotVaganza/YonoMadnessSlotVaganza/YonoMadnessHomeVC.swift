//
//  HomeVC.swift
//  Madness Slot Vaganza
//
//  Created by Madness Slot Vaganza  on 13/09/24.
//

import UIKit
import StoreKit

class YonoMadnessHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    @IBAction func YonoMadnessbtnRate(_ sender: Any) {
        
        SKStoreReviewController.requestReview()
        
    }
    
    
}
