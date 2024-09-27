//
//  SlotGameVC.swift
//  Madness Slot Vaganza
//
//  Created by Madness Slot Vaganza  on 13/09/24.
//

import UIKit
import AudioToolbox

class YonoMadnessSlotGameVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickrSlot: UIPickerView!
    @IBOutlet weak var lblScore: UILabel!
    @IBOutlet weak var btnSpin: UIButton!
    @IBOutlet weak var lblToken: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var loadingView: UIView!
    
    var slotSymbols = ["🇦", "𝟟", "ₖ", "⋈", "ԋ", "➶", "♢"]
    
    var score: Int = 0
    var spinTokens: Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        YonoMadnessshowLoadingAnimation()
        
        pickrSlot.delegate = self
        pickrSlot.dataSource = self
        
        imgLogo.alpha = 1.0
        
    }
    
    func YonoMadnessshowLoadingAnimation() {
        
        loadingView = UIView(frame: self.view.bounds)
        loadingView.backgroundColor = UIColor.black
        
        let loadingLabel = UILabel()
        
        loadingLabel.text = "Loading..."
        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textAlignment = .center
        
        loadingView.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            
            loadingLabel.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
            
        ])
        
        self.view.addSubview(loadingView)
        
        loadingView.alpha = 0.5
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.loadingView.alpha = 1.0
            
        }) { _ in
            
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                
                self.loadingView.alpha = 0.0
                
            }) { _ in
                
                self.loadingView.removeFromSuperview()
                self.startYonoMadnessGame()
                
            }
            
        }
    }
    
    func startYonoMadnessGame() {
        
        pickrSlot.isHidden = false
        lblScore.isHidden = false
        btnSpin.isHidden = false
        lblToken.isHidden = false
        lblResult.isHidden = false
        
        uYonoMadnesspdateUI()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 3
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return slotSymbols.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.frame.size = CGSize(width: 60, height: 60)
        label.text = slotSymbols[row]
        label.textAlignment = .center
        label.textColor = .lbl1
        label.font = UIFont.systemFont(ofSize: 60)
        
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70
    }
    
    @IBAction func YonoMadnessspinButtonTapped(_ sender: UIButton) {
        
        if spinTokens > 0 {
            
            spinTokens -= 1
            
            startYonoMadnessLogoBlinkingAnimation()
            
            for i in 0..<3 {
                
                let randomIndex = Int.random(in: 0..<slotSymbols.count)
                
                pickrSlot.selectRow(randomIndex, inComponent: i, animated: true)
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                self.checkYonoMadnessForMatches()
                self.stYonoMadnessopLogoBlinkingAnimation()
                self.uYonoMadnesspdateUI()
                
            }
            
        } else {
            
            lblResult.text = "No Spins Left"
            
        }
        
        uYonoMadnesspdateUI()
    }
    
    func startYonoMadnessLogoBlinkingAnimation() {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            
            self.imgLogo.alpha = 0.0
            
        }, completion: nil)
        
    }
    
    func stYonoMadnessopLogoBlinkingAnimation() {
        
        imgLogo.layer.removeAllAnimations()
        imgLogo.alpha = 1.0
        
    }
    
    func checkYonoMadnessForMatches() {
        
        let symbol1 = slotSymbols[pickrSlot.selectedRow(inComponent: 0)]
        
        let symbol2 = slotSymbols[pickrSlot.selectedRow(inComponent: 1)]
        
        let symbol3 = slotSymbols[pickrSlot.selectedRow(inComponent: 2)]
        
        if symbol1 == symbol2 && symbol2 == symbol3 {
            
            score += 50
            lblResult.text = "Jackpot! You matched all three!"
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        } else if symbol1 == symbol2 || symbol2 == symbol3 || symbol1 == symbol3 {
            
            score += 20
            lblResult.text = "Nice! You matched two symbols!"
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        } else {
            
            score -= 10
            lblResult.text = "Try Again! No match."
            
        }
    }
    
    func uYonoMadnesspdateUI() {
        
        lblScore.text = "Score: \(score)"
        lblToken.text = "Spin Tokens: \(spinTokens)"
        
    }
    
}

