//
//  button.swift
//  按钮按下时添加背景高亮效果
//
//  Created by zhi.zhong on 2019/2/28.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

extension UIButton {
	func setBackgroundColor(color: UIColor, forState: UIControl.State) {
		self.clipsToBounds = true  // add this to maintain corner radius
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		if let context = UIGraphicsGetCurrentContext() {
			context.setFillColor(color.cgColor)
			context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
			let colorImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			self.setBackgroundImage(colorImage, for: forState)
		}
	}
}
