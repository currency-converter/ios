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
	
	// 枇杷黄 - 功能按钮正常背景颜色
	public static let loquatYellow = UIColor.hex("ff9408")
	
	// app 背景色
	public static let appBackgroundColor = UIColor.hex("121212")
	
	public static func rgba(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
		return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
	}
	public static func rgb(r:CGFloat, g:CGFloat, b:CGFloat) -> UIColor {
		return UIColor (red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
	}
	public static func hex(_ hex: String, alpha: CGFloat = 1) -> UIColor {
		var cstr = hex.trimmingCharacters(in:  CharacterSet.whitespacesAndNewlines).uppercased() as NSString;
		if(cstr.length < 6){
			return UIColor.clear;
		}
		if(cstr.hasPrefix("0X")){
			cstr = cstr.substring(from: 2) as NSString
		}
		if(cstr.hasPrefix("#")){
			cstr = cstr.substring(from: 1) as NSString
		}
		if(cstr.length != 6){
			return UIColor.clear;
		}
		var range = NSRange.init()
		range.location = 0
		range.length = 2
		//r
		let rStr = cstr.substring(with: range);
		//g
		range.location = 2;
		let gStr = cstr.substring(with: range)
		//b
		range.location = 4;
		let bStr = cstr.substring(with: range)
		var r :UInt32 = 0x0;
		var g :UInt32 = 0x0;
		var b :UInt32 = 0x0;
		Scanner.init(string: rStr).scanHexInt32(&r);
		Scanner.init(string: gStr).scanHexInt32(&g);
		Scanner.init(string: bStr).scanHexInt32(&b);
		return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha);
	}
}

extension Date {
	enum unit: String {
		case day
		case hour
		case minute
		case second
	}
	
	//返回秒数
	var timeStamp: Int {
		let timeInterval: TimeInterval = self.timeIntervalSince1970
		return Int(timeInterval)
	}
	
	func diff(timestamp: Int, unit: unit) -> Int {
		let now: Int = self.timeStamp
		let diffSecond: Int = now - timestamp
		switch unit {
		case .day:
			return Int(diffSecond/(24 * 3600))
		case .hour:
			return Int(diffSecond/3600)
		case .minute:
			return Int(diffSecond/60)
		default:
			return diffSecond
		}
	}
}

//自定义事件
extension Notification.Name {
	static let didUpdateRate = Notification.Name("didUpdateRate")
	static let didUserDefaultsChange = Notification.Name("didUserDefaultsChange")
}

//定义协议
protocol CallbackDelegate {
	func onReady(key: String, value: String)
}

//货币选择类型
enum CurrencyPickerType: String {
	case from
	case to
}

//汇率更新频率
enum RateUpdatedFrequency: String {
	case realtime = "0"
	case hourly = "1"
	case daily = "2"
}

