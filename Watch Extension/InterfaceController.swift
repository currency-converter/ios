//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by zhi.zhong on 2019/5/7.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
	
	var isEmpty: Bool = true
	
	// 输入货币数量
	var fromMoney: String = "0"
	
	// 汇率
	var rate: Float = 6.777
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	@IBOutlet var group1: WKInterfaceGroup!
	@IBOutlet var group2: WKInterfaceGroup!
	@IBOutlet var group3: WKInterfaceGroup!
	@IBOutlet var group4: WKInterfaceGroup!
	@IBOutlet var group5: WKInterfaceGroup!
	@IBOutlet var fromFlagImage: WKInterfaceImage!
	@IBOutlet var fromMoneyLabel: WKInterfaceLabel!
	@IBOutlet var fromSymbolLabel: WKInterfaceLabel!
	@IBOutlet var toFlagImage: WKInterfaceImage!
	@IBOutlet var toMoneyLabel: WKInterfaceLabel!
	@IBOutlet var toSymbolLabel: WKInterfaceLabel!
	@IBOutlet var button7: WKInterfaceButton!
	@IBOutlet var button8: WKInterfaceButton!
	@IBOutlet var button9: WKInterfaceButton!
	@IBOutlet var button0: WKInterfaceButton!
	@IBOutlet var button4: WKInterfaceButton!
	@IBOutlet var button5: WKInterfaceButton!
	@IBOutlet var button6: WKInterfaceButton!
	@IBOutlet var buttonDot: WKInterfaceButton!
	@IBOutlet var button1: WKInterfaceButton!
	@IBOutlet var button2: WKInterfaceButton!
	@IBOutlet var button3: WKInterfaceButton!
	@IBOutlet var buttonAC: WKInterfaceButton!
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		// Configure interface objects here.
		initConfig()
		render()
		observe()
		WatchSessionUtil.sharedManager.sendMessage(key: "initConfig", value: "")
    }
	
	func initConfig() {
		let shared = UserDefaults(suiteName: Config.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol") ?? Config.defaults["fromSymbol"] as! String
		self.toSymbol = shared?.string(forKey: "toSymbol") ?? Config.defaults["toSymbol"] as! String
		self.rate = shared?.float(forKey: "rate") ?? 6.7
	}
	
	func render() {
//		if let path = Bundle.main.path(forResource: fromSymbol, ofType: "png") {
//			print("find path")
//			fromFlagImage.setImage(UIImage(contentsOfFile: path))
//		}
//		if let path = Bundle.main.path(forResource: toSymbol, ofType: "png") {
//			toFlagImage.setImage(UIImage(contentsOfFile: path))
//		}
//
//		fromMoneyLabel.setText(numberFormat(fromMoney))
//		toMoneyLabel.setText(output(fromMoney))
//
//		fromSymbolLabel.setText(fromSymbol)
//		toSymbolLabel.setText(toSymbol)
		
		let buttonColumns: CGFloat = 4
		let buttonRows: CGFloat = 3
		let buttonWidth: CGFloat = (self.contentFrame.width - 4 * (buttonColumns - 1))/buttonColumns
		let buttonHeight: CGFloat = (self.contentFrame.height - 8 * (buttonRows - 1))/(buttonRows + 2)
		
		group1.setHeight(buttonHeight)
		group2.setHeight(buttonHeight)
		group3.setHeight(buttonHeight)
		group4.setHeight(buttonHeight)
		group5.setHeight(buttonHeight)
		
		button7.setWidth(buttonWidth)
		button8.setWidth(buttonWidth)
		button9.setWidth(buttonWidth)
		button0.setWidth(buttonWidth)
		
		button7.setHeight(buttonHeight)
		button8.setHeight(buttonHeight)
		button9.setHeight(buttonHeight)
		button0.setHeight(buttonHeight)
		
		button4.setWidth(buttonWidth)
		button5.setWidth(buttonWidth)
		button6.setWidth(buttonWidth)
		buttonDot.setWidth(buttonWidth)
		
		button4.setHeight(buttonHeight)
		button5.setHeight(buttonHeight)
		button6.setHeight(buttonHeight)
		buttonDot.setHeight(buttonHeight)
		
		button1.setWidth(buttonWidth)
		button2.setWidth(buttonWidth)
		button3.setWidth(buttonWidth)
		buttonAC.setWidth(buttonWidth)
		
		button1.setHeight(buttonHeight)
		button2.setHeight(buttonHeight)
		button3.setHeight(buttonHeight)
		buttonAC.setHeight(buttonHeight)
		buttonAC.setBackgroundColor(UIColor.loquatYellow)
		
		print("x:",self.contentFrame.origin.x)
		print("y:",self.contentFrame.origin.y)
		print("width:",self.contentFrame.width)
		print("height:",self.contentFrame.height)
		
		self.refresh()
	}
	
	func refresh() {
		if let path = Bundle.main.path(forResource: fromSymbol, ofType: "png") {
			print("find path")
			fromFlagImage.setImage(UIImage(contentsOfFile: path))
		}
		if let path = Bundle.main.path(forResource: toSymbol, ofType: "png") {
			toFlagImage.setImage(UIImage(contentsOfFile: path))
		}
		
		fromMoneyLabel.setText(numberFormat(fromMoney))
		toMoneyLabel.setText(output(fromMoney))
		
		fromSymbolLabel.setText(fromSymbol)
		toSymbolLabel.setText(toSymbol)
	}
	
	func observe() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidWatchSendMessage), name: .didWatchSendMessage, object: nil)
	}
	
	func output(_ money:String) -> String {
		return numberFormat(String(Float(money)! * self.rate), maximumFractionDigits: 2)
	}
	
	func numberFormat(_ s: String, maximumFractionDigits: Int = 20) -> String {
		//let shared = UserDefaults(suiteName: Config.groupId)
		//let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
		var price: NSNumber = 0
		if let myInteger = Double(s) {
			price = NSNumber(value:myInteger)
		}
		//创建一个NumberFormatter对象
		let numberFormatter = NumberFormatter()
		//设置number显示样式
		numberFormatter.numberStyle = .decimal  // 小数形式
		numberFormatter.usesGroupingSeparator = true //设置用组分隔
		numberFormatter.maximumFractionDigits = maximumFractionDigits //设置小数点后最多3位
		let format = numberFormatter.string(from: price)!
		return format
	}
	
	@objc func onDidWatchSendMessage(_ notification: Notification) {
		if let data = notification.userInfo as? [String: Any] {
			print("Notification data:", data)
			self.fromSymbol = data["fromSymbol"] as? String
			self.toSymbol = (data["toSymbol"] as! String)
			self.rate = (data["rate"] as! NSNumber).floatValue
			
			let shared = UserDefaults(suiteName: Config.groupId)
			shared?.set(self.fromSymbol, forKey: "fromSymbol")
			shared?.set(self.toSymbol, forKey: "toSymbol")
			shared?.set(self.rate, forKey: "rate")
			
			self.refresh()
		}
	}
	
	func onInput(_ n: String) {
		switch n {
		case "AC":
			self.isEmpty = true
			self.fromMoney = "0"
		case "0":
			if fromMoney != "0" {
				self.fromMoney += "0"
				self.isEmpty = false
			}
		case ".":
			if !self.fromMoney.contains(".") {
				self.fromMoney += "."
				self.isEmpty = false
			}
		default:
			self.fromMoney = self.isEmpty ? n : self.fromMoney + n
			self.isEmpty = false
		}

		fromMoneyLabel.setText(self.numberFormat(self.fromMoney))
		toMoneyLabel.setText(self.output(self.fromMoney))
	}

	@IBAction func input7() {
		onInput("7")
	}
	@IBAction func input8() {
		onInput("8")
	}
	@IBAction func input9() {
		onInput("9")
	}
	@IBAction func input0() {
		onInput("0")
	}
	@IBAction func input4() {
		onInput("4")
	}
	@IBAction func input5() {
		onInput("5")
	}
	@IBAction func input6() {
		onInput("6")
	}
	@IBAction func inputDot() {
		onInput(".")
	}
	@IBAction func input1() {
		onInput("1")
	}
	@IBAction func inpu2() {
		onInput("2")
	}
	@IBAction func input3() {
		onInput("3")
	}
	@IBAction func inputAC() {
		onInput("AC")
	}
}
