//
//  ShutterDetailViewController.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 09.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import UIKit

class ShutterDetailViewController: UIViewController {

    var testName: String = "Test"
    var wasTabBarHidden: Bool = false;
    
    @IBOutlet weak var testUILabel: UILabel!
    
    
    
    override func loadView() {
        super.loadView()
        
        guard let testUILabel = testUILabel else {
            return
        }
        
        testUILabel.text = testName
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        print("ShutterDetailViewController.viewDidLoad");
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide the tabbar
        wasTabBarHidden = (self.tabBarController?.tabBar.isHidden)!
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = wasTabBarHidden
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
