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
	var fromSymbol: String = "USD"
	
	// 输出货币类型
	var toSymbol: String = "CNY"
	
	// 是否为收起模式
	var isCompact: Bool = true
	
	var rate: Float!
	
	var rates: Dictionary<String,NSNumber>!
	
	var fromMoneyLabel: UILabel!
	var toMoneyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
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
		print("maxWidth %f maxHeight %f",maxSize.width,maxSize.height)
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
	
	func clearViews() {
		for v in self.view.subviews as [UIView] {
			v.removeFromSuperview()
		}
	}
	
	func initConfig() {
		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: self.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol") ?? "USD"
		self.toSymbol = shared?.string(forKey: "toSymbol") ?? "CNY"
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
		print("UIScreen.main.bounds.width:", UIScreen.main.bounds.width)
		print("buttonWidth:", buttonWidth)
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
			btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
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
		let currency = sender.tag == 1 ? self.fromSymbol : self.toSymbol
		let url: URL = URL.init(string: "currencyconverter://currencypicker/\(type)/\(currency)")!
		self.extensionContext?.open(url)
	}
	
	// 格式化输出换算结果
	func output(_ money:String) -> String {
		let shared = UserDefaults(suiteName: groupId)
		let decimals: Int = shared?.integer(forKey: "decimals") ?? 0
		return addThousandSeparator(String(format: "%.\(String(decimals))f", Float(money)! * self.rate))
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func addThousandSeparator(_ s:String) -> String {
		let shared = UserDefaults(suiteName: groupId)
		print((shared?.bool(forKey: "thousandSeparator"))!)
		if ((shared?.bool(forKey: "thousandSeparator"))!) {
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
