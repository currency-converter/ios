//
//  WatchSessionUtil.swift
//  Watch Extension
//
//  Created by zhi.zhong on 2019/5/8.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import WatchKit
import WatchConnectivity

class WatchSessionUtil: NSObject,WCSessionDelegate {
	// 静态单例
	static let sharedManager = WatchSessionUtil()
	// 初始化
	private override init()
	{
		super.init()
	}
	// 连接机制
	private let session:WCSession? = WCSession.isSupported() ? WCSession.default : nil
	
	// 激活机制
	func startSession(){
		session?.delegate=self
		session?.activate()
	}
	
	// 检测到iPhone的父应用
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
	}
	
	// 接收到iPhone端发送过来的信息
	// message: iPhone端发送过来的信息
	// replyHandler: watch端回复给iPhone的内容
	func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
		// 这里也可以通过通知中心发送通知给InterfaceController，进行页面操作，至于用什么方法大家随意。注意事项iPhone的代码里提到了，一样的性质，这里就不写了。
		print("didReceiveMessage from iphone:", message)
	}
	
	// 向iPhone侧发送信息
	func sendMessage(key:String, value:Any){
		session?.sendMessage([key : value], replyHandler: { (reply: [String : Any]) in
			// 信息发送之后，收到iPhone端回复的操作
			print("Send to iphone successed")
			print("reply:", reply)
			NotificationCenter.default.post(name: .didWatchSendMessage, object: self, userInfo: reply)
		}, errorHandler: { (Error) in
			// 发送失败
			print("Send to iphone error")
		})
	}
}


