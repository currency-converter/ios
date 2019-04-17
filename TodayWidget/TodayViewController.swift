//
//  TodayViewController.swift
//  TodayWidget
//
//  Created by zhi.zhong on 2019/4/9.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	
	let groupId: String = "group.com.zhongzhi.currencyconverter"
	
	// 当前输入货币是否为空
	var isEmpty: Bool = true
	
	// 当前运算符
	var operatorSymbol:String = ""
	
	var operatorButton:UIButton!
	
	// 被操作的数
	var operatorEnd:String = "0"
	
	// 输入货币数量
	var fromMoney: String = "0"
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	var defaults:[String:Any] = [
		// 小数位数
		"decimals": 2,
		// 使用千位分隔符
		"thousandSeparator": true,
		// 是否使用按键声音
		"sounds": false,
		"fromSymbol": "USD",
		"toSymbol": "CNY",
		"favorites": ["CNY", "HKD", "JPY", "USD"],
		"rates": [
			"AED":3.6728,"AUD":1.4013,"BGN":1.7178,"BHD":0.3769,"BND":1.3485,"BRL":3.7255,"BYN":2.13,"CAD":1.31691,"CHF":0.99505,"CLP":648.93,"CNY":6.6872,"COP":3069,"CRC":605.45,"CZK":22.4794,"DKK":6.54643,"DZD":118.281,"EGP":17.47,"EUR":0.8771,"GBP":0.75226,"HKD":7.8496,"HRK":6.5141,"HUF":277.27,"IDR":14067,"ILS":3.6082,"INR":71.0925,"IQD":1190,"ISK":119.5,"JOD":0.708,"JPY":110.749,"KES":99.85,"KHR":3958,"KRW":1121.95,"KWD":0.3032,"LAK":8565,"LBP":1505.7,"LKR":180.05,"MAD":9.539,"MMK":1499,"MOP":8.0847,"MXN":19.1921,"MYR":4.065,"NOK":8.53527,"NZD":1.4617,"OMR":0.3848,"PHP":51.72,"PLN":3.7801,"QAR":3.6406,"RON":4.1578,"RSD":103.5678,"RUB":65.7806,"SAR":3.75,"SEK":9.19689,"SGD":1.34869,"SYP":514.98,"THB":31.489,"TRY":5.3232,"TWD":30.783,"TZS":2338,"UGX":3668,"USD":1,"VND":23190,"ZAR":13.9727
		]
	]
	
	// 是否为收起模式
	var isCompact: Bool = true
	
	var rate: Float!
	
	var rates: Dictionary<String,NSNumber>!
	
	var fromMoneyLabel: UILabel!
	var toMoneyLabel: UILabel!
	
	// 最外层间隔宽度
	let expandedPadding: CGFloat = 20
	//货币符号的宽度
	let expandedSymbolWidth: CGFloat = 60
	//货币符号的高度
	let expandedSymbolHeight: CGFloat = 60
	//键盘上间距
	let expandedKeyboardMarginTop: CGFloat = 20
	//每个数字按钮间距
	let expandedButtonMargin: CGFloat = 10
	//展开时高度(运行时会修改)
	var expandedHeight: CGFloat = 400
	//收起时高度，不能小于110
	let compactHeight: CGFloat = 110
	//货币数字字体大小
	let expandedMoneyFontSize: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		self.view.backgroundColor = UIColor.black
		self.expandedHeight = self.view.frame.width + expandedSymbolHeight * 2 + expandedKeyboardMarginTop
		
		self.registerSettingsBundle()
		self.initConfig()
		
		if self.isCompact {
			renderCompactMode()
		} else {
			renderExpandedMode()
		}
		
		if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)) {
			//在ios10 中支持折叠
			self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
		}
		
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: compactHeight)
    }
	
	//折叠change size
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		self.clearViews()
		
		if activeDisplayMode == NCWidgetDisplayMode.compact {
			self.isCompact = true
			self.preferredContentSize = CGSize(width: maxSize.width, height: compactHeight);
			
			//延时2秒，让切换效果更加自然
			DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
				self.renderCompactMode()
			})
		} else {
			self.isCompact = false
			self.preferredContentSize = CGSize(width: maxSize.width, height: expandedHeight);
			renderExpandedMode()
		}
	}
	
	func registerSettingsBundle() {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.register(defaults: defaults)
	}
	
	func clearViews() {
		for v in self.view.subviews as [UIView] {
			v.removeFromSuperview()
		}
	}
	
	func initConfig() {
		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: self.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol") ?? defaults["fromSymbol"] as! String
		self.toSymbol = shared?.string(forKey: "toSymbol") ?? defaults["toSymbol"] as! String
		self.rates = shared?.object(forKey: "rates") as? Dictionary<String, NSNumber>
		let fromRate:Float! = rates[self.fromSymbol]?.floatValue
		let toRate:Float! = rates[self.toSymbol]?.floatValue
		self.rate = toRate/fromRate
	}
	
	func renderCompactMode() {
		//整体间距
		let margin: CGFloat = 10
		//屏幕宽度
		let screenWidth: CGFloat = 110
		//屏幕高度
		let screenHeight: CGFloat = compactHeight - margin * 2
		//两个小屏幕之间的间距
		let screenMargin: CGFloat = 2
		//小屏幕高度
		let subScreenHeight: CGFloat = (screenHeight - screenMargin) / 2
		
		let symbolMargin: CGFloat = 3
		
		let symbolHeight: CGFloat = 15
		let symbolWidth: CGFloat = 40
		
		//键盘宽度
		let keyboardWidth: CGFloat = self.view.frame.width - screenWidth - margin * 3
		let keyboardHeight: CGFloat = screenHeight
		
		let screen: UIView = UIView(frame: CGRect(x: margin, y: margin, width: screenWidth, height: screenHeight))
		//screen.backgroundColor = UIColor.green
		self.view.addSubview(screen)
		
		let fromScreen: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: subScreenHeight))
		fromScreen.tag = 1
		fromScreen.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		fromScreen.backgroundColor = UIColor.hex("333333")
		fromScreen.layer.cornerRadius = 5
		screen.addSubview(fromScreen)
		
		let toScreen: UIButton = UIButton(frame: CGRect(x: 0, y: subScreenHeight + screenMargin, width: screenWidth, height: subScreenHeight))
		toScreen.tag = 2
		toScreen.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		toScreen.backgroundColor = UIColor.hex("222222")
		toScreen.layer.cornerRadius = 5
		screen.addSubview(toScreen)
		
		let fromSymbol = UIButton(frame: CGRect(x: symbolMargin, y: symbolMargin, width: symbolWidth, height: symbolHeight))
		//fromSymbol.backgroundColor = UIColor.red
		//fromSymbol.layer.cornerRadius = 5
		//fromSymbol.tag = 1
		fromSymbol.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
		fromSymbol.setTitle(self.fromSymbol, for: .normal)
		fromSymbol.setTitleColor(UIColor.gray, for: .normal)
		//fromSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		fromScreen.addSubview(fromSymbol)

		fromMoneyLabel = UILabel(frame: CGRect(x: symbolMargin, y: symbolMargin + symbolHeight, width: fromScreen.frame.width - symbolMargin * 2, height: subScreenHeight - symbolHeight - symbolMargin))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		//fromMoneyLabel.backgroundColor = UIColor.gray
		fromMoneyLabel.textAlignment = .right
		fromMoneyLabel.textColor = UIColor.gray
		fromMoneyLabel.font = UIFont.boldSystemFont(ofSize: 18)
		fromMoneyLabel.text = self.fromMoney
		fromScreen.addSubview(fromMoneyLabel)

		let toSymbol = UIButton(frame: CGRect(x: symbolMargin, y: symbolMargin, width: symbolWidth, height: symbolHeight))
		//toSymbol.backgroundColor = UIColor.green
		//toSymbol.tag = 2
		toSymbol.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
		toSymbol.setTitle(self.toSymbol, for: .normal)
		toSymbol.setTitleColor(UIColor.white, for: .normal)
		//toSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		toScreen.addSubview(toSymbol)

		toMoneyLabel = UILabel(frame: CGRect(x: symbolMargin, y: symbolMargin + symbolHeight, width: fromScreen.frame.width - symbolMargin * 2, height: subScreenHeight - symbolHeight - symbolMargin))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		toMoneyLabel.textColor = UIColor.white
		toMoneyLabel.font = UIFont.boldSystemFont(ofSize: 18)
		//toMoneyLabel.backgroundColor = UIColor.gray
		toMoneyLabel.textAlignment = .right
		toMoneyLabel.text = self.output(self.fromMoney)
		toScreen.addSubview(toMoneyLabel)
