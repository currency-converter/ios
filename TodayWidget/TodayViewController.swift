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
    
    // 当前是否为计算结果
    var isResult: Bool = false
	
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
    
    var zero: String = NumberFormatter().string(from: 0)!
	
	// 当前运算符
	var operatorSymbol:String = ""
	
	var operatorButton:UIButton!
	
    // 左操作数真实值
    var leftOperand: String = "0"
    // 左操作数显示值
    var leftOperandDisplayValue: String = NumberFormatter().string(from: 0)!
    
    // 右操作数真实值
    var rightOperand: String = ""
    // 右操作数显示值
    var rightOperandDisplayValue: String = ""
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	// 是否为收起模式
	var isCompact: Bool = true
	
    // 汇率
    var rate: Float = 6.777
	
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
	var compactHeight: CGFloat!
	var wrapperWidth: CGFloat!
	var wrapperHeight: CGFloat!
	//货币数字字体大小
	let expandedMoneyFontSize: CGFloat = 50

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
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.register(defaults: Config.defaults)
	}
	
	func clearViews() {
		for v in self.view.subviews as [UIView] {
			v.removeFromSuperview()
		}
	}
	
	func initConfig() {
		self.wrapperWidth = (self.extensionContext?.widgetMaximumSize(for: .compact).width ?? 0) - self.expandedPadding * 2
		self.compactHeight = self.extensionContext?.widgetMaximumSize(for: .compact).height
		self.expandedHeight = self.expandedSymbolHeight * 2 + self.expandedKeyboardMarginTop + self.wrapperWidth + self.expandedPadding * 2

		let widgetMaxHeight: CGFloat = (self.extensionContext?.widgetMaximumSize(for: .expanded).height)!
		if UIDevice.current.userInterfaceIdiom == .pad && widgetMaxHeight == 616 {
			// iPad air & iPad air2 & iPad pro (9.7-inch) 组件高度不能超过616
			self.expandedHeight = widgetMaxHeight
		}
		self.wrapperHeight = self.expandedHeight - self.expandedPadding * 2
        
        let shared = UserDefaults(suiteName: Config.groupId)
        self.fromSymbol = shared?.string(forKey: "fromSymbol")
        self.toSymbol = shared?.string(forKey: "toSymbol")
        self.rates = shared?.object(forKey: "rates") as? [String: [String: NSNumber]]
        
        if self.rates != nil {
            self.setRate()
        }
	}
    
    func setRate() {
        let fromRate: Float! = Float(truncating: (rates![self.fromSymbol]! as [String: NSNumber])["a"]!)
        let toRate: Float! = Float(truncating: (rates![self.toSymbol]! as [String: NSNumber])["a"]!)
        self.rate = toRate/fromRate
    }
	
	func renderCompactMode() {
		let shared = UserDefaults(suiteName: Config.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		
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
		
		let symbolHeight: CGFloat = 15
		let symbolWidth: CGFloat = 40
		
		let moneyLabelMarginLeft: CGFloat = 5
		
		//键盘宽度
		let keyboardWidth: CGFloat = self.view.frame.width - screenWidth - margin * 3
		let keyboardHeight: CGFloat = screenHeight
		
		let screen: UIView = UIView(frame: CGRect(x: margin, y: margin, width: screenWidth, height: screenHeight))
		if isDebug {
			screen.backgroundColor = UIColor.red
		}
		self.view.addSubview(screen)
		
		let fromScreen: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth, height: subScreenHeight))
		fromScreen.tag = 1
//		fromScreen.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		if isDebug {
			fromScreen.backgroundColor = UIColor.green
		}
		screen.addSubview(fromScreen)
		
		let toScreen: UIButton = UIButton(frame: CGRect(x: 0, y: subScreenHeight + screenMargin, width: screenWidth, height: subScreenHeight))
		toScreen.tag = 2
