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
	
	let isDebug: Bool = false
	
	var fromMoneyLabelTextColor: [UIColor] = [
		UIColor.hex("333333"),
        UIColor.black
	]
	
	var toMoneyLabelTextColor: [UIColor] = [
		UIColor.hex("333333"),
        UIColor.black
	]
	
	// 当前输入货币是否为空
	var isEmpty: Bool = true {
		didSet {
			let isChanged = oldValue != isEmpty
			if isChanged {
				self.fromMoneyLabel.textColor = fromMoneyLabelTextColor[(isEmpty ? 0 : 1)]
				self.toMoneyLabel.textColor = toMoneyLabelTextColor[(isEmpty ? 0 : 1)]
			}
		}
	}
	
	// 当前运算符
	var operatorSymbol:String = ""
	
	var operatorButton:UIButton!
	
	// 被操作的数
	var operatorEnd:String = "0"
	
	// 输入货币数量
	var fromMoney: String = "100"
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	// 是否为收起模式
//	var isCompact: Bool = true
	
	var rate: Float!
	
	var rates: [String: [String: NSNumber]]!
	
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
	var expandedHeight: CGFloat!
	//收起时高度，不能小于110
//	var compactHeight: CGFloat!
	var wrapperWidth: CGFloat!
	var wrapperHeight: CGFloat!
	//货币数字字体大小
	let expandedMoneyFontSize: CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		self.registerSettingsBundle()
		
		self.initConfig()
		
//		if self.isCompact {
//			renderCompactMode()
//		} else {
			render()
//		}
		
//		if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0)) {
//			//在ios10 中支持折叠
//			self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
//		}
//
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: expandedHeight)
	}
	
	//折叠change size
//	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
//		self.clearViews()
//
//		if activeDisplayMode == NCWidgetDisplayMode.compact {
//			self.isCompact = true
//			self.preferredContentSize = CGSize(width: maxSize.width, height: compactHeight);
//
//			//延时2秒，让切换效果更加自然
//			DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
//				self.renderCompactMode()
//			})
//		} else {
//			self.isCompact = false
//			self.preferredContentSize = CGSize(width: maxSize.width, height: expandedHeight);
//			renderExpandedMode()
//		}
//	}
	
	func registerSettingsBundle() {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.register(defaults: Config.defaults)
	}
	
