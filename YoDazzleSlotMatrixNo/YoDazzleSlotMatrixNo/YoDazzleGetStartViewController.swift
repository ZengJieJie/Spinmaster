//
//  YoDazzleGetStartViewController.swift
//  YoDazzleSlotMatrixNo
//
//  Created by adin on 2024/9/10.
//

import UIKit

class YoDazzleGetStartViewController: UIViewController {

    @IBOutlet weak var imgLogo: UIImageView!
    
    override func viewDidLoad() {
          super.viewDidLoad()
          
          animateLogoAndNavigate()
      }
      
      private func animateLogoAndNavigate() {
          
          imgLogo.transform = CGAffineTransform(scaleX: 1, y: 1)
          imgLogo.alpha = 1.0
          
          UIView.animate(withDuration: 3.0, animations: {
              
              self.imgLogo.alpha = 0.3
              
              self.imgLogo.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
              
          }) { _ in
              
              self.goToNextScreen()
          }
      }
      
      private func goToNextScreen() {
          
          self.performSegue(withIdentifier: "toHome", sender: self)
          
      }
}
