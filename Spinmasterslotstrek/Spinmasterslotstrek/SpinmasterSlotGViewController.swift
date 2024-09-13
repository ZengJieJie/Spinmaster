//
//  SpinmasterSlotGViewController.swift
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

import UIKit
import AVFoundation
class SpinmasterSlotGViewController: UIViewController {

    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!
    @IBOutlet weak var autoplayButton: UIButton!
    @IBOutlet weak var betIncreaseButton: UIButton!
    @IBOutlet weak var betDecreaseButton: UIButton!
    
    // Outlets for the 3x5 grid of UIImageViews (slot reels)
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var imageView7: UIImageView!
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var imageView9: UIImageView!
    @IBOutlet weak var imageView10: UIImageView!
    
    @IBOutlet weak var imageView11: UIImageView!
    @IBOutlet weak var imageView12: UIImageView!
    @IBOutlet weak var imageView13: UIImageView!
    @IBOutlet weak var imageView14: UIImageView!
    @IBOutlet weak var imageView15: UIImageView!
    
    var slotImages = ["1", "2", "3", "4", "5", "6", "7"]
    var coins = 1000
    var bet = 10
    var isAutoplayActive = false
    var autoplayTimer: Timer?
    var audioPlayer: AVAudioPlayer?
    
    // Array to hold UIImageView outlets for easier access
    var slotImageViews: [UIImageView] = []
    
    // Winning patterns for the 3x5 grid
    let winningPatterns: [[Int]] = [
        [0, 1, 2, 3, 4],    // Top row
        [5, 6, 7, 8, 9],    // Middle row
        [10, 11, 12, 13, 14], // Bottom row
        [0, 6, 12, 8, 4],   // Diagonal left to right
        [10, 6, 2, 8, 14]   // Diagonal right to left
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize slotImageViews with all UIImageView outlets
        slotImageViews = [
            imageView1, imageView2, imageView3, imageView4, imageView5,
            imageView6, imageView7, imageView8, imageView9, imageView10,
            imageView11, imageView12, imageView13, imageView14, imageView15
        ]
        
        // Set initial button title to "Autoplay"
        let font = UIFont(name: "Times New Roman", size: 13) ?? UIFont.systemFont(ofSize: 17)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        let attributedTitle = NSAttributedString(string: "AutoPlay", attributes: attributes)
        autoplayButton.setAttributedTitle(attributedTitle, for: .normal)
        
        updateUI()
        loadSpinSound()
    }
    
    func updateUI() {
        coinLabel.text = "Coins: \(coins)"
        betLabel.text = "Bet: \(bet)"
    }
    
    // Load the sound for the spin action
    func loadSpinSound() {
        if let soundURL = Bundle.main.url(forResource: "spin", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error loading spin sound: \(error)")
            }
        }
    }
    
    // Play the spin sound
    func playSpinSound() {
        audioPlayer?.play()
    }
    
    @IBAction func spinButtonTapped(_ sender: UIButton) {
        if coins >= bet {
            coins -= bet
            updateUI()
            animateSlotReels()  // Start slot animation only when button is tapped
            playSpinSound()     // Play slot spin sound
        } else {
            showNoCoinsAlert()
        }
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func autoplayButtonTapped(_ sender: UIButton) {
        isAutoplayActive.toggle()
        
        let font = UIFont(name: "Times New Roman", size: 13) ?? UIFont.systemFont(ofSize: 17)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        if isAutoplayActive {
            let attributedTitle = NSAttributedString(string: "Stop", attributes: attributes)
            autoplayButton.setAttributedTitle(attributedTitle, for: .normal)
            
            autoplayTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(spinReels), userInfo: nil, repeats: true)
        } else {
            let attributedTitle = NSAttributedString(string: "AutoPlay", attributes: attributes)
            autoplayButton.setAttributedTitle(attributedTitle, for: .normal)
            
            autoplayTimer?.invalidate()
        }
    }
    @IBAction func betIncreaseTapped(_ sender: UIButton) {
        bet += 10
        updateUI()
    }
    
    @IBAction func betDecreaseTapped(_ sender: UIButton) {
        if bet > 10 {
            bet -= 10
            updateUI()
        }
    }
    
    @objc func spinReels() {
        if coins >= bet {
            coins -= bet
            updateUI()
            playSpinSound() // Play the spin sound
            animateSlotReels() // Start animation
        } else {
            let alert = UIAlertController(title: "Not enough coins!", message: "You need more coins to play.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func animateSlotReels() {
        let animationDuration: TimeInterval = 1.5  // Duration of each spin animation
        let columnAnimationDelay: TimeInterval = 0.3  // Delay between each column's stop

        for (index, imageView) in slotImageViews.enumerated() {
            let randomImageName = slotImages.randomElement() ?? "1"  // Assign a default symbol if there's an issue
            let randomImage = UIImage(named: randomImageName)

            // Set the accessibilityIdentifier to track which symbol is displayed
            imageView.image = randomImage
            imageView.accessibilityIdentifier = randomImageName
            
            // Randomize animation types for each row/column
            let animationType: UIView.AnimationOptions = {
                switch index % 5 {
                case 0: return .transitionFlipFromLeft
                case 1: return .transitionFlipFromRight
                case 2: return .transitionCurlUp
                case 3: return .transitionCurlDown
                default: return .transitionFlipFromTop
                }
            }()

            // Spin animation with staggered timing for each column to simulate real slot machines
            DispatchQueue.main.asyncAfter(deadline: .now() + (columnAnimationDelay * Double(index % 5))) {
                UIView.transition(with: imageView, duration: 0.2, options: animationType, animations: {
                    imageView.image = randomImage
                }, completion: nil)
            }
        }

        // Simulate spin completion with a slight delay after the entire spin animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + columnAnimationDelay * 5) {
            self.finalizeSpin()
        }
    }

    func finalizeSpin() {
        var slotSymbols: [String] = []
        
        // Collect the final symbols shown in each slot reel
        for imageView in slotImageViews {
            if let imageName = imageView.accessibilityIdentifier {
                slotSymbols.append(imageName)
            } else {
                // If any image is missing an identifier, fallback to a safe default
                slotSymbols.append("1")  // Use a default symbol to avoid nil
            }
        }
        
        // Ensure we have the correct number of slot symbols (should be 15)
        if slotSymbols.count == 15 {
            let isWinning = checkForWinningCombination(slotSymbols: slotSymbols)
            
            if isWinning {
                coins += bet * 10 // Reward coins
                updateUI()
                showWinningAlert()
            } else {
                updateUI() // No win, just update UI normally
            }
        } else {
            print("Error: Slot symbols count mismatch")
        }
    }


    
    // MARK: - Check for Winning Combination
    func checkForWinningCombination(slotSymbols: [String]) -> Bool {
        for pattern in winningPatterns {
            let firstSymbol = slotSymbols[pattern[0]]
            
            var isWinning = true
            for index in pattern {
                if slotSymbols[index] != firstSymbol {
                    isWinning = false
                    break
                }
            }
            
            if isWinning {
                return true // A winning pattern was found
            }
        }
        
        return false // No winning pattern found
    }
    
    // MARK: - Show Winning Alert
    func showWinningAlert() {
        let alert = UIAlertController(title: "You Win!", message: "Congratulations! You won the game!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showNoCoinsAlert() {
        let alert = UIAlertController(title: "Not enough coins!", message: "You don't have enough coins to continue. Please try again later or reset the game.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
