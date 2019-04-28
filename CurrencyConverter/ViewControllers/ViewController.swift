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
	
	// 当前输入货币是否为空
	var isEmpty: Bool = true
	
	// 当前运算符
	var operatorSymbol:String = ""
	
	var operatorButton:UIButton!
	
	// 被操作的数
	var operatorEnd:String = "0"
	
	// 输入货币数量
	var fromMoney: String = "0"
	
	// 汇率
	var rate: Float = 6.777
	
	var rates: [String: [String: NSNumber]]!
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	// 缓存收藏的货币
	var fromFavorites: [String]!
	var toFavorites: [String]!
	
	var fromControllers: [Int: [String: Any]] = [:]
	var toControllers: [Int: [String: Any]] = [:]

	var currencyPickerType: CurrencyPickerType = CurrencyPickerType.from
	
	// UI 组件
	var fromScrollView: UIScrollView!
	var toScrollView: UIScrollView!
	var settingsView: UIView!
	var fromScreenView: UIView!
	var toScreenView: UIView!
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
	
	//键盘距离顶部的间距
	var PADDING_BOTTOM: CGFloat = 20
	
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
				print("update rate success!")
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
				print("Update rate failed.")
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
		
		if self.rates != nil {
			self.setRate()
		}
		
		let favorites: [String] = shared?.array(forKey: "favorites") as! [String]
		fromFavorites = favorites.filter { (symbol) -> Bool in
			return symbol != self.fromSymbol
		}
		fromFavorites.insert(self.fromSymbol, at: 0)
		
		toFavorites = favorites.filter { (symbol) -> Bool in
			return symbol != self.toSymbol
		}
		toFavorites.insert(self.toSymbol, at: 0)
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		let rates = shared?.object(forKey: "rates") as? Dictionary<String, NSNumber>

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
	
	func render() {
		self.view.backgroundColor = UIColor.appBackgroundColor
		
		renderScreen()
		renderKeyboard()
	}
	
	func observe() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidUserDefaultsChange), name: .didUserDefaultsChange, object: nil)
	}
	
	func renderScreen() {
		let screenViewPadding: CGFloat = 16
		let screenViewWidth: CGFloat = UIScreen.main.bounds.width - 2 * screenViewPadding
		let screenViewHeight: CGFloat = 200
		let screenViewY: CGFloat = UIScreen.main.bounds.height - UIScreen.main.bounds.width - screenViewHeight - PADDING_BOTTOM
		
		// 创建屏幕容器
		let screenView = UIView()
		// 坐标
		screenView.frame = CGRect(x: screenViewPadding, y: screenViewY, width: screenViewWidth, height: screenViewHeight)
		// 是否切除子视图超出部分
		screenView.clipsToBounds = true
		//screenView.backgroundColor = UIColor.red
		// 添加到当前视图控制器
		self.view.addSubview(screenView)
		
		fromScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenView.frame.width, height: screenView.frame.height/2)) // Frame属性
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

		for (seq, symbol) in fromFavorites.enumerated() {
			let page = UIView(frame: CGRect(x: CGFloat(seq) * fromScrollView.frame.width, y: 0, width: fromScrollView.frame.width, height: fromScrollView.frame.height))
			//page.backgroundColor = UIColor.green
			fromScrollView.addSubview(page)
			
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
	
			// 货币输入框
			let fromMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: fromScrollView.frame.width - symbolButtonWidth, height: moneyLabelHeight))
			fromMoneyLabel.font = UIFont(name: Config.numberFontName, size: 72)
			fromMoneyLabel.adjustsFontSizeToFitWidth = true
			fromMoneyLabel.textAlignment = .right
			fromMoneyLabel.text = numberFormat(self.fromMoney)
			fromMoneyLabel.textColor = UIColor.gray
			page.addSubview(fromMoneyLabel)
	
			// 输入货币符号容器
			let fromSymbolButton = UIButton(frame: CGRect(x: fromMoneyLabel.frame.width + symbolButtonPaddingLeft, y: 0, width: symbolButtonWidth, height: symbolButtonHeight))
			fromSymbolButton.tag = 1
			fromSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
			page.addSubview(fromSymbolButton)
	
			// 输入货币国旗
			let fromImageView = UIImageView(frame: CGRect(x: 0, y: flagPaddingTop, width: flagWidth, height: flagHeight))
			fromImageView.alpha = 0.5
			fromSymbolButton.addSubview(fromImageView)
			if let fromFlagPath = Bundle.main.path(forResource: symbol, ofType: "png") {
				fromImageView.image = UIImage(contentsOfFile: fromFlagPath)
			}
	
			// 输入货币缩写标签
			let fromSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: symbolLabelWidth, height: symbolLabelHeight))
			fromSymbolLabel.text = symbol
			fromSymbolLabel.textAlignment = .center
			fromSymbolLabel.font = UIFont.systemFont(ofSize: 16)
			fromSymbolLabel.textColor = UIColor.gray
			fromSymbolButton.addSubview(fromSymbolLabel)

			// 将组件和类关联
			if self.fromSymbol == symbol {
				self.fromMoneyLabel = fromMoneyLabel
				self.fromSymbolLabel = fromSymbolLabel
				self.fromImageView = fromImageView
			}
			
			fromControllers[seq] = [
				"moneyLabel": fromMoneyLabel,
				"symbolLabel": fromSymbolLabel,
				"imageView": fromImageView
			]
		}
		
		toScrollView = UIScrollView(frame: CGRect(x: 0, y: screenView.frame.height/2, width: screenView.frame.width, height: screenView.frame.height/2)) // Frame属性
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
		
		for (seq, symbol) in toFavorites.enumerated() {
			let page = UIView(frame: CGRect(x: CGFloat(seq) * toScrollView.frame.width, y: 0, width: toScrollView.frame.width, height: toScrollView.frame.height))
			//page.backgroundColor = UIColor.green
			toScrollView.addSubview(page)
			
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
			
			// 货币输入框
			let toMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: toScrollView.frame.width - symbolButtonWidth, height: moneyLabelHeight))
			toMoneyLabel.font = UIFont(name: Config.numberFontName, size: 72)
			toMoneyLabel.adjustsFontSizeToFitWidth = true
			toMoneyLabel.textAlignment = .right
			toMoneyLabel.text = numberFormat(self.fromMoney)
			toMoneyLabel.textColor = UIColor.white
			page.addSubview(toMoneyLabel)
			
			// 输入货币符号容器
			let toSymbolButton = UIButton(frame: CGRect(x: toMoneyLabel.frame.width + symbolButtonPaddingLeft, y: 0, width: symbolButtonWidth, height: symbolButtonHeight))
			toSymbolButton.tag = 2
			toSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
			page.addSubview(toSymbolButton)
			
			// 输入货币国旗
			let toImageView = UIImageView(frame: CGRect(x: 0, y: flagPaddingTop, width: flagWidth, height: flagHeight))
			toSymbolButton.addSubview(toImageView)
			if let toFlagPath = Bundle.main.path(forResource: symbol, ofType: "png") {
				toImageView.image = UIImage(contentsOfFile: toFlagPath)
			}
			
			// 输入货币缩写标签
			let toSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: symbolLabelWidth, height: symbolLabelHeight))
			toSymbolLabel.text = symbol
			toSymbolLabel.textAlignment = .center
			toSymbolLabel.font = UIFont.systemFont(ofSize: 16)
			toSymbolLabel.textColor = UIColor.white
			toSymbolButton.addSubview(toSymbolLabel)
			
			// 将组件和类关联
			if self.toSymbol == symbol {
				self.toMoneyLabel = toMoneyLabel
				self.toSymbolLabel = toSymbolLabel
				self.toImageView = toImageView
			}
			
			toControllers[seq] = [
				"moneyLabel": toMoneyLabel,
				"symbolLabel": toSymbolLabel,
				"imageView": toImageView
			]
		}
		
