//
//  SpinmasterSlotVCViewController.swift
//  Spinmasterslotstrek
//
//  Created by adin on 2024/9/5.
//

import UIKit

class SpinmasterSlotVCViewController: UIViewController {

    // UI Elements
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var coinLabel: UILabel! // Label to show coin count
    @IBOutlet weak var spinButton: UIButton!
    
    // Game Variables
    var imageNames: [String] = ["a", "b", "c", "d", "e", "f", "g" ,"i" ,"j","k"]
    var coins = 0 // Coin count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupGame() {
        statusLabel.text = "Press Spin to play!"
        coinLabel.text = "Coins: \(coins)"
    }
    
    @IBAction func spinButtonTapped(_ sender: UIButton) {
        spinImages()
    }
    
    func spinImages() {
        // Randomly select images for each imageView, allowing repeats
        for imageView in imageViews {
            let randomImageName = imageNames.randomElement()!
            imageView.image = UIImage(named: randomImageName)
            imageView.accessibilityIdentifier = randomImageName
        }
        
        // Randomly select 3 image views to animate
        let randomIndices = Array(0..<imageViews.count).shuffled().prefix(3)
        let selectedImageViews = randomIndices.map { imageViews[$0] }
        
        // Animate the selected image views with the same images
        animateImages(selectedImageViews: selectedImageViews) {
            self.checkWinCondition(selectedImageViews: selectedImageViews)
        }
    }
    
    func animateImages(selectedImageViews: [UIImageView], completion: @escaping () -> Void) {
        let animationDuration: TimeInterval = 1.0
        let delayBetweenAnimations: TimeInterval = 0.2
        
        for (index, imageView) in selectedImageViews.enumerated() {
            let animationType = AnimationType.random()

            UIView.transition(with: imageView, duration: animationDuration, options: [], animations: {
                // Apply different animation based on the type
                switch animationType {
                case .scale:
                    imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    UIView.animate(withDuration: animationDuration) {
                        imageView.transform = CGAffineTransform.identity
                    }
                }
            }, completion: { _ in
                // Delay for the next image transition
                if index == selectedImageViews.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenAnimations) {
                        completion()
                    }
                }
            })
        }
    }
    
    func checkWinCondition(selectedImageViews: [UIImageView]) {
        // Get the image names of the displayed images
        let displayedImages = selectedImageViews.compactMap { $0.accessibilityIdentifier }
        
        // Check how many images are the same
        let imageCounts = Dictionary(grouping: displayedImages, by: { $0 }).mapValues { $0.count }
        
        // Determine the highest count of any single image
        if let maxCount = imageCounts.values.max() {
            if maxCount == 3 {
                // All three images are the same
                coins += 50 // Add coins for three matching images
                statusLabel.text = "Jackpot! You Win 50 Coins! Total Coins: \(coins)"
            } else if maxCount == 2 {
                // Two images are the same
                coins += 10 // Add coins for two matching images
                statusLabel.text = "Two Match! You Win 10 Coins! Total Coins: \(coins)"
            } else {
                // No matches or all different
                statusLabel.text = "Try Again!"
            }
        }
        
        coinLabel.text = "Coins: \(coins)"
    }
    
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// Enum to define different animation types
enum AnimationType {
    case scale
    
    static func random() -> AnimationType {
        return [scale].randomElement()!
    }
}
