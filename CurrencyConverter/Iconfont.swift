//
//  Iconfont.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/2.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

extension UIImage {
	
	public static func iconFont(fontSize: CGFloat, unicode: String, color: UIColor? = nil) -> UIImage {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[NSAttributedString.Key.font] = UIFont(name: "CurrencyConverter", size: fontSize)
		if let color = color {
			attributes[NSAttributedString.Key.foregroundColor] = color
		}
		let attributedString = NSAttributedString(string: unicode, attributes: attributes)
		
		let rect = attributedString.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: fontSize), options: .usesLineFragmentOrigin, context: nil)
		
		let imageSize: CGSize = rect.size
		UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
		
		attributedString.draw(in: rect)
		
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return image
	}
}
