//
//  Util.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/8.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

//func normalRGBA (r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
//	return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
//}

extension UIColor {
	public static func rgba(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
		return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
	}
}
