//
//  View + ToImg.swift
//  Big Dazzle Slot Matrix
//
//  Created by SSS Big Dazzle Slot Matrix on 06/09/24.
//

import Foundation
import UIKit

extension UIView {
    
    func toImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        guard let pngData = image.pngData() else { return nil }
        
        return UIImage(data: pngData)
    }
}
