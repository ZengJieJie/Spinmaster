//
//  Vc + Back.swift
//  Madness Slot Vaganza
//
//  Created by Madness Slot Vaganza  on 13/09/24.
//

import Foundation
import UIKit

extension UIViewController{
    
    @IBAction func btnBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
}
