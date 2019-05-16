//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/2/25.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIScrollViewDelegate {
	
	// 调试开关
	var isDebug: Bool = false
	
	// 当前输入货币是否为空
	var isEmpty: Bool = true {
		didSet {
			let isChanged = oldValue != isEmpty
			if isChanged {
				self.fromMoneyLabel.textColor = self.isEmpty ?
					Theme.fromMoneyLabelEmptyTextColor[themeIndex] :
					Theme.fromMoneyLabelTextColor[themeIndex]
				self.toMoneyLabel.textColor = self.isEmpty ?
					Theme.toMoneyLabelEmptyTextColor[themeIndex] :
					Theme.toMoneyLabelTextColor[themeIndex]
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
	
	// 汇率
	var rate: Float = 6.777
	
	var rates: [String: [String: NSNumber]]!
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	// 缓存收藏的货币
	var fromFavorites: [String] = []
	var toFavorites: [String] = []
	
	var fromControllers: [Int: [String: Any]] = [:]
	var toControllers: [Int: [String: Any]] = [:]

	var currencyPickerType: CurrencyPickerType = CurrencyPickerType.from
	
	var themeIndex: Int!
	
	// UI 组件
	var screenView: UIView!
	var fromScrollView: UIScrollView!
	var toScrollView: UIScrollView!
	var settingsView: UIView!
	var keyboardView: UIView!
	var currencyPickerView: UIView!
	var fromSymbolButton: UIButton!
	var toSymbolButton: UIButton!
	var fromSymbolLabel: UILabel!
	var toSymbolLabel: UILabel!
	var fromImageView: UIImageView!
	var toImageView: UIImageView!
	var fromMoneyLabel: UILabel!
	var toMoneyLabel: UILabel!
	var tapSoundPlayer: AVAudioPlayer!
	
	var screenViewMarginTop: CGFloat = 0
	var screenViewHeight: CGFloat = 0
	var screenViewY: CGFloat = 0
	var keyboardViewHeight: CGFloat = 0
	var keyboardViewY: CGFloat = 0
	var numberButtonWidth: CGFloat = 0
	var numberButtonHeight: CGFloat = 0
	//按钮之间间隔
	let numberButtonPadding:CGFloat = 14
	//按钮列数
	let columnsNumber: CGFloat = 4
	//按钮行数
	let rowsNumber: CGFloat = 5
	//显示屏高度
	var SCREEN_VIEW_HEIGHT_MAX: CGFloat = 200
	var SCREEN_VIEW_HEIGHT_MIN: CGFloat = 150
	
	public func updateRate() {
		let newUrlString = Config.updateRateUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		// 创建请求配置
		let config = URLSessionConfiguration.default
		// 创建请求URL
		let url = URL(string: newUrlString!)
		// 创建请求实例
		let request = URLRequest(url: url!)
		// 创建请求Session
		let session = URLSession(configuration: config)
		// 创建请求任务
		let task = session.dataTask(with: request) { (data,response,error) in
			if(error == nil) {
				print("Rate update succeeded.")
				// 将json数据解析成字典
				let rates = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
				// 请求到数据
				if rates != nil {
					self.rates = rates as? [String: [String: NSNumber]]
				} else if self.rates == nil {
					// 从接口没更新到汇率，且当前汇率集合为空时，使用默认值
					// 防止闪退
					self.rates = Config.defaults["rates"] as? [String: [String: NSNumber]]
				}
				
				let now = Date().timeStamp
				//汇率更新后，需要主动更新app中正使用的汇率
				self.setRate()

				//更新缓存数据
				let shared = UserDefaults(suiteName: Config.groupId)
				shared?.set(now, forKey: "rateUpdatedAt")
				shared?.set(rates, forKey: "rates")
				NotificationCenter.default.post(name: .didUpdateRate, object: self, userInfo: ["error": 0])
			} else {
				print("Rate update failed.")
				NotificationCenter.default.post(name: .didUpdateRate, object: self, userInfo: ["error": 1])
			}
		}
		
		// 激活请求任务
		task.resume()
	}
	
	func initConfig() {
		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: Config.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol")
		self.toSymbol = shared?.string(forKey: "toSymbol")
		self.rates = shared?.object(forKey: "rates") as? [String: [String: NSNumber]]
		self.themeIndex = shared?.integer(forKey: "theme")
		
		if self.rates != nil {
			self.setRate()
		}
	}
	
	func initFavorites(type: String) {
		let shared = UserDefaults(suiteName: Config.groupId)
		let favorites: [String] = shared?.array(forKey: "favorites") as! [String]
		
		if type == "from" {
			fromFavorites.removeAll()
			fromFavorites = favorites.filter { (symbol) -> Bool in
				return symbol != self.fromSymbol
			}
			fromFavorites.insert(self.fromSymbol, at: 0)
		} else {
			toFavorites.removeAll()
			toFavorites = favorites.filter { (symbol) -> Bool in
				return symbol != self.toSymbol
			}
			toFavorites.insert(self.toSymbol, at: 0)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		IwatchSessionUtil.shareManager.sendMessageToWatch(key: "name", value: "Joe")
		
		registerSettingsBundle()
		
		createUpdateRateDaemon()

		initConfig()
		
		render()
		
		observe()
	}
	
	func isNeedUpdateRate() -> Bool {
		let shared = UserDefaults(suiteName: Config.groupId)
		let rateUpdatedAt: Int = shared?.integer(forKey: "rateUpdatedAt") ?? Config.defaults["rateUpdatedAt"] as! Int
		let rateUpdatedFrequency: String = shared?.string(forKey: "rateUpdatedFrequency") ?? Config.defaults["rateUpdatedFrequency"] as! String
		let autoUpdateRate = shared?.bool(forKey: "autoUpdateRate") ?? Config.defaults["autoUpdateRate"] as! Bool
		let rates = shared?.object(forKey: "rates") as? [String: [String: NSNumber]]

		return rates == nil ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.realtime.rawValue) ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.daily.rawValue && Date().diff(timestamp: rateUpdatedAt, unit: Date.unit.day) > 0) ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.hourly.rawValue && Date().diff(timestamp: rateUpdatedAt, unit: Date.unit.hour) > 0)
	}
	
	func setRate() {
		let fromRate: Float! = Float(truncating: (rates![self.fromSymbol]! as [String: NSNumber])["a"]!)
		let toRate: Float! = Float(truncating: (rates![self.toSymbol]! as [String: NSNumber])["a"]!)
		self.rate = toRate/fromRate
	}
	
	func createUpdateRateDaemon() {
		Timer.scheduledTimer(withTimeInterval: 3 * 60, repeats: true) { (start) in
			if self.isNeedUpdateRate() {
				self.updateRate()
			}
		}.fire()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		//显示前隐藏导航条
		self.navigationController?.isNavigationBarHidden = true
	}
	
	func getPosition() {
		//self.layout["marginBetweenScreenAndBoard"]
		let width: CGFloat = UIScreen.main.bounds.width
		let height: CGFloat = UIScreen.main.bounds.height
		let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			//高度不够，只能使用椭圆按钮
			self.keyboardViewHeight = height / 3 * 2
			self.screenViewHeight = height / 3
			self.screenViewY = statusBarHeight
			self.keyboardViewY = height - self.keyboardViewHeight
			self.numberButtonWidth = (width - self.numberButtonPadding * (self.columnsNumber + 1)) / self.columnsNumber
			self.numberButtonHeight = (self.keyboardViewHeight - self.numberButtonPadding * (self.rowsNumber + 1)) / self.rowsNumber
		} else {
			//竖屏
			self.keyboardViewHeight = width / self.columnsNumber * self.rowsNumber
			if height > self.keyboardViewHeight + statusBarHeight + self.SCREEN_VIEW_HEIGHT_MAX {
				//需要有间距
				self.screenViewHeight = self.SCREEN_VIEW_HEIGHT_MAX
				self.screenViewY = height - self.keyboardViewHeight - self.screenViewHeight
				self.numberButtonWidth = (width - self.numberButtonPadding * (self.columnsNumber + 1)) / self.columnsNumber
				self.numberButtonHeight = self.numberButtonWidth
				self.keyboardViewY = height - self.keyboardViewHeight
			} else {
				//没有间隙，但足够显示圆形按钮
				self.screenViewHeight = height - statusBarHeight - self.keyboardViewHeight
				self.screenViewY = statusBarHeight
				self.numberButtonWidth = (width - self.numberButtonPadding * (self.columnsNumber + 1)) / self.columnsNumber
				self.numberButtonHeight = self.numberButtonWidth
				self.keyboardViewY = height - self.keyboardViewHeight
			}
		}
	}
	
	func render() {
		self.view.backgroundColor = Theme.appBackgroundColor[themeIndex]
		self.navigationController?.navigationBar.barStyle = Theme.barStyle[themeIndex]
		UIApplication.shared.statusBarStyle = Theme.statusBarStyle[themeIndex]
		getPosition()
		renderScreen()
		renderKeyboard()
	}
	
	func observe() {
		//感知设备方向 - 开启监听设备方向
		if UIDevice.current.userInterfaceIdiom == .pad {
			UIDevice.current.beginGeneratingDeviceOrientationNotifications()
			//添加通知，监听设备方向改变
			NotificationCenter.default.addObserver(self, selector: #selector(self.onReceivedRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidUserDefaultsChange), name: .didUserDefaultsChange, object: nil)
	}
	
	func renderScreen() {
		let screenViewMarginLeft: CGFloat = 16
		let screenViewWidth: CGFloat = UIScreen.main.bounds.width - 2 * screenViewMarginLeft

		if screenView == nil {
			screenView = UIView(frame: CGRect(x: screenViewMarginLeft, y: screenViewY, width: screenViewWidth, height: screenViewHeight))
			screenView.clipsToBounds = true
			self.view.addSubview(screenView)
			
			let swipeUp = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
			swipeUp.direction = .up
			screenView.addGestureRecognizer(swipeUp)
			
			let swipeDown = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
			swipeDown.direction = .down
			screenView.addGestureRecognizer(swipeDown)
			
			if isDebug {
				screenView.backgroundColor = UIColor.cyan
			}
		}
		
		initFavorites(type: "from")

		fromScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenView.frame.width, height: screenView.frame.height/2))
		if isDebug {
			fromScrollView.backgroundColor = UIColor.red
		}
		fromScrollView.contentSize = CGSize(width: fromScrollView.frame.width * CGFloat(fromFavorites.count), height: fromScrollView.frame.height)
		//关闭滚动条显示
		fromScrollView.showsHorizontalScrollIndicator = false
		fromScrollView.showsVerticalScrollIndicator = false
		fromScrollView.scrollsToTop = false
		//协议代理，在本类中处理滚动事件
		fromScrollView.delegate = self
		fromScrollView.isPagingEnabled = true
		//fromScrollView.backgroundColor = .gray
		screenView.addSubview(fromScrollView)
		
		renderPagesInScrollView(type: "from")
		
		initFavorites(type: "to")

		toScrollView = UIScrollView(frame: CGRect(x: 0, y: screenView.frame.height/2, width: screenView.frame.width, height: screenView.frame.height/2))
		if isDebug {
			toScrollView.backgroundColor = UIColor.green
		}
		toScrollView.contentSize = CGSize(width: toScrollView.frame.width * CGFloat(toFavorites.count), height: toScrollView.frame.height)
		//关闭滚动条显示
		toScrollView.showsHorizontalScrollIndicator = false
		toScrollView.showsVerticalScrollIndicator = false
		toScrollView.scrollsToTop = false
		//协议代理，在本类中处理滚动事件
		toScrollView.delegate = self
		toScrollView.isPagingEnabled = true
		//toScrollView.backgroundColor = .gray
		screenView.addSubview(toScrollView)

		renderPagesInScrollView(type: "to")
	}
	
	func clear(_ view: UIView) {
		for subview in view.subviews as [UIView] {
			subview.removeFromSuperview()
		}
	}
	
	func renderPagesInScrollView(type: String) {
		var favorites: [String]
		var scrollView: UIScrollView
		var moneyLabelText: String
		var symbolButtonTag: Int
		var isCustomRate: Bool = Config.defaults["isCustomRate"] as! Bool
		let moneyLabelTextColor: UIColor = type == "from" ? Theme.fromMoneyLabelEmptyTextColor[themeIndex] : Theme.toMoneyLabelEmptyTextColor[themeIndex]
		
		let view: UIScrollView = type == "from" ? fromScrollView : toScrollView
		view.contentOffset.x = 0
		clear(view)
		
		if type == "from" {
			favorites = fromFavorites
			scrollView = fromScrollView
			moneyLabelText = numberFormat(fromMoney)
			symbolButtonTag = 1
			fromControllers.removeAll()
		} else {
			favorites = toFavorites
			scrollView = toScrollView
			moneyLabelText = output(fromMoney)
			symbolButtonTag = 2
			toControllers.removeAll()

			let shared = UserDefaults(suiteName: Config.groupId)
			isCustomRate = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		}
		
		for (seq, symbol) in favorites.enumerated() {
			let page = UIView(frame: CGRect(x: CGFloat(seq) * scrollView.frame.width, y: 0, width: scrollView.frame.width, height: scrollView.frame.height))
			scrollView.addSubview(page)
			
			//国旗图片尺寸
			let flagWidth: CGFloat = 40
			let flagHeight: CGFloat = 30
			let flagPaddingTop: CGFloat = 12
			
			let symbolLabelWidth: CGFloat = flagWidth
			let symbolLabelHeight: CGFloat = 20
			let symbolLabelPaddingTop: CGFloat = 5
			
			//货币容器按钮尺寸
			let symbolButtonWidth: CGFloat = 70
			let symbolButtonHeight: CGFloat = flagHeight + symbolLabelHeight
			let symbolButtonPaddingLeft: CGFloat = (symbolButtonWidth - flagWidth) / 2
			
			let moneyLabelHeight: CGFloat = 80
			let moneyLabelMarginTop: CGFloat = (self.screenView.frame.size.height/2 - moneyLabelHeight)/2
			
			// 货币输入框
			let moneyLabel = UILabel(frame: CGRect(x: 0, y: moneyLabelMarginTop, width: scrollView.frame.width - symbolButtonWidth, height: moneyLabelHeight))
			if isDebug {
				moneyLabel.backgroundColor = UIColor.yellow
			}
			moneyLabel.font = UIFont(name: Config.numberFontName, size: 72)
			moneyLabel.adjustsFontSizeToFitWidth = true
			moneyLabel.textAlignment = .right
			moneyLabel.text = moneyLabelText
			moneyLabel.textColor = moneyLabelTextColor
			moneyLabel.isUserInteractionEnabled = true
			let longPressGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction))
			moneyLabel.addGestureRecognizer(longPressGesture)
			page.addSubview(moneyLabel)
			
			// 货币符号容器
			let symbolButton = UIButton(frame: CGRect(x: moneyLabel.frame.width + symbolButtonPaddingLeft, y: moneyLabelMarginTop, width: symbolButtonWidth, height: symbolButtonHeight))
			symbolButton.tag = symbolButtonTag
			if isDebug {
				symbolButton.backgroundColor = UIColor.loquatYellow
			}
			symbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
			page.addSubview(symbolButton)
			
			// 货币国旗
			let flag = UIImageView(frame: CGRect(x: 0, y: flagPaddingTop, width: flagWidth, height: flagHeight))
			symbolButton.addSubview(flag)
			if let path = Bundle.main.path(forResource: symbol, ofType: "png") {
				flag.image = UIImage(contentsOfFile: path)
			}
			
			// 货币缩写标签
			let symbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: symbolLabelWidth, height: symbolLabelHeight))
			// 如果是自定义汇率则在目标货币符号后加星号
			symbolLabel.text = symbol + (type == "to"  && self.toSymbol == symbol && isCustomRate ? "*" : "")
			symbolLabel.textAlignment = .center
			symbolLabel.font = UIFont.systemFont(ofSize: 16)
			symbolLabel.textColor = Theme.fromMoneyLabelTextColor[themeIndex]
			symbolButton.addSubview(symbolLabel)
			
			// 将组件和类关联
			if type == "from" {
				if self.fromSymbol == symbol {
					self.fromMoneyLabel = moneyLabel
					self.fromSymbolLabel = symbolLabel
					self.fromImageView = flag
				}
				
				fromControllers[seq] = [
					"moneyLabel": moneyLabel,
					"symbolLabel": symbolLabel,
					"imageView": flag
				]
			} else {
				if self.toSymbol == symbol {
					self.toMoneyLabel = moneyLabel
					self.toSymbolLabel = symbolLabel
					self.toImageView = flag
				}
				
				toControllers[seq] = [
					"moneyLabel": moneyLabel,
					"symbolLabel": symbolLabel,
					"imageView": flag
				]
			}
		}
	}
	
	func renderKeyboard() {
		if keyboardView == nil {
			keyboardView = UIView(frame: CGRect(x: 0, y: self.keyboardViewY, width: UIScreen.main.bounds.width, height: self.keyboardViewHeight))
			if isDebug {
				keyboardView.backgroundColor = UIColor.blue
			}
			keyboardView.clipsToBounds = true
			self.view.addSubview(keyboardView)
		}
		
		let characters:[String] = [
			"AC", "A", "H", "÷",
			"7", "8", "9", "×",
			"4", "5", "6", "-",
			"1", "2", "3", "+",
			"0", ".", "G", "="
		]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			let btn:UIButton = UIButton.init(frame: CGRect(x:(self.numberButtonWidth + self.numberButtonPadding) * CGFloat(index % Int(self.columnsNumber)) + self.numberButtonPadding, y:(self.numberButtonHeight + self.numberButtonPadding) * CGFloat(floor(Double(index/4))) + self.numberButtonPadding, width: self.numberButtonWidth, height: self.numberButtonHeight))
			btn.layer.cornerRadius = self.numberButtonHeight/2
			btn.setTitleColor(Theme.numberButtonTextColor[themeIndex], for: .normal)
			btn.titleLabel?.font = UIFont(name: Config.numberFontName, size: 32)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			
			switch item {
			case "÷", "×", "+", "-", "=":
				btn.setBackgroundColor(color: UIColor.loquatYellow, forState: .normal)
				btn.setBackgroundColor(color: Theme.operatorButtonHighlightedBackgroundColor[themeIndex], forState: .highlighted)
				btn.setBackgroundColor(color: Theme.operatorButtonSelectedBackgroundColor[themeIndex], forState: .selected)
				btn.setTitleColor(Theme.operatorButtonSelectedTextColor[themeIndex], for: .selected)
			case "A", "G", "H":
				btn.titleLabel?.font = UIFont(name: "CurrencyConverter", size: 32)
				fallthrough
			case "AC":
				btn.setTitleColor(Theme.settingsButtonTextColor[themeIndex], for: .normal)
				btn.setBackgroundColor(color: Theme.settingsButtonBackgroundColor[themeIndex], forState: .normal)
			default:
				btn.setBackgroundColor(color: Theme.numberButtonBackgroundColor[themeIndex], forState: .normal)
				btn.setBackgroundColor(color: Theme.numberButtonHighlightedBackgroundColor[themeIndex], forState: .highlighted)
			}
			
			btn.setTitle(item, for: UIControl.State.normal)
			keyboardView.addSubview(btn)
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func swipe(_ recognizer: UISwipeGestureRecognizer) {
		if recognizer.direction == .up || recognizer.direction == .down {
			let offsetY = self.fromScrollView.frame.size.height
			UIView.animate(withDuration: 0.5, animations: {
				self.fromScrollView.frame.origin.y = offsetY
				self.toScrollView.frame.origin.y = 0
			}, completion: {
				(finished:Bool) -> Void in
				
				let fromSymbol: String = self.toSymbol
				let toSymbol: String = self.fromSymbol
				//let newToMoney: String = self.fromMoney
				//反向计算得到原始toMoney
				//let newFromMoney: String = String(Float(self.fromMoney)! * self.rate)
				//更新界面
				self.fromScrollView.frame.origin.y = 0
				self.toScrollView.frame.origin.y = offsetY
				//fromMoney没有缓存，不能通过UserDefaults事件来派发
				//self.fromMoney = newFromMoney
				//self.fromMoneyLabel.text = self.numberFormat(newFromMoney)

				//更新缓存
				let shared = UserDefaults(suiteName: Config.groupId)
				shared?.set(fromSymbol, forKey: "fromSymbol")
				shared?.set(toSymbol, forKey: "toSymbol")
				let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
				if isCustomRate {
					shared?.set(false, forKey: "isCustomRate")
				}
				
				NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
					"fromSymbol": fromSymbol,
					"toSymbol": toSymbol,
					"changeType": "swipe",
					"isCustomRate": false
				])
				
			})
		}
	}
	
	@objc func showCurrencyPicker(_ sender: UIButton) {
		var currencySymbol: String, currencyType: String
		
		if sender.tag == 1 {
			currencyType = CurrencyPickerType.from.rawValue
			currencySymbol = self.fromSymbol
		} else {
			currencyType = CurrencyPickerType.to.rawValue
			currencySymbol = self.toSymbol
		}
		
		let pickerView = CurrencyPickerViewController()
		pickerView.currencySymbol = currencySymbol
		pickerView.currencyType = currencyType
		self.present(pickerView, animated: true, completion: nil)
	}
	
	@objc func onInput(_ sender: UIButton) {
		let n = sender.currentTitle
		
		//清除+-的选中状态
		self.operatorButton?.isSelected = false
		
		switch n {
		case "AC":
			self.isEmpty = true
			self.fromMoney = "100"
			self.operatorEnd = "0"
			self.operatorSymbol = ""
		case "A":
			self.onSettingsClick(sender)
		case "G":
			self.copyMoney(sender)
		case "H":
			self.backspace()
		case "÷", "×", "+", "-":
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
			if self.operatorEnd != "0" {
				self.exec()
			}
			self.operatorSymbol = ""
			self.operatorEnd = "0"
		case "0":
			if self.operatorSymbol == "" {
				if self.isEmpty {
					self.fromMoney = "0"
					self.isEmpty = false
				} else {
					self.fromMoney += "0"
				}
			} else {
				if operatorEnd != "0" {
					self.operatorEnd += "0"
				}
			}
		case ".":
			if self.operatorSymbol == "" {
				if self.isEmpty {
					self.fromMoney = "0."
					self.isEmpty = false
				} else {
					if !self.fromMoney.contains(".") {
						self.fromMoney += "."
					}
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
			fromMoneyLabel.text = numberFormat(self.operatorEnd)
			toMoneyLabel.text = self.output(self.operatorEnd)
		} else {
			fromMoneyLabel.text = numberFormat(self.fromMoney)
			toMoneyLabel.text = self.output(self.fromMoney)
		}
		
		self.playTapSound()
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
	
	func backspace() {
		if self.operatorSymbol == "" && !self.isEmpty {
			let length = self.fromMoney.count
			self.fromMoney = length > 1 ? String(self.fromMoney.prefix(length - 1)) : "0"
		} else {
			let length = self.operatorEnd.count
			self.operatorEnd = length > 1 ? String(self.operatorEnd.prefix(length - 1)) : "0"
		}
	}
	
	func playTapSound() {
		let shared = UserDefaults(suiteName: Config.groupId)
		let isSounds: Bool = shared?.bool(forKey: "sounds") ?? Config.defaults["sounds"] as! Bool
		
		if isSounds {
			let path = Bundle.main.path(forResource: "Sounds/tap", ofType: "wav")!
			let url = URL(fileURLWithPath: path)
			
			do {
				try tapSoundPlayer = AVAudioPlayer(contentsOf: url)
				tapSoundPlayer.play()
			} catch {
				print("Failed to load audio file.")
			}
		}
	}
	
	@objc func onSettingsClick(_ sender: UIButton) {
		self.performSegue(withIdentifier: "showSettingsSegue", sender: nil)
	}
	
	
	@objc func onSettingsDone(_ sender: UIButton) {
		UIView.animate(withDuration: 0.5, animations: {
			self.settingsView.frame.origin.y = UIScreen.main.bounds.height
		}, completion: nil)
	}
	
	@objc func longPressAction(_ recognizer: UILongPressGestureRecognizer) {
		self.toMoneyLabel.becomeFirstResponder()
		let menu = UIMenuController.shared
		menu.arrowDirection = .down
		menu.menuItems = [ UIMenuItem.init(title: NSLocalizedString("home.copy", comment: ""), action: #selector(copyMoney(_:))) ]
		let rect = CGRect(x: self.toMoneyLabel.frame.width-50, y: 10, width: 50, height: 50)
		menu.setTargetRect(rect, in: self.toMoneyLabel)
		menu.setMenuVisible(true, animated: true)
	}

	@objc func copyMoney(_ sender: AnyObject?) {
		let paste = UIPasteboard.general
		paste.string = self.toMoneyLabel.text
	}
	
	override var canBecomeFirstResponder : Bool {
		return true
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if action == #selector(self.copyMoney) {
			return true
		}
		return false
	}
	
	// 格式化输出换算结果
	func output(_ money:String) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		let customRate: Float = shared?.float(forKey: "customRate") ?? 1.0
		let decimals = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		let rate = isCustomRate ? customRate : self.rate
		
		return numberFormat(String(Float(money)! * rate), maximumFractionDigits: decimals)
	}
	
	func registerSettingsBundle() {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.register(defaults: Config.defaults)
	}
	
	//把 "1234567.89" -> "1,234,p567.89"
	func numberFormat(_ s: String, maximumFractionDigits: Int = 20) -> String {
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
		let format = numberFormatter.string(from: price)!
		return format
	}
	
	@objc func onDidUserDefaultsChange(_ notification: Notification) {
		if let data = notification.userInfo as? [String: Any] {
			print("Notification data:", data)
			if data.keys.contains("isCustomRate") {
				let isCustomRate: Bool = data["isCustomRate"] as! Bool
				self.toSymbolLabel.text = self.toSymbol + (isCustomRate ? "*" : "")
			}
			
			if data.keys.contains("fromSymbol") {
				let symbol: String = data["fromSymbol"] as! String
				self.fromSymbolLabel.text = symbol
				if let path = Bundle.main.path(forResource: symbol, ofType: "png") {
					fromImageView.image = UIImage(contentsOfFile: path)
				}
				self.fromSymbol = symbol
				self.setRate()
				
				let changeType: String = data["changeType"] as! String
				if changeType != "scroll" {
					// 滑动切换货币时不需要更新界面
					initFavorites(type: "from")
					renderPagesInScrollView(type: "from")
				}
			}
			
			if data.keys.contains("toSymbol") {
				let symbol: String = data["toSymbol"] as! String
				self.toSymbolLabel.text = symbol
				if let path = Bundle.main.path(forResource: symbol, ofType: "png") {
					toImageView.image = UIImage(contentsOfFile: path)
				}
				self.toSymbol = symbol
				self.setRate()

				let changeType: String = data["changeType"] as! String
				if changeType != "scroll" {
					// 滑动切换货币时不需要更新界面
					initFavorites(type: "to")
					renderPagesInScrollView(type: "to")
				}
			}

			if data.keys.contains("favorites") {
				initFavorites(type: "from")
				renderPagesInScrollView(type: "from")
				initFavorites(type: "to")
				renderPagesInScrollView(type: "to")
			}
		
			if data.keys.contains("isCustomRate") || data.keys.contains("decimals") || data.keys.contains("usesGroupingSeparator") || data.keys.contains("fromSymbol") || data.keys.contains("toSymbol") {
				DispatchQueue.main.async {
					self.toMoneyLabel.text = self.output(self.fromMoney)
				}
			}
			
			if data.keys.contains("theme") {
				let themeIndex: Int = data["theme"] as! Int
				self.themeIndex = themeIndex
				self.view.backgroundColor = Theme.appBackgroundColor[themeIndex]
				renderPagesInScrollView(type: "from")
				renderPagesInScrollView(type: "to")
				
				clear(self.keyboardView)
				renderKeyboard()
			}
		}
	}
	
	@objc func onReceivedRotation() {
		DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
			self.clear(self.view)
			self.screenView = nil
			self.keyboardView = nil
			self.render()
		})
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		//根据scrollview实例类型判断滑动的货币类型
		let type: String = scrollView == fromScrollView ? "from" : "to"
		let favorites: [String] = scrollView == fromScrollView ? fromFavorites : toFavorites

		//通过scrollView内容的偏移计算当前显示的是第几页
		let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
		
		let newSymbol: String = favorites[page]
		
		if type == "from" {
			let controllers = fromControllers[page]
			self.fromSymbol = newSymbol
			self.fromMoneyLabel = controllers?["moneyLabel"] as? UILabel
			self.fromMoneyLabel?.text = numberFormat(self.fromMoney)
			self.fromSymbolLabel = controllers?["symbolLabel"] as? UILabel
			self.fromImageView = controllers?["imageView"] as? UIImageView
		} else {
			let controllers = toControllers[page]
			self.toSymbol = newSymbol
			self.toMoneyLabel = controllers?["moneyLabel"] as? UILabel
			self.toSymbolLabel = controllers?["symbolLabel"] as? UILabel
			self.toImageView = controllers?["imageView"] as? UIImageView
		}
		
		let key: String = "\(type)Symbol"
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(newSymbol, forKey: key)
		shared?.set(false, forKey: "isCustomRate")
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			key: newSymbol,
			"changeType": "scroll",
			"isCustomRate": false
		])
	}
}