//
//		let arrowLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 30, height: 30))
//		//arrowLabel.backgroundColor = UIColor.red
//		arrowLabel.text = "⇩"
//		arrowLabel.textColor = UIColor.white
//		arrowLabel.textAlignment = .left
//		self.view.addSubview(arrowLabel)
		
		let keyboard = UIView(frame: CGRect(x: screenWidth + margin * 2, y: margin, width: keyboardWidth, height: keyboardHeight))
		//keyboard.backgroundColor = UIColor.lightGray
		keyboard.clipsToBounds = true
		self.view.addSubview(keyboard)
		
		//每行显示按钮个数
		let numberOfButtonsPerLine: CGFloat = 6
		//按钮左右间距
		let buttonMarginLeft: CGFloat = 5
		//按钮宽度
		let buttonWidth: CGFloat = (keyboard.frame.width - buttonMarginLeft * (numberOfButtonsPerLine - 1)) / numberOfButtonsPerLine
		let buttonY: CGFloat = (subScreenHeight - buttonWidth)/2
		let characters:[String] = ["4", "5", "6", "7", "8", "9", "0", "1", "2", "3", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			let columnIndex: CGFloat = CGFloat(index % Int(numberOfButtonsPerLine))
			let x: CGFloat = (buttonWidth + buttonMarginLeft) * columnIndex
			let y: CGFloat = buttonY + CGFloat(floor(Double(index / Int(numberOfButtonsPerLine)))) * subScreenHeight
			var btn: UIButton
			btn = UIButton.init(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			//btn.layer.borderWidth = 1
			//btn.layer.borderColor = UIColor.hex("2c2c2c").cgColor
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.backgroundColor = UIColor.hex("2c2c2c")
			if item == "AC" {
				btn.backgroundColor = UIColor.hex("ff9408")
			}
			btn.setTitle(item, for: UIControl.State.normal)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			keyboard.addSubview(btn)
		}
	}
	
	func renderExpandedMode() {
		let wrapperWidth: CGFloat = self.view.frame.width - expandedPadding * 2
		let wrapperHeight: CGFloat = expandedHeight - expandedPadding * 2
		
		let wrapper = UIView(frame: CGRect(x: expandedPadding, y: expandedPadding, width: wrapperWidth, height: wrapperHeight))
		//wrapper.backgroundColor = UIColor.green
		self.view.addSubview(wrapper)
		
		//货币输入框的宽度
		let moneyLabelWidth: CGFloat = wrapper.frame.width - expandedSymbolWidth

		fromMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: moneyLabelWidth, height: expandedSymbolHeight))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		//fromMoneyLabel.backgroundColor = UIColor.yellow
		fromMoneyLabel.font = UIFont.systemFont(ofSize: expandedMoneyFontSize)
		fromMoneyLabel.textColor = UIColor.gray
		fromMoneyLabel.textAlignment = .right
		fromMoneyLabel.text = self.fromMoney
		wrapper.addSubview(fromMoneyLabel)

		let fromSymbol = UIButton(frame: CGRect(x: moneyLabelWidth, y: 0, width: expandedSymbolWidth, height: expandedSymbolHeight))
		fromSymbol.tag = 1
		//fromSymbol.backgroundColor = UIColor.red
		fromSymbol.setTitle("USD", for: .normal)
		fromSymbol.setTitleColor(UIColor.gray, for: .normal)
		fromSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		wrapper.addSubview(fromSymbol)
		
		toMoneyLabel = UILabel(frame: CGRect(x: 0, y: expandedSymbolHeight, width: moneyLabelWidth, height: expandedSymbolHeight))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		//toMoneyLabel.backgroundColor = UIColor.purple
		toMoneyLabel.font = UIFont.systemFont(ofSize: expandedMoneyFontSize)
		toMoneyLabel.textColor = UIColor.white
		toMoneyLabel.textAlignment = .right
		toMoneyLabel.text = self.output(self.fromMoney)
		wrapper.addSubview(toMoneyLabel)

		let toSymbol = UIButton(frame: CGRect(x: moneyLabelWidth, y: expandedSymbolHeight, width: expandedSymbolWidth, height: expandedSymbolHeight))
		toSymbol.tag = 2
		//toSymbol.backgroundColor = UIColor.brown
		toSymbol.setTitle("CNY", for: .normal)
		toSymbol.setTitleColor(UIColor.white, for: .normal)
		toSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		wrapper.addSubview(toSymbol)
		
		let keyboardY :CGFloat = expandedSymbolHeight * 2 + expandedKeyboardMarginTop
		let keyboard = UIView(frame: CGRect(x: 0, y: keyboardY, width: wrapper.frame.width, height: wrapper.frame.height - keyboardY))
		//keyboard.backgroundColor = UIColor.red
		wrapper.addSubview(keyboard)
		
		let buttonWidth: CGFloat = (keyboard.frame.width - expandedButtonMargin * 3) / 4
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			let columnIndex: CGFloat = CGFloat(index % 4)
			let x: CGFloat = (buttonWidth + expandedButtonMargin) * columnIndex
			let y: CGFloat = (buttonWidth + expandedButtonMargin) * CGFloat(floor(Double(index / 4)))
			btn = UIButton.init(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonWidth))
			btn.layer.cornerRadius = buttonWidth / 2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
			btn.setTitle(item, for: UIControl.State.normal)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			
			switch item {
			case "=", "+", "-", "AC":
				btn.backgroundColor = UIColor.hex("ff9408")
			case "A":
				btn.backgroundColor = UIColor.hex("2c2c2c")
				btn.titleLabel?.font = UIFont(name:"CurrencyConverter", size:28)
			default:
				btn.backgroundColor = UIColor.hex("424242")
			}
		
			keyboard.addSubview(btn)
		}
	}
	
	@objc func onInput(_ sender: UIButton) {
		let n = sender.currentTitle
		
		switch n {
		case "AC":
			self.isEmpty = true
			self.fromMoney = "0"
			self.operatorEnd = "0"
			self.operatorSymbol = ""
		case "A":
			self.onSettingsClick()
		case "+", "-":
			if !self.isEmpty {
				self.operatorSymbol = n ?? ""
				self.operatorEnd = "0"
				self.operatorButton = sender
				sender.isSelected = true
			}
		case "=":
			if self.operatorEnd != "0" {
				var a:Float = 0
				if self.operatorSymbol == "+" {
					a = (self.fromMoney as NSString).floatValue + (self.operatorEnd as NSString).floatValue
				} else {
					a = (self.fromMoney as NSString).floatValue - (self.operatorEnd as NSString).floatValue
				}
				self.fromMoney = "\(a)"
			}
			self.operatorSymbol = ""
			self.operatorEnd = "0"
		case "0":
			if self.operatorSymbol == "" {
				if fromMoney != "0" {
					self.fromMoney += "0"
					self.isEmpty = false
				}
			} else {
				if operatorEnd != "0" {
					self.operatorEnd += "0"
				}
			}
		case ".":
			if self.operatorSymbol == "" {
				if !self.fromMoney.contains(".") {
					self.fromMoney += "."
					self.isEmpty = false
				}
			} else {
				if !self.operatorEnd.contains(".") {
					self.operatorEnd += "."
				}
			}
		default:
			if self.operatorSymbol == "" {
				self.fromMoney = self.isEmpty ? n! : self.fromMoney + n!
				self.isEmpty = false
			} else {
				self.operatorEnd += n!
			}
		}

		if self.operatorSymbol != "" && self.operatorEnd != "0" {
			fromMoneyLabel.text = addThousandSeparator(self.operatorEnd)
			toMoneyLabel.text = self.output(self.operatorEnd)
		} else {
			fromMoneyLabel.text = addThousandSeparator(self.fromMoney)
			toMoneyLabel.text = self.output(self.fromMoney)
		}
	}
	
	@objc func onSettingsClick() {
		let url: URL = URL.init(string: "currencyconverter://settings")!
		self.extensionContext?.open(url)
	}
	
	@objc func onCurrencyPickerClick(_ sender: UIButton) {
		let type = sender.tag == 1 ? "from" : "to"
		let currency: String = sender.tag == 1 ? self.fromSymbol : self.toSymbol
		let url: URL = URL.init(string: "currencyconverter://currencypicker/\(type)/\(currency)")!
		self.extensionContext?.open(url)
	}
	
	// 格式化输出换算结果
	func output(_ money:String) -> String {
		let shared = UserDefaults(suiteName: self.groupId)
		let decimals: Int = shared?.integer(forKey: "decimals") ?? self.defaults["decimals"] as! Int
		return addThousandSeparator(String(format: "%.\(String(decimals))f", Float(money)! * self.rate))
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func addThousandSeparator(_ s:String) -> String {
		let shared = UserDefaults(suiteName: self.groupId)
		if shared?.bool(forKey: "thousandSeparator") ?? self.defaults["thousandSeparator"] as! Bool {
			var price: NSNumber = 0
			if let myInteger = Double(s) {
				price = NSNumber(value:myInteger)
			}
			let f = NumberFormatter()
			f.numberStyle = .decimal
			return f.string(from: price)!
		}
		return s
	}
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