//	func clearViews() {
//		for v in self.view.subviews as [UIView] {
//			v.removeFromSuperview()
//		}
//	}
	
	func initConfig() {
		self.wrapperWidth = (self.extensionContext?.widgetMaximumSize(for: .compact).width ?? 0) - self.expandedPadding * 2
//        self.compactHeight = self.extensionContext?.widgetMaximumSize(for: .expanded).height
		self.expandedHeight = self.expandedSymbolHeight * 2 + self.expandedKeyboardMarginTop + self.wrapperWidth + self.expandedPadding * 2

		let widgetMaxHeight: CGFloat = (self.extensionContext?.widgetMaximumSize(for: .expanded).height)!
		if UIDevice.current.userInterfaceIdiom == .pad && widgetMaxHeight == 616 {
			// iPad air & iPad air2 & iPad pro (9.7-inch) 组件高度不能超过616
			self.expandedHeight = widgetMaxHeight
		}
		self.wrapperHeight = self.expandedHeight - self.expandedPadding * 2

		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: Config.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol") ?? Config.defaults["fromSymbol"] as! String
		self.toSymbol = shared?.string(forKey: "toSymbol") ?? Config.defaults["toSymbol"] as! String
        self.rates = (shared?.object(forKey: "rates") ?? Config.defaults["rates"] as! [String: [String: NSNumber]]) as? [String: [String: NSNumber]]
		let fromRate: Float! = Float(truncating: (rates![self.fromSymbol]! as [String: NSNumber])["a"]!)
		let toRate: Float! = Float(truncating: (rates![self.toSymbol]! as [String: NSNumber])["a"]!)
		self.rate = toRate/fromRate
	}
	
	func render() {
		let shared = UserDefaults(suiteName: Config.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		let wrapper = UIView(frame: CGRect(x: self.expandedPadding, y: self.expandedPadding, width: self.wrapperWidth, height: self.wrapperHeight))
		if isDebug {
			wrapper.backgroundColor = UIColor.green
		}
		self.view.addSubview(wrapper)
		
		//货币输入框的宽度
		let moneyLabelWidth: CGFloat = wrapper.frame.width - expandedSymbolWidth

		fromMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: moneyLabelWidth, height: expandedSymbolHeight))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		fromMoneyLabel.font = UIFont.systemFont(ofSize: expandedMoneyFontSize)
		fromMoneyLabel.textColor = self.fromMoneyLabelTextColor[self.isEmpty ? 0 : 1]
		fromMoneyLabel.textAlignment = .right
		fromMoneyLabel.text = self.fromMoney
		if isDebug {
			fromMoneyLabel.backgroundColor = UIColor.gray
		}
		wrapper.addSubview(fromMoneyLabel)
		
		//国旗图片尺寸
		let flagWidth: CGFloat = 32
		let flagHeight: CGFloat = 24
		let flagPaddingTop: CGFloat = 10
		let symbolLabelHeight: CGFloat = 20
		let symbolLabelPaddingTop: CGFloat = 2
		
		// 货币符号容器
		let fromSymbolButton = UIButton(frame: CGRect(x: moneyLabelWidth, y: 0, width: expandedSymbolWidth, height: expandedSymbolHeight))
		fromSymbolButton.tag = 1
		if isDebug {
			fromSymbolButton.backgroundColor = UIColor.loquatYellow
		}
		let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onCurrencyPickerClick))
		fromSymbolButton.addGestureRecognizer(tapGesture)
		wrapper.addSubview(fromSymbolButton)
		
		// 货币国旗
		let fromFlagImage = UIImageView(frame: CGRect(x: (expandedSymbolWidth - flagWidth)/2, y: flagPaddingTop, width: flagWidth, height: flagHeight))
		if let path = Bundle.main.path(forResource: self.fromSymbol, ofType: "png") {
			fromFlagImage.image = UIImage(contentsOfFile: path)
		}
		fromSymbolButton.addSubview(fromFlagImage)
		
		// 货币缩写标签
		let fromSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: expandedSymbolWidth, height: symbolLabelHeight))
		// 如果是自定义汇率则在目标货币符号后加星号
		fromSymbolLabel.text = self.fromSymbol
		fromSymbolLabel.textAlignment = .center
		fromSymbolLabel.font = UIFont.systemFont(ofSize: 16)
		fromSymbolLabel.textColor = UIColor.black
		fromSymbolButton.addSubview(fromSymbolLabel)

		toMoneyLabel = UILabel(frame: CGRect(x: 0, y: expandedSymbolHeight, width: moneyLabelWidth, height: expandedSymbolHeight))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		toMoneyLabel.font = UIFont.systemFont(ofSize: expandedMoneyFontSize)
		toMoneyLabel.textColor = self.toMoneyLabelTextColor[self.isEmpty ? 0 : 1]
		toMoneyLabel.textAlignment = .right
		toMoneyLabel.text = self.output(self.fromMoney)
		if isDebug {
			toMoneyLabel.backgroundColor = UIColor.yellow
		}
		wrapper.addSubview(toMoneyLabel)
		
		let toSymbolButton = UIButton(frame: CGRect(x: moneyLabelWidth, y: expandedSymbolHeight, width: expandedSymbolWidth, height: expandedSymbolHeight))
		toSymbolButton.tag = 2
		if isDebug {
			toSymbolButton.backgroundColor = UIColor.red
		}
		let toTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onCurrencyPickerClick))
		toSymbolButton.addGestureRecognizer(toTapGesture)
		wrapper.addSubview(toSymbolButton)
		
		// 货币国旗
		let toFlagImage = UIImageView(frame: CGRect(x: (expandedSymbolWidth - flagWidth)/2, y: flagPaddingTop, width: flagWidth, height: flagHeight))
		if let path = Bundle.main.path(forResource: self.toSymbol, ofType: "png") {
			toFlagImage.image = UIImage(contentsOfFile: path)
		}
		toSymbolButton.addSubview(toFlagImage)
		
		// 货币缩写标签
		let toSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: expandedSymbolWidth, height: symbolLabelHeight))
		// 如果是自定义汇率则在目标货币符号后加星号
		toSymbolLabel.text = self.toSymbol + (isCustomRate ? "*" : "")
		toSymbolLabel.textAlignment = .center
		toSymbolLabel.font = UIFont.systemFont(ofSize: 16)
		toSymbolLabel.textColor = UIColor.black
		toSymbolButton.addSubview(toSymbolLabel)

		let keyboardY :CGFloat = expandedSymbolHeight * 2 + expandedKeyboardMarginTop
		let keyboard = UIView(frame: CGRect(x: 0, y: keyboardY, width: wrapper.frame.width, height: wrapper.frame.height - keyboardY))
		if isDebug {
			keyboard.backgroundColor = UIColor.red
		}
		wrapper.addSubview(keyboard)

		let buttonWidth: CGFloat = (keyboard.frame.width - expandedButtonMargin * 3) / 4
		let buttonHeight: CGFloat = (keyboard.frame.height - expandedButtonMargin * 3) / 4
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]

		for (index, item) in characters.enumerated() {
			let columnIndex: CGFloat = CGFloat(index % 4)
			let x: CGFloat = (buttonWidth + expandedButtonMargin) * columnIndex
			let y: CGFloat = (buttonHeight + expandedButtonMargin) * CGFloat(floor(Double(index / 4)))
			let btn :UIButton = UIButton.init(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight))
			btn.layer.cornerRadius = min(buttonWidth, buttonHeight) / 2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
			btn.setTitle(item, for: UIControl.State.normal)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)

			switch item {
			case "=", "+", "-", "AC":
				btn.backgroundColor = UIColor.hex("da8009")
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
		self.operatorButton?.backgroundColor = UIColor.hex("da8009")
		self.operatorButton?.setTitleColor(UIColor.white, for: .normal)
		
		switch n {
		case "AC":
			self.flash(button: sender)
			self.isEmpty = true
			self.fromMoney = "100"
			self.operatorEnd = "0"
			self.operatorSymbol = ""
		case "A":
			self.flash(button: sender)
			self.onSettingsClick()
		case "÷", "×", "+", "-":
			sender.backgroundColor = UIColor.white
			sender.setTitleColor(UIColor.hex("da8009"), for: .normal)
			
			// 连加
			if self.operatorEnd != "0" {
				self.exec()
			}
			
			if !self.isEmpty {
				self.operatorSymbol = n ?? ""
				self.operatorEnd = "0"
				self.operatorButton = sender
				sender.isSelected = true
			}
		case "=":
			self.flash(button: sender)
			if self.operatorEnd != "0" {
				self.exec()
			}
			self.operatorSymbol = ""
			self.operatorEnd = "0"
		case "0":
			if self.operatorSymbol == "" {
				self.flash(button: sender)
				if self.isEmpty {
					self.fromMoney = "0"
					self.isEmpty = false
				} else {
					self.fromMoney += "0"
				}
			} else {
				if operatorEnd != "0" {
					self.flash(button: sender)
					self.operatorEnd += "0"
				}
			}
		case ".":
			if self.operatorSymbol == "" {
				self.flash(button: sender)
				if self.isEmpty {
					self.fromMoney = "0."
					self.isEmpty = false
				} else {
					if !self.fromMoney.contains(".") {
						self.fromMoney += "."
					}
				}
			} else {
				self.flash(button: sender)
				if !self.operatorEnd.contains(".") {
					self.operatorEnd += "."
				}
			}
		default:
			self.flash(button: sender)
			
			if self.operatorSymbol == "" {
				self.fromMoney = self.isEmpty ? n! : self.fromMoney + n!
				self.isEmpty = false
			} else {
				self.operatorEnd += n!
			}
		}

		if self.operatorSymbol != "" && self.operatorEnd != "0" {
			fromMoneyLabel.text = numberFormat(self.operatorEnd)
			toMoneyLabel.text = self.output(self.operatorEnd)
		} else {
			fromMoneyLabel.text = numberFormat(self.fromMoney)
			toMoneyLabel.text = self.output(self.fromMoney)
		}
	}
	
	func flash(button: UIButton) {
		let originBackgroundColor: UIColor = button.backgroundColor!
		UIView.animate(withDuration: 0.2) {
			button.backgroundColor = UIColor.hex("646464")
			UIView.animate(withDuration: 0.2) {
				button.backgroundColor = originBackgroundColor
			}
		}
	}
	
	func exec() {
		var newResult: Float = 0
		
		switch self.operatorSymbol {
		case "÷":
			newResult = (self.fromMoney as NSString).floatValue / (self.operatorEnd as NSString).floatValue
		case "×":
			newResult = (self.fromMoney as NSString).floatValue * (self.operatorEnd as NSString).floatValue
		case "+":
			newResult = (self.fromMoney as NSString).floatValue + (self.operatorEnd as NSString).floatValue
		case "-":
			newResult = (self.fromMoney as NSString).floatValue - (self.operatorEnd as NSString).floatValue
		default:
			print("Unknow operator symbol: \(self.operatorSymbol)")
		}
		
		self.fromMoney = "\(newResult)"
	}
	
	@objc func onSettingsClick() {
		let url: URL = URL.init(string: "currencyconverter://settings")!
		self.extensionContext?.open(url)
	}
	
	@objc func onCurrencyPickerClick(_ recognizer: UILongPressGestureRecognizer) {
        let button: UIButton = recognizer.view as! UIButton
		let type = button.tag == 1 ? "from" : "to"
		let currency: String = button.tag == 1 ? self.fromSymbol : self.toSymbol
		let url: URL = URL.init(string: "currencyconverter://currencypicker/\(type)/\(currency)")!
		self.extensionContext?.open(url)
	}
	
	// 格式化输出换算结果
	func output(_ money:String) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		let customRate: Float = shared?.float(forKey: "customRate") ?? 1.0
		let decimals = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		let rate: Float = isCustomRate ? customRate : self.rate
		
		return numberFormat(String(Float(money)! * rate), maximumFractionDigits: decimals)
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func numberFormat(_ s:String, maximumFractionDigits: Int = 20) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
		var price: NSNumber = 0
		if let myInteger = Double(s) {
			price = NSNumber(value:myInteger)
		}
		//创建一个NumberFormatter对象
		let numberFormatter = NumberFormatter()
		//设置number显示样式
		numberFormatter.numberStyle = .decimal  // 小数形式
		numberFormatter.usesGroupingSeparator = usesGroupingSeparator //设置用组分隔
		numberFormatter.maximumFractionDigits = maximumFractionDigits //设置小数点后最多3位
		
		//格式化
		let format = numberFormatter.string(from: price)!
		return format
	}
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
