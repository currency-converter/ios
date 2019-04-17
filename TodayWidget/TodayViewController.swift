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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
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
		
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 110)
    }
	
	//折叠change size
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		self.clearViews()
		
		if activeDisplayMode == NCWidgetDisplayMode.compact {
			self.isCompact = true
			self.preferredContentSize = CGSize(width: maxSize.width, height: 110);
			renderCompactMode()
		} else {
			self.isCompact = false
			self.preferredContentSize = CGSize(width: maxSize.width, height: 460);
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
		let fromSymbol = UIButton(frame: CGRect(x: 10, y: 10, width: 40, height: 45))
		//fromSymbol.backgroundColor = UIColor.yellow
		fromSymbol.tag = 1
		fromSymbol.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		fromSymbol.setTitle(self.fromSymbol, for: .normal)
		fromSymbol.setTitleColor(UIColor.black, for: .normal)
		fromSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		self.view.addSubview(fromSymbol)
		
		fromMoneyLabel = UILabel(frame: CGRect(x: 50, y: 10, width: 70, height: 45))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		//fromMoneyLabel.backgroundColor = UIColor.gray
		//fromMoneyLabel.textAlignment = .right
		fromMoneyLabel.text = self.fromMoney
		self.view.addSubview(fromMoneyLabel)
		
		let toSymbol = UIButton(frame: CGRect(x: 10, y: 55, width: 40, height: 45))
		//toSymbol.backgroundColor = UIColor.yellow
		toSymbol.tag = 2
		toSymbol.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		toSymbol.setTitle(self.toSymbol, for: .normal)
		toSymbol.setTitleColor(UIColor.black, for: .normal)
		toSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		self.view.addSubview(toSymbol)
		
		toMoneyLabel = UILabel(frame: CGRect(x: 50, y: 55, width: 70, height: 45))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		//toMoneyLabel.backgroundColor = UIColor.gray
		//toMoneyLabel.textAlignment = .right
		toMoneyLabel.text = self.output(self.fromMoney)
		self.view.addSubview(toMoneyLabel)
		
		let arrowLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 30, height: 30))
		//arrowLabel.backgroundColor = UIColor.red
		arrowLabel.text = "⇩"
		arrowLabel.textAlignment = .left
		self.view.addSubview(arrowLabel)
		
		let keyboard = UIView(frame: CGRect(x: 120, y: 10, width: UIScreen.main.bounds.width - 145, height: 90))
		//keyboard.backgroundColor = UIColor.lightGray
		self.view.addSubview(keyboard)
		
		let numberOfButtonsPerLine: Int = 6
		let buttonPadding :CGFloat = 5
		let buttonWidth: CGFloat = (UIScreen.main.bounds.width - 150) / CGFloat(numberOfButtonsPerLine) - buttonPadding
		let characters:[String] = ["4", "5", "6", "7", "8", "9", "0", "1", "2", "3", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % numberOfButtonsPerLine) + buttonPadding, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/numberOfButtonsPerLine))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.layer.borderWidth = 1
			btn.layer.borderColor = UIColor.hex("2c2c2c").cgColor
			btn.setTitleColor(UIColor.hex("2c2c2c"), for: .normal)
			//btn.backgroundColor = UIColor.hex("2c2c2c")
			btn.setTitle(item, for: UIControl.State.normal)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			keyboard.addSubview(btn)
		}
	}
	
	func renderExpandedMode() {
		let padding: CGFloat = 20
		let arrowWidth: CGFloat = 30
		let labelWidth: CGFloat = (UIScreen.main.bounds.width-4*padding-arrowWidth)/2
		fromMoneyLabel = UILabel(frame: CGRect(x: padding, y: padding, width: labelWidth, height: 30))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		fromMoneyLabel.backgroundColor = UIColor.black
		fromMoneyLabel.font = UIFont.systemFont(ofSize: 30)
		fromMoneyLabel.textColor = UIColor.white
		fromMoneyLabel.layer.cornerRadius = 15
		fromMoneyLabel.clipsToBounds = true
		fromMoneyLabel.textAlignment = .center
		fromMoneyLabel.text = self.fromMoney
		self.view.addSubview(fromMoneyLabel)
		
		let arrowLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width-arrowWidth)/2, y: padding, width: arrowWidth, height: 30))
		arrowLabel.text = "→"
		self.view.addSubview(arrowLabel)
		
		toMoneyLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width+arrowWidth)/2, y: padding, width: labelWidth, height: 30))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		toMoneyLabel.backgroundColor = UIColor.black
		toMoneyLabel.font = UIFont.systemFont(ofSize: 30)
		toMoneyLabel.textColor = UIColor.white
		toMoneyLabel.layer.cornerRadius = 15
		toMoneyLabel.clipsToBounds = true
		toMoneyLabel.textAlignment = .center
		toMoneyLabel.text = self.output(self.fromMoney)
		self.view.addSubview(toMoneyLabel)
		
		let fromSymbol = UIButton(frame: CGRect(x: padding, y: 50, width: labelWidth, height: 30))
		fromSymbol.tag = 1
		fromSymbol.setTitle("USD", for: .normal)
		fromSymbol.setTitleColor(UIColor.black, for: .normal)
		fromSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		self.view.addSubview(fromSymbol)
		
		let toSymbol = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width+arrowWidth)/2, y: 50, width: labelWidth, height: 30))
		toSymbol.tag = 2
		toSymbol.setTitle("CNY", for: .normal)
		toSymbol.setTitleColor(UIColor.black, for: .normal)
		toSymbol.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		self.view.addSubview(toSymbol)
		
		let keyboard = UIView(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 400))
		self.view.addSubview(keyboard)
		
		let buttonMargin: CGFloat = 20
		let buttonWidth: CGFloat = (UIScreen.main.bounds.width - 70 - buttonMargin * 2) / 4
		let buttonPadding :CGFloat = 10
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % 4) + buttonPadding + buttonMargin, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/4))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.backgroundColor = UIColor.hex("2c2c2c")
			if item == "A" {
				btn.titleLabel?.font = UIFont(name:"CurrencyConverter", size: 28)
			} else {
				btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
			}
			btn.setTitle(item, for: UIControl.State.normal)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
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
