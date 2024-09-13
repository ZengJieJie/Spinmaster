//
//  SpinmasterStartViewController.swift
//  Spinmasterslotstrek
//
//  Created by jin fu on 2024/9/13.
//

import UIKit

class SpinmasterStartViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.activityView.hidesWhenStopped = true
        
        self.spmLoadADsData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.orientation.isLandscape {
                self.stackView.axis = .horizontal
                print("Landscape layout")
            } else if UIDevice.current.orientation.isPortrait {
                self.stackView.axis = .vertical
                print("Portrait layout")
            }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            if self.traitCollection.verticalSizeClass == .compact {
                self.stackView.axis = .horizontal
                print("Landscape layout")
            } else {
                self.stackView.axis = .vertical
                print("Portrait layout")
            }
        }, completion: nil)
    }
    
    private func spmLoadADsData() {
        if UIDevice.current.model.contains("iPad") {
            return
        }
                
        self.activityView.startAnimating()
        if SpinmasterNetReachManager.shared().isReachable {
            spmGetRequestLocalAdsData()
        } else {
            SpinmasterNetReachManager.shared().setReachabilityStatusChange { status in
                if SpinmasterNetReachManager.shared().isReachable {
                    self.spmGetRequestLocalAdsData()
                    SpinmasterNetReachManager.shared().stopMonitoring()
                }
            }
            SpinmasterNetReachManager.shared().startMonitoring()
        }
    }
    
    private func spmGetRequestLocalAdsData() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            self.activityView.stopAnimating()
            return
        }
        
        
        let url = URL(string: "https://open.cleverspot.top/open/spmGetADS")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "appKey": "1235fd532140437cb26f915a98d59603",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            self.activityView.stopAnimating()
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    self.activityView.stopAnimating()
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary, let adsData = dataDic["jsonObject"] {
                            UserDefaults.standard.setValue(adsData, forKey: "spmADSList")
                            self.spmShowAdViewC()
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    self.activityView.stopAnimating()
                } catch {
                    print("Failed to parse JSON:", error)
                    self.activityView.stopAnimating()
                }
            }
        }

        task.resume()
    }
}
