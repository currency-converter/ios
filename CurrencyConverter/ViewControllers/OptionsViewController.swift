//
//  OptionsViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController  {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// 导航条
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
//		navigationBar.barTintColor = UIColor.black
//		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
//		navigationBar.backgroundColor = UIColor.black
		self.view.addSubview(navigationBar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onOptionsDone(_:)))
		rightBtn.tintColor = UIColor.hex("f09a37")
		navigationitem.title = NSLocalizedString("done", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
	}
	
	func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func onOptionsDone(_ sender: UIButton) {
		self.close()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
