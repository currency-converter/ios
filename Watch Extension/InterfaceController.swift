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
    
    var zero: String = NumberFormatter().string(from: 0)!
    
    // 左操作数真实值
    var leftOperand: String = "0"
    // 左操作数显示值
    var leftOperandDisplayValue: String = NumberFormatter().string(from: 0)!
	
	// 汇率
	var rate: Float = 1
	
	var favorites: [String]!
	
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
		self.rate = shared?.float(forKey: "rate") ?? 1
	}
	
	func render() {
		let buttonColumns: CGFloat = 4
		let buttonRows: CGFloat = 3
		let buttonWidth: CGFloat = (self.contentFrame.width - 4 * (buttonColumns - 1))/buttonColumns
		let buttonHeight: CGFloat = (self.contentFrame.height - 8 * (buttonRows - 1))/(buttonRows + 2)
		
		group1.setHeight(25)
		group2.setHeight(25)
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
        
        buttonDot.setTitle(NumberFormatter().decimalSeparator)
		buttonAC.setBackgroundColor(UIColor.loquatYellow)
		
		self.refresh()
	}
	
	func refresh() {
		if let path = Bundle.main.path(forResource: fromSymbol, ofType: "png") {
			fromFlagImage.setImage(UIImage(contentsOfFile: path))
		}
		if let path = Bundle.main.path(forResource: toSymbol, ofType: "png") {
			toFlagImage.setImage(UIImage(contentsOfFile: path))
		}
		
		fromMoneyLabel.setText(leftOperandDisplayValue)
		toMoneyLabel.setText(output(leftOperand))
	}
	
	func observe() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidWatchSendMessage), name: .didWatchSendMessage, object: nil)
	}
	
	func output(_ money:String) -> String {
		return numberFormat(String(Float(money)! * self.rate), maximumFractionDigits: 2)
	}
	
	func numberFormat(_ s: String, maximumFractionDigits: Int = 20) -> String {
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

			let shared = UserDefaults(suiteName: Config.groupId)

			if let fromSymbol = data["fromSymbol"] as? String {
				self.fromSymbol = fromSymbol
				shared?.set(self.fromSymbol, forKey: "fromSymbol")
			}
			
			if let toSymbol = data["toSymbol"] as? String {
				self.toSymbol = toSymbol
				shared?.set(self.toSymbol, forKey: "toSymbol")
			}
			
			if let rate = data["rate"] as? NSNumber {
				self.rate = rate.floatValue
				shared?.set(self.rate, forKey: "rate")
			}
			
			if let favorites = data["favorites"] as? [String] {
				shared?.set(favorites, forKey: "favorites")
			}
			
			self.refresh()
		}
	}
	
    func onInput(_ plainValue: String, _ labelValue: String) {
        let decimalSeparator = String(NumberFormatter().decimalSeparator)
        
		switch plainValue {
		case "AC":
            self.isEmpty = true
            self.leftOperand = "0"
            self.leftOperandDisplayValue = zero
		case "0":
            if !self.isEmpty {
                self.leftOperand += "0"
                self.leftOperandDisplayValue += zero
            }
		case ".":
            if self.isEmpty {
                self.leftOperand = "0."
                self.leftOperandDisplayValue = zero + decimalSeparator
                self.isEmpty = false
            } else {
                if !self.leftOperand.contains(".") {
                    self.leftOperand += "."
                    self.leftOperandDisplayValue += decimalSeparator
                }
            }
		default:
            self.leftOperand = self.isEmpty ? plainValue : self.leftOperand + plainValue
            self.leftOperandDisplayValue = self.isEmpty ? labelValue : self.leftOperandDisplayValue + labelValue
            self.isEmpty = false
		}

		fromMoneyLabel.setText(self.leftOperandDisplayValue)
		toMoneyLabel.setText(self.output(self.leftOperand))
	}

	@IBAction func input7() {
		onInput("7", "7")
	}
	@IBAction func input8() {
		onInput("8", "8")
	}
	@IBAction func input9() {
		onInput("9", "9")
	}
	@IBAction func input0() {
		onInput("0", "0")
	}
	@IBAction func input4() {
		onInput("4", "4")
	}
	@IBAction func input5() {
		onInput("5", "5")
	}
	@IBAction func input6() {
		onInput("6", "6")
	}
	@IBAction func inputDot() {
		onInput(".", ".")
	}
	@IBAction func input1() {
		onInput("1", "1")
	}
	@IBAction func inpu2() {
		onInput("2", "2")
	}
	@IBAction func input3() {
		onInput("3", "3")
	}
	@IBAction func inputAC() {
		onInput("AC", "AC")
	}
	@IBAction func pickToSymbol(_ sender: Any) {
		presentController(withName: "Currency", context: ["toSymbol", self.toSymbol])
	}
	@IBAction func pickFromSymbol(_ sender: Any) {
		presentController(withName: "Currency", context: ["fromSymbol", self.fromSymbol])
	}

}