//		toScreen.addTarget(self, action: #selector(onCurrencyPickerClick(_:)), for: .touchDown)
		if isDebug {
			toScreen.backgroundColor = UIColor.yellow
		}
		screen.addSubview(toScreen)
		
		let fromSymbol = UIButton(frame: CGRect(x: 0, y: 0, width: symbolWidth, height: symbolHeight))
		fromSymbol.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
		fromSymbol.setTitle(self.fromSymbol, for: .normal)
		fromSymbol.setTitleColor(UIColor.black, for: .normal)
		fromSymbol.contentHorizontalAlignment = .left
		fromScreen.addSubview(fromSymbol)

		fromMoneyLabel = UILabel(frame: CGRect(x: moneyLabelMarginLeft, y: symbolHeight, width: fromScreen.frame.width - moneyLabelMarginLeft, height: subScreenHeight - symbolHeight))
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		fromMoneyLabel.textColor = self.fromMoneyLabelTextColor[self.isEmpty ? 0 : 1]
		fromMoneyLabel.font = UIFont.boldSystemFont(ofSize: 18)
		fromMoneyLabel.text = self.leftOperandDisplayValue
		fromScreen.addSubview(fromMoneyLabel)

		let toSymbol = UIButton(frame: CGRect(x: 0, y: 0, width: symbolWidth, height: symbolHeight))
		toSymbol.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
		toSymbol.setTitle(self.toSymbol + (isCustomRate ? "*" : ""), for: .normal)
		toSymbol.setTitleColor(UIColor.black, for: .normal)
		toSymbol.contentHorizontalAlignment = .left
		toScreen.addSubview(toSymbol)

		toMoneyLabel = UILabel(frame: CGRect(x: moneyLabelMarginLeft, y: symbolHeight, width: fromScreen.frame.width - moneyLabelMarginLeft, height: subScreenHeight - symbolHeight))
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		toMoneyLabel.textColor = self.toMoneyLabelTextColor[self.isEmpty ? 0 : 1]
		toMoneyLabel.font = UIFont.boldSystemFont(ofSize: 18)
		toMoneyLabel.text = self.output(self.leftOperand)
		toScreen.addSubview(toMoneyLabel)
		
		let keyboard = UIView(frame: CGRect(x: screenWidth + margin * 2, y: margin, width: keyboardWidth, height: keyboardHeight))
		keyboard.clipsToBounds = true
		if isDebug {
			keyboard.backgroundColor = UIColor.blue
		}
		self.view.addSubview(keyboard)
		
		//每行显示按钮个数
		let numberOfButtonsPerLine: CGFloat = 6
		//按钮左右间距
		let buttonMarginLeft: CGFloat = 5
		let buttonMarginTop: CGFloat = 1
		//按钮宽度
		let buttonWidth: CGFloat = (keyboard.frame.width - buttonMarginLeft * (numberOfButtonsPerLine - 1)) / numberOfButtonsPerLine
		let buttonHeight: CGFloat = subScreenHeight - buttonMarginTop
		let characters:[String] = ["4", "5", "6", "7", "8", "9", "0", "1", "2", "3", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			let columnIndex: CGFloat = CGFloat(index % Int(numberOfButtonsPerLine))
			let x: CGFloat = (buttonWidth + buttonMarginLeft) * columnIndex
			let y: CGFloat = index < Int(numberOfButtonsPerLine) ? 0 : subScreenHeight + buttonMarginTop
			let btn: UIButton = UIButton.init(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight))
			btn.layer.cornerRadius = 5
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.backgroundColor = UIColor.hex("2c2c2c")
            btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
            btn.accessibilityHint = item
            
			if item == "AC" {
				btn.backgroundColor = UIColor.hex("da8009")
                btn.setTitle(item, for: UIControl.State.normal)
            } else if item == "." {
                btn.setTitle(NumberFormatter().decimalSeparator, for: UIControl.State.normal)
            } else {
                btn.setTitle(numberFormat(item), for: UIControl.State.normal)
            }
			keyboard.addSubview(btn)
		}
	}
	
	func renderExpandedMode() {
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
		fromMoneyLabel.text = leftOperandDisplayValue
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
		toMoneyLabel.text = self.output(self.leftOperand)
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal  // 小数形式
        let decimalSeparator = String(numberFormatter.decimalSeparator)
		let characters:[Any] = [7, 8, 9, "AC", 4, 5, 6, "-", 1, 2, 3, "+", 0, ".", "A", "="]

		for (index, item) in characters.enumerated() {
			let columnIndex: CGFloat = CGFloat(index % 4)
			let x: CGFloat = (buttonWidth + expandedButtonMargin) * columnIndex
			let y: CGFloat = (buttonHeight + expandedButtonMargin) * CGFloat(floor(Double(index / 4)))
			let btn :UIButton = UIButton.init(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight))
			btn.layer.cornerRadius = min(buttonWidth, buttonHeight) / 2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name:"Avenir", size: 28)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
            
            if let stringItem = item as? String {
                // 如果元素是字符串类型,即功能按钮
                switch stringItem {
                case "+", "-", "=", "AC":
                    btn.backgroundColor = UIColor.hex("da8009")
                    btn.accessibilityHint = stringItem
                    btn.setTitle(stringItem, for: UIControl.State.normal)
                case "A":
                    btn.backgroundColor = UIColor.hex("2c2c2c")
                    btn.titleLabel?.font = UIFont(name: "CurrencyConverter", size: 28)
                    btn.accessibilityHint = stringItem
                    btn.setTitle(stringItem, for: UIControl.State.normal)
                default:
                    // 小数点
                    btn.backgroundColor = UIColor.hex("424242")
                    btn.accessibilityHint = "."
                    btn.setTitle(decimalSeparator, for: UIControl.State.normal)
                }
                
            } else if let numberItem = item as? Int {
                // 如果元素是整数类型，即数字按钮
                // 如果是阿拉伯语言需要转换为阿拉伯字符
                let numberFormatter = NumberFormatter()
                let format = numberFormatter.string(from: NSNumber(value: numberItem))!
                btn.setTitle(format, for: UIControl.State.normal)
                btn.accessibilityHint = String(numberItem)
                btn.backgroundColor = UIColor.hex("424242")
            }

			keyboard.addSubview(btn)
		}
	}
	
	@objc func onInput(_ sender: UIButton) {
        // 真实值
        let plainValue = sender.accessibilityHint!
        // 显示值
        let labelValue = sender.currentTitle!
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal  // 小数形式
        let decimalSeparator = String(numberFormatter.decimalSeparator)
		self.operatorButton?.backgroundColor = UIColor.hex("da8009")
		self.operatorButton?.setTitleColor(UIColor.white, for: .normal)
		
		switch plainValue {
		case "AC":
			self.flash(button: sender)
			self.isEmpty = true
            self.isResult = false
            self.leftOperand = "0"
			self.leftOperandDisplayValue = zero
            self.rightOperand = ""
            self.rightOperandDisplayValue = ""
			self.operatorSymbol = ""
		case "A":
			self.flash(button: sender)
			self.onSettingsClick()
		case "+", "-":
            if !self.isEmpty {
                sender.backgroundColor = UIColor.white
                sender.setTitleColor(UIColor.hex("da8009"), for: .normal)
                
                // 连加
                if self.rightOperand != "" {
                    self.exec()
                }
                if (isResult) {
                    isResult = false
                }
                self.operatorSymbol = plainValue
				self.operatorButton = sender
				sender.isSelected = true
			}
		case "=":
			self.flash(button: sender)
            if self.rightOperand != "" {
                self.exec()
            }
		case "0":
            if (!isResult) {
                if self.operatorSymbol == "" {
                    if !self.isEmpty {
                        self.leftOperand += "0"
                        self.leftOperandDisplayValue += zero
                    }
                } else {
                    if rightOperand != "0" {
                        self.rightOperand += "0"
                        self.rightOperandDisplayValue += zero
                    }
                }
            }
		case ".":
            if (!isResult) {
                if self.operatorSymbol == "" {
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
                } else {
                    if !self.rightOperand.contains(".") {
                        self.rightOperand += "."
                        self.rightOperandDisplayValue += decimalSeparator
                    }
                    if self.rightOperand.hasPrefix(".") {
                        self.rightOperand = "0\(self.rightOperand)"
                        self.rightOperandDisplayValue = zero + self.rightOperandDisplayValue
                    }
                }
            }
		default:
			self.flash(button: sender)
			
            if (!isResult) {
                if self.operatorSymbol == "" {
                    self.leftOperand = self.isEmpty ? plainValue : self.leftOperand + plainValue
                    self.leftOperandDisplayValue = self.isEmpty ? labelValue : self.leftOperandDisplayValue + labelValue
                    self.isEmpty = false
                } else {
                    self.rightOperand = self.rightOperand == "0" ? plainValue : self.rightOperand + plainValue
                    self.rightOperandDisplayValue = self.rightOperandDisplayValue == zero ? labelValue : self.rightOperandDisplayValue + labelValue
                }
            }
		}

        if self.operatorSymbol != "" && self.rightOperand != "" {
            fromMoneyLabel.text = self.rightOperandDisplayValue
            toMoneyLabel.text = self.output(self.rightOperand)
        } else {
            fromMoneyLabel.text = self.leftOperandDisplayValue
            toMoneyLabel.text = self.output(self.leftOperand)
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
            newResult = (self.leftOperand as NSString).floatValue / (self.rightOperand as NSString).floatValue
        case "×":
            newResult = (self.leftOperand as NSString).floatValue * (self.rightOperand as NSString).floatValue
        case "+":
            newResult = (self.leftOperand as NSString).floatValue + (self.rightOperand as NSString).floatValue
        case "-":
            newResult = (self.leftOperand as NSString).floatValue - (self.rightOperand as NSString).floatValue
        default:
            print("Unknow operator symbol: \(self.operatorSymbol)")
        }
        
        self.leftOperand = "\(newResult)"
        self.leftOperandDisplayValue = numberFormat(String(newResult))
        
        isResult = true
        
        self.operatorSymbol = ""
        self.rightOperand = ""
        self.rightOperandDisplayValue = ""
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
        if !money.isEmpty {
            let shared = UserDefaults(suiteName: Config.groupId)
            let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? false
            let customRate: Float = shared?.float(forKey: "customRate") ?? 1.0
            let rate = isCustomRate ? customRate : self.rate
            if let moneyNum = Float(money) {
                return numberFormat(String(moneyNum * rate))
            }
            return ""
        }
        return ""
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func numberFormat(_ s:String, minimumFractionDigits: Int = 0) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
        let decimals: Int = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		var price: NSNumber = 0
		if let myInteger = Double(s) {
			price = NSNumber(value:myInteger)
		}
        //创建一个NumberFormatter对象
        let numberFormatter = NumberFormatter()
        //设置number显示样式
        numberFormatter.numberStyle = .decimal  // 小数形式
        numberFormatter.usesGroupingSeparator = usesGroupingSeparator //设置用组分隔
        if ((minimumFractionDigits) != 0) {
            numberFormatter.minimumFractionDigits = min(minimumFractionDigits, decimals)
        }
        numberFormatter.maximumFractionDigits = decimals //设置保留小数点位数
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
