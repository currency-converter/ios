//
//  STC.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/11.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class STC: UITableViewController {
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		print("====")
		self.navigationItem.title = NSLocalizedString("settings", comment: "")

        // Do any additional setup after loading the view.
		
//		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onDone(_:)))
//		rightBtn.tintColor = UIColor.hex("f09a37")
//		navItem.title = NSLocalizedString("settings", comment: "")
//		navItem.rightBarButtonItem = rightBtn
    }
	
	@IBAction func onDone(_ sender: Any) {
		//self.dismiss(animated: true, completion: nil)
		//self.presentingViewController!.dismiss(animated: true, completion: nil)
		
		self.dismiss(animated: false, completion: nil)
		//self.prepare(for: "showSettingsSegue", sender: nil)
	}
	//	@objc func onDone(_ sender: UIButton) {
//		self.dismiss(animated: true, completion: nil)
//	}
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
