//
//  Vc + Audio.swift
//  Madness Slot Vaganza
//
//  Created by Madness Slot Vaganza  on 12/09/24.
//

import Foundation
import AVFoundation
import UIKit

extension UIViewController{
    
    static var audioPlayer: AVAudioPlayer?
    
    func playSound(name : String, type: String) {
        
        if let path = Bundle.main.path(forResource: name, ofType: type) {
            let url = URL(fileURLWithPath: path)
            
            do {
                UIViewController.audioPlayer = try AVAudioPlayer(contentsOf: url)
                UIViewController.audioPlayer?.play()
            } catch {
                print("Couldn't load file")
            }
        }
    }
    
}
