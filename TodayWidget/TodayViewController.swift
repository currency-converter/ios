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
	
	// 当前输入货币是否为空
	var isEmpty: Bool = true
	
	// 当前运算符
	var operatorSign:String = ""
	
	var operatorButton:UIButton!
	
	// 被操作的数
	var operatorEnd:String = "0"
	
	// 输入货币数量
	var fromMoney: String = "0"
	
	var rate: Float = 6.66
	
	var fromMoneyLabel: UILabel!
	var toMoneyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		initView()
		
		if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)) {
			//在ios10 中支持折叠
			self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
		}
		
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 100)
		
		//self.actionButton.addTarget(self, action: #selector(openButtonPressed), for: UIControl.Event.touchUpInside)
    }
	
	//折叠change size
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		print("maxWidth %f maxHeight %f",maxSize.width,maxSize.height)
		
		if activeDisplayMode == NCWidgetDisplayMode.compact {
			self.preferredContentSize = CGSize(width: maxSize.width, height: 110);
		} else {
			self.preferredContentSize = CGSize(width: maxSize.width, height: 420);
		}
	}
	
	func initView() {
		let padding: CGFloat = 20
		let arrowWidth: CGFloat = 30
		let labelWidth: CGFloat = (UIScreen.main.bounds.width-4*padding-arrowWidth)/2
		fromMoneyLabel = UILabel(frame: CGRect(x: padding, y: padding, width: labelWidth, height: 30))
		fromMoneyLabel.backgroundColor = UIColor.white
		fromMoneyLabel.layer.cornerRadius = 15
		fromMoneyLabel.clipsToBounds = true
		fromMoneyLabel.textAlignment = .center
		fromMoneyLabel.text = self.fromMoney
		self.view.addSubview(fromMoneyLabel)
		
		let arrowLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width-arrowWidth)/2, y: padding, width: arrowWidth, height: 30))
		arrowLabel.text = "→"
		self.view.addSubview(arrowLabel)
		
		
		toMoneyLabel = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width+arrowWidth)/2, y: padding, width: labelWidth, height: 30))
		toMoneyLabel.backgroundColor = UIColor.white
		toMoneyLabel.layer.cornerRadius = 15
		toMoneyLabel.clipsToBounds = true
		toMoneyLabel.textAlignment = .center
		toMoneyLabel.text = self.output(self.fromMoney)
		self.view.addSubview(toMoneyLabel)
		
		let fromSign = UILabel(frame: CGRect(x: padding, y: 50, width: labelWidth, height: 30))
		fromSign.textAlignment = .center
		fromSign.font = UIFont.systemFont(ofSize: 14)
		fromSign.text = "USD"
		self.view.addSubview(fromSign)
		
		let toSign = UILabel(frame: CGRect(x: (UIScreen.main.bounds.width+arrowWidth)/2, y: 50, width: labelWidth, height: 30))
		toSign.textAlignment = .center
		toSign.font = UIFont.systemFont(ofSize: 14)
		toSign.text = "CNY"
		self.view.addSubview(toSign)
		
		let keyboard = UIView(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: 400))
		self.view.addSubview(keyboard)
		
		let buttonWidth = (UIScreen.main.bounds.width - 180) / 4
		let buttonPadding:CGFloat = 10
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % 4) + buttonPadding, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/4))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.backgroundColor = UIColor.hex("2c2c2c")
			btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			
			switch item {
//			case "=", "+", "-", "AC":
//				//btn.setBackgroundColor(color: UIColor.hex("ff9408"), forState: .normal)
//				//btn.setBackgroundColor(color: UIColor.hex("fbd5aa"), forState: .highlighted)
//				//btn.setBackgroundColor(color: UIColor.hex("fefefe"), forState: .selected)
//				btn.setTitleColor(UIColor.hex("fb9601"), for: .selected)
//			case "A":
//				//btn.setBackgroundColor(color: UIColor.hex("2c2c2c"), forState: .normal)
//				btn.titleLabel?.font = UIFont(name:"CurrencyConverter", size:32)
			default:
				//btn.setBackgroundColor(color: UIColor.hex("424242"), forState: .normal)
				//btn.setBackgroundColor(color: UIColor.hex("646464"), forState: .highlighted)
				btn.setTitle(item, for: UIControl.State.normal)
			}
			
			//btn.setTitle(item, for: UIControl.State.normal)
			keyboard.addSubview(btn)
		}
	}
	
	func openButtonPressed() -> Void {
//		let url : URL = URL.init(string: "widgetDemo://open")!
//		self.extensionContext?.open(url, completionHandler: {(isSucces) in
//			print("点击了open按钮，来唤醒APP，是否成功 : \(isSucces)")
//		})
		
	}
	
	@objc func onInput(_ sender: UIButton) {
		let n = sender.currentTitle
		
		//清除+-的选中状态
//		self.operatorButton?.isSelected = false
//
		switch n {
		case "AC":
			self.isEmpty = true
			self.fromMoney = "0"
			self.operatorEnd = "0"
			self.operatorSign = ""
		//case "A":
			//self.onSettingsClick(sender)
		case "+", "-":
			if !self.isEmpty {
				self.operatorSign = n ?? ""
				self.operatorEnd = "0"
				self.operatorButton = sender
				sender.isSelected = true
			}
		case "=":
			if self.operatorEnd != "0" {
				var a:Float = 0
				if self.operatorSign == "+" {
					a = (self.fromMoney as NSString).floatValue + (self.operatorEnd as NSString).floatValue
				} else {
					a = (self.fromMoney as NSString).floatValue - (self.operatorEnd as NSString).floatValue
				}
				self.fromMoney = "\(a)"
			}
			self.operatorSign = ""
			self.operatorEnd = "0"
		case "0":
			if self.operatorSign == "" {
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
			if self.operatorSign == "" {
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
			if self.operatorSign == "" {
				self.fromMoney = self.isEmpty ? n! : self.fromMoney + n!
				self.isEmpty = false
			} else {
				self.operatorEnd += n!
			}
		}

		if self.operatorSign != "" && self.operatorEnd != "0" {
			fromMoneyLabel.text = addThousandSeparator(self.operatorEnd)
			toMoneyLabel.text = self.output(self.operatorEnd)
		} else {
			fromMoneyLabel.text = addThousandSeparator(self.fromMoney)
			toMoneyLabel.text = self.output(self.fromMoney)
		}
	}
	
	// 格式化输出换算结果
	func output(_ money:String) -> String {
		let decimals = UserDefaults.standard.integer(forKey: "decimals")
		return addThousandSeparator(String(format: "%.\(String(decimals))f", Float(money)! * self.rate))
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func addThousandSeparator(_ s:String) -> String {
		if (UserDefaults.standard.bool(forKey: "thousandSeparator")) {
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
