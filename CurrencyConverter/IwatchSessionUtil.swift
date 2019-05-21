//
//  IwatchSessionUtil.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/5/8.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit
import WatchConnectivity

class IwatchSessionUtil: NSObject, WCSessionDelegate {
	//静态单例
	static let shareManager = IwatchSessionUtil()
	//初始化
	private override init()
	{
		super.init()
	}
	// 连接机制
	private let session:WCSession? = WCSession.isSupported() ? WCSession.default : nil
	// 激活机制对象
	func startSession(){
		session?.delegate = self
		session?.activate()
	}
	
	// 检测到watch端app
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("AppleWatch匹配完成")
	}
	
	// 开始向Watch传递数据
	func sessionDidBecomeInactive(_ session: WCSession) {
	}
	
	// 数据传递完了
	func sessionDidDeactivate(_ session: WCSession) {
	}
	
	// watch侧发送数据过来，iPhone接收到数据并回复数据过去
	// message: watch侧发送过来的信息
	// replyHandler: iPhone回复过去的信息
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		print("didReceiveMessage from watch:", message)
		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: Config.groupId)
		var fromSymbol: String = shared?.string(forKey: "fromSymbol") ?? Config.defaults["fromSymbol"] as! String
		if message["fromSymbol"] != nil {
			fromSymbol = message["fromSymbol"] as! String
			shared?.set(fromSymbol, forKey: "fromSymbol")
			NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
				"fromSymbol": fromSymbol,
				"changeType": "pick"
			])
		}
		
		var toSymbol: String = shared?.string(forKey: "toSymbol") ?? Config.defaults["toSymbol"] as! String
		if message["toSymbol"] != nil {
			toSymbol = message["toSymbol"] as! String
			shared?.set(toSymbol, forKey: "toSymbol")
			NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
				"toSymbol": toSymbol,
				"changeType": "pick"
			])
		}
		
		let rates: [String: [String: NSNumber]] = shared?.object(forKey: "rates") as? [String: [String: NSNumber]] ?? Config.defaults["toSymbol"] as! [String: [String: NSNumber]]
		let fromRate: Float! = Float(truncating: (rates[fromSymbol]! as [String: NSNumber])["a"]!)
		let toRate: Float! = Float(truncating: (rates[toSymbol]! as [String: NSNumber])["a"]!)
		let rate: Float = toRate/fromRate
		let favorites: [String] = shared?.array(forKey: "favorites") as? [String] ?? Config.defaults["favorites"] as! [String]
		
		replyHandler([
			"fromSymbol": fromSymbol,
			"toSymbol": toSymbol,
			"rate": rate,
			"favorites": favorites
		])
		// 在这里，我们接收到watch发送过来的数据，可以用代理、代码块或者通知中心传值到ViewController，做出一系列操作。
		// 注！！：watch侧发送过来信息，iPhone回复直接在这个函数里回复replyHandler([String : Any])（replyHandler(数据)），这样watch侧发送数据的函数对应的reply才能接收到数据，别跟sendMessage这个函数混淆了。如果用sendMessage回复，那watch侧接收到信息就是didReceiveMessage的函数。
	}
	
	// iPhone向watch发送数据
	// key: 数据的key值
	// value: 数据内容
	func sendMessageToWatch(key:String, value:Any) {
		session?.sendMessage([key : value], replyHandler: { (dict:Dictionary) in
			// 这里是发送数据后的操作，比如写个alert提示发送成功
			// replyHandler是watch侧didReceiveMessage函数接收到信息后reply回复过来的内容，这里可以编辑自己需要的功能
			print("Send OK.")
		}, errorHandler: { (Error) in
			// 发送失败，一般是蓝牙没开，或手机开了飞行模式
		})
	}
}


