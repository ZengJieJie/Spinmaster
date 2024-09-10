//
//  YoDazzleViewWallpController.swift
//  YoDazzleSlotMatrixNo
//
//  Created by adin on 2024/9/10.
//

import UIKit

class YoDazzleViewWallpController: UIViewController {

    @IBOutlet weak var viewWallp: UIView!
    
    @IBOutlet weak var swtchMultiColor: UISwitch!
    
    @IBOutlet weak var swtchMultiIcons: UISwitch!
    
    @IBOutlet weak var swtchIsDark: UISwitch!
    
    var arrSymbols: [String] = [
        
        "♧",
        "♤",
        "♡",
        "♢",
        "♥︎",
        "❤︎",
        "♦︎",
        "♣︎",
        "♠︎",
        "♦️",
        "♣️",
        "♥️",
        "♠️",
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    @IBAction func btnGenerate(_ sender: Any) {
        
        viewWallp.subviews.forEach { $0.removeFromSuperview() }
        
        generateRandomLabels()
    }
    
    private func generateRandomLabels() {
        
        let numberOfLabels = 200
        let labelSize: CGFloat = viewWallp.bounds.height / 10
        
        let symbolsToUse = swtchMultiIcons.isOn ? arrSymbols : [arrSymbols.randomElement() ?? ""]
        
        let columns = 20
        
        let spacingX: CGFloat = 10
        let spacingY: CGFloat = 10
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        
        addNeonBackground(multicolor: swtchMultiColor.isOn)
        
        for i in 0..<numberOfLabels {
            
            let label = UILabel()
            label.alpha = 0.7
            label.text = symbolsToUse.randomElement()
            
            label.font = UIFont.systemFont(ofSize: 30)
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            label.textColor = swtchIsDark.isOn ? .white : .black
            
            label.frame = CGRect(x: currentX, y: currentY, width: labelSize, height: labelSize)
            
            viewWallp.addSubview(label)
            
            currentX += labelSize + spacingX
            
            if (i + 1) % columns == 0 {
                currentX = 0
                currentY += labelSize + spacingY
            }
        }
    }
    
    private func addNeonBackground(multicolor: Bool) {
        let numberOfLines = 10
        let lineWidth: CGFloat = 5
        let viewWidth = viewWallp.bounds.width
        let viewHeight = viewWallp.bounds.height
        
        for _ in 0..<numberOfLines {
            let neonColor = multicolor ? getRandomColor() : UIColor.cyan
            
            let neonLine = UIView()
            neonLine.backgroundColor = neonColor
            neonLine.frame = CGRect(x: 0, y: CGFloat.random(in: 0..<viewHeight), width: viewWidth, height: lineWidth)
            
            neonLine.layer.shadowColor = neonColor.cgColor
            neonLine.layer.shadowRadius = 10
            neonLine.layer.shadowOpacity = 1.0
            neonLine.layer.shadowOffset = CGSize.zero
            
            viewWallp.insertSubview(neonLine, at: 0)
        }
        
        for _ in 0..<numberOfLines {
            let neonColor = multicolor ? getRandomColor() : UIColor.cyan
            
            let neonLine = UIView()
            neonLine.backgroundColor = neonColor
            neonLine.frame = CGRect(x: CGFloat.random(in: 0..<viewWidth), y: 0, width: lineWidth, height: viewHeight)
            
            neonLine.layer.shadowColor = neonColor.cgColor
            neonLine.layer.shadowRadius = 10
            neonLine.layer.shadowOpacity = 1.0
            neonLine.layer.shadowOffset = CGSize.zero
            
            viewWallp.insertSubview(neonLine, at: 0)
        }
    }
    
    
    private func getRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    
    private func updateBackgroundForDarkMode() {
        viewWallp.backgroundColor = swtchIsDark.isOn ? UIColor.black : UIColor.white
    }
    
    
    @IBAction func swtchIsDarkToggled(_ sender: UISwitch) {
        updateBackgroundForDarkMode()
    }
    
    
    @IBAction func btnShare(_ sender: Any) {
        
        guard let img = viewWallp.toImage() else{
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        
        guard let capturedImage = viewWallp.toImage() else{
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(capturedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully!")
        }
    }
    
    @IBAction func btnCustom(_ sender: Any) {
     
//        showAlertWithTextInput { str in
//
//            guard let lettr = str?.first else{
//                return
//            }
//
//        }
        
        
        navigationController?.popViewController(animated: true)
          
        
    }
        //MARK: Alert With Text Input
        
        func showAlertWithTextInput(completion: @escaping (String?) -> Void) {
            let alertController = UIAlertController(title: "Enter Text", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.placeholder = "Enter text"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(nil)
            }
            
            let okayAction = UIAlertAction(title: "Okay", style: .default) { _ in
                let textField = alertController.textFields?.first
                let enteredText = textField?.text
                completion(enteredText)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okayAction)
            
            // Present the alert controller
            // Replace `viewController` with the appropriate view controller to present the alert from
            self.present(alertController, animated: true, completion: nil)
        }

}