//		let subScreenViewPaddingLeft: CGFloat = 16
//		let subScreenViewHeight: CGFloat = screenViewHeight / 2
//
//		self.fromScreenView = UIView(frame: CGRect(x: subScreenViewPaddingLeft, y: 0, width: screenView.frame.width - subScreenViewPaddingLeft, height: subScreenViewHeight))
//		screenView.addSubview(self.fromScreenView)
//		self.toScreenView = UIView(frame: CGRect(x: subScreenViewPaddingLeft, y: subScreenViewHeight, width: screenView.frame.width - subScreenViewPaddingLeft, height: subScreenViewHeight))
//		screenView.addSubview(self.toScreenView)
//
//		//国旗图片尺寸
//		let flagWidth: CGFloat = 40
//		let flagHeight: CGFloat = 30
//		let flagPaddingTop: CGFloat = 12
//
//		let symbolLabelWidth: CGFloat = flagWidth
//		let symbolLabelHeight: CGFloat = 20
//		let symbolLabelPaddingTop: CGFloat = 5
//
//
//		//货币容器按钮尺寸
//		let symbolButtonWidth: CGFloat = 70
//		let symbolButtonHeight: CGFloat = flagHeight + symbolLabelHeight
//		let symbolButtonPaddingLeft: CGFloat = (symbolButtonWidth - flagWidth) / 2
//
//		let moneyLabelHeight: CGFloat = 80
//
//
//		// 货币输入框
//		fromMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: fromScreenView.frame.width - symbolButtonWidth, height: moneyLabelHeight))
//		fromMoneyLabel.font = UIFont(name: Config.numberFontName, size: 72)
//		fromMoneyLabel.adjustsFontSizeToFitWidth = true
//		fromMoneyLabel.textAlignment = .right
//		fromMoneyLabel.text = numberFormat(self.fromMoney)
//		fromMoneyLabel.textColor = UIColor.gray
//		fromScreenView.addSubview(fromMoneyLabel)
//
//		// 输入货币符号容器
//		fromSymbolButton = UIButton(frame: CGRect(x: fromMoneyLabel.frame.width + symbolButtonPaddingLeft, y: 0, width: symbolButtonWidth, height: symbolButtonHeight))
//		fromSymbolButton.tag = 1
//		fromSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
//		fromScreenView.addSubview(fromSymbolButton)
//
//		// 输入货币国旗
//		fromImageView = UIImageView(frame: CGRect(x: 0, y: flagPaddingTop, width: flagWidth, height: flagHeight))
//		fromImageView.alpha = 0.5
//		fromSymbolButton.addSubview(fromImageView)
//		if let fromFlagPath = Bundle.main.path(forResource: self.fromSymbol, ofType: "png") {
//			fromImageView.image = UIImage(contentsOfFile: fromFlagPath)
//		}
//
//		// 输入货币缩写标签
//		fromSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: symbolLabelWidth, height: symbolLabelHeight))
//		fromSymbolLabel.text = self.fromSymbol
//		fromSymbolLabel.textAlignment = .center
//		fromSymbolLabel.font = UIFont.systemFont(ofSize: 16)
//		fromSymbolLabel.textColor = UIColor.gray
//		fromSymbolButton.addSubview(fromSymbolLabel)
//
//		// 货币输出框
//		toMoneyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: toScreenView.frame.width - symbolButtonWidth, height: moneyLabelHeight))
//		toMoneyLabel.font = UIFont(name: Config.numberFontName, size: 72)
//		toMoneyLabel.adjustsFontSizeToFitWidth = true
//		toMoneyLabel.textAlignment = .right
//		toMoneyLabel.text = self.output(self.fromMoney)
//		toMoneyLabel.textColor = UIColor.white
//		// 允许响应用户交互（长按出现copy）
//		toMoneyLabel.isUserInteractionEnabled = true
//		let longPress = UILongPressGestureRecognizer(target:self, action: #selector(toMoneyLongPress(_:)))
//		toMoneyLabel.addGestureRecognizer(longPress)
//		toScreenView.addSubview(toMoneyLabel)
//
//		// 输出货币符号容器
//		toSymbolButton = UIButton(frame: CGRect(x: toMoneyLabel.frame.width + symbolButtonPaddingLeft, y: 0, width: symbolButtonWidth, height: symbolButtonHeight))
//		toSymbolButton.tag = 2
//		toSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
//		toScreenView.addSubview(toSymbolButton)
//
//		// 输出货币国旗
//		toImageView = UIImageView(frame: CGRect(x: 0, y: flagPaddingTop, width: flagWidth, height: flagHeight))
//		toSymbolButton.addSubview(toImageView)
//		if let toFlagPath = Bundle.main.path(forResource: self.toSymbol, ofType: "png") {
//			toImageView.image = UIImage(contentsOfFile: toFlagPath)
//		}
//
//		// 创建输出货币缩写标签
//		toSymbolLabel = UILabel(frame: CGRect(x: 0, y: flagPaddingTop + flagHeight + symbolLabelPaddingTop, width: symbolLabelWidth, height: symbolLabelHeight))
//		toSymbolLabel.textAlignment = .center
//		toSymbolLabel.font = UIFont.systemFont(ofSize: 16)
//		toSymbolLabel.textColor = UIColor.white
//		toSymbolLabel.text = self.toSymbol
//		if isCustomRate {
//			toSymbolLabel.text = self.toSymbol + "*"
//		}
//		toSymbolButton.addSubview(toSymbolLabel)
//
		let swipeUp = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
		swipeUp.direction = .up
		screenView.addGestureRecognizer(swipeUp)

		let swipeDown = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
		swipeDown.direction = .down
		screenView.addGestureRecognizer(swipeDown)
	}
	
	func renderKeyboard() {
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		// 创建键盘容器
		let keyboardView = UIView()
		self.keyboardView = keyboardView
		// 坐标
		keyboardView.frame = CGRect(x: 0, y: viewBounds.height - viewBounds.width - PADDING_BOTTOM, width: viewBounds.width, height: viewBounds.width)
		// 背景颜色
		// keyboardView.backgroundColor = UIColor.yellow
		// 是否切除子视图超出部分
		keyboardView.clipsToBounds = true
		// 添加到当前视图控制器
		self.view.addSubview(keyboardView)
		
		let buttonWidth = (keyboardView.frame.size.width - 50) / 4
		let buttonPadding:CGFloat = 10
		
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % 4) + buttonPadding, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/4))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name: Config.numberFontName, size:32)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			
			switch item {
			case "=", "+", "-", "AC":
				btn.setBackgroundColor(color: UIColor.loquatYellow, forState: .normal)
				btn.setBackgroundColor(color: UIColor.hex("fbd5aa"), forState: .highlighted)
				btn.setBackgroundColor(color: UIColor.hex("fefefe"), forState: .selected)
				btn.setTitleColor(UIColor.hex("fb9601"), for: .selected)
			case "A":
				btn.setBackgroundColor(color: UIColor.hex("2c2c2c"), forState: .normal)
				btn.titleLabel?.font = UIFont(name:"CurrencyConverter", size:32)
			default:
				btn.setBackgroundColor(color: UIColor.hex("424242"), forState: .normal)
				btn.setBackgroundColor(color: UIColor.hex("646464"), forState: .highlighted)
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
			UIView.animate(withDuration: 0.5, animations: {
				self.fromScrollView.frame.origin.y = 100
				self.toScrollView.frame.origin.y = 0
			}, completion: {
				(finished:Bool) -> Void in
				
				let fromSymbol: String = self.toSymbol
				let toSymbol: String = self.fromSymbol
				//let newToMoney: String = self.fromMoney
				//反向计算得到原始toMoney
				let newFromMoney: String = String(Float(self.fromMoney)! * self.rate)
				//更新界面
				self.fromScrollView.frame.origin.y = 0
				self.toScrollView.frame.origin.y = 100
				//fromMoney没有缓存，不能通过UserDefaults事件来派发
				self.fromMoney = newFromMoney
				self.fromMoneyLabel.text = self.numberFormat(newFromMoney)

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
			self.fromMoney = "0"
			self.operatorEnd = "0"
			self.operatorSymbol = ""
		case "A":
			self.onSettingsClick(sender)
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
			fromMoneyLabel.text = numberFormat(self.operatorEnd)
			toMoneyLabel.text = self.output(self.operatorEnd)
		} else {
			fromMoneyLabel.text = numberFormat(self.fromMoney)
			toMoneyLabel.text = self.output(self.fromMoney)
		}
		
		self.playTapSound()
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
				print("Could not load audio file.")
			}
		}
	}
	
	@objc func onSettingsClick(_ sender: UIButton) {
//		let settingsView = SettingsViewController()
//		self.present(settingsView, animated: true, completion: nil)
		
//		let settingsView = STC()
//		self.present(settingsView, animated: true, completion: nil)
		self.performSegue(withIdentifier: "showSettingsSegue", sender: nil)
	}
	
	
	@objc func onSettingsDone(_ sender: UIButton) {
		UIView.animate(withDuration: 0.5, animations: {
			self.settingsView.frame.origin.y = UIScreen.main.bounds.height
		}, completion: nil)
	}
	
	@objc func toMoneyLongPress(_ recognizer: UILongPressGestureRecognizer) {
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
		let rate = isCustomRate ? customRate : self.rate
		
		return numberFormat(String(Float(money)! * rate))
	}
	
	func registerSettingsBundle() {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.register(defaults: Config.defaults)
	}
	
	//把 "1234567.89" -> "1,234,p567.89"
	func numberFormat(_ s:String) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
		let decimals = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		var price: NSNumber = 0
		if let myInteger = Double(s) {
			price = NSNumber(value:myInteger)
		}
		//创建一个NumberFormatter对象
		let numberFormatter = NumberFormatter()
		//设置number显示样式
		numberFormatter.numberStyle = .decimal  // 小数形式
		numberFormatter.usesGroupingSeparator = usesGroupingSeparator //设置用组分隔
		//numberFormatter.groupingSeparator = "," //分隔符号
		//numberFormatter.groupingSize = 4  //分隔位数
		
		numberFormatter.maximumFractionDigits = decimals //设置小数点后最多3位
		//numberFormatter.minimumFractionDigits = 5 //设置小数点后最少2位（不足补0）
		
		//numberFormatter.positivePrefix = "$" //自定义前缀
		//numberFormatter.positiveSuffix = "元" //自定义后缀
		
		//numberFormatter.locale = Locale(identifier: "fa_IR")
		//numberFormatter.locale = Locale(identifier: "ar_EG")
		//numberFormatter.locale = Locale(identifier: "cs_CZ")
		//numberFormatter.locale = Locale(identifier: "de_DE")
		
		//格式化
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
			}
			
			if data.keys.contains("toSymbol") {
				let symbol: String = data["toSymbol"] as! String
				self.toSymbolLabel.text = symbol
				if let path = Bundle.main.path(forResource: symbol, ofType: "png") {
					toImageView.image = UIImage(contentsOfFile: path)
				}
				self.toSymbol = symbol
				self.setRate()
			}
			
			if data.keys.contains("isCustomRate") || data.keys.contains("decimals") || data.keys.contains("usesGroupingSeparator") || data.keys.contains("fromSymbol") || data.keys.contains("toSymbol") {
				DispatchQueue.main.async {
					self.toMoneyLabel.text = self.output(self.fromMoney)
				}
			}
		}
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
			print("toControllers:", toControllers)
			let controllers = toControllers[page]
			self.toSymbol = newSymbol
			self.toMoneyLabel = controllers?["moneyLabel"] as? UILabel
			self.toSymbolLabel = controllers?["symbolLabel"] as? UILabel
			self.toImageView = controllers?["imageView"] as? UIImageView
		}
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"\(type)Symbol": newSymbol,
			"isCustomRate": false
		])
	}
}



