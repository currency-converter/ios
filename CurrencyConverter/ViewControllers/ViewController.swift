//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/2/25.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit
import AVFoundation

//定义协议
protocol CallbackDelegate {
	func onReady(key: String, value: String)
}

//protocol myDelegate {
//	func currencyCellClickCallback(data: String)
//}

//货币选择类型
enum CurrencyPickerType: String {
	case from
	case to
}

//汇率更新频率
enum RateUpdatedFrequency: String {
	case realtime = "0"
	case hourly = "1"
	case daily = "2"
}

//域名
let domain = "\u{71}\u{75}\u{6E}\u{61}\u{72}"

class ViewController: UIViewController {
	
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
	
	// 汇率
	var rate: Float = 6.777
	
	var rates: Dictionary<String,NSNumber>!
	
	// 输入货币类型
	var fromSymbol: String!
	
	// 输出货币类型
	var toSymbol: String!
	
	var currencyPickerType: CurrencyPickerType = CurrencyPickerType.from
	
	// api
	var updateRateUrl:String = "https://cc.beta.\(domain).com/api/rates?ios=1"
	
	var defaults:[String:Any] = [
		// 小数位数
		"decimals": 2,
		// 使用千位分隔符
		"usesGroupingSeparator": true,
		// 是否使用按键声音
		"sounds": false,
		"fromSymbol": "USD",
		"toSymbol": "CNY",
		"autoUpdateRate": true,
		"rateUpdatedFrequency": RateUpdatedFrequency.daily.rawValue,
		"rateUpdatedAt": 1554968594,
		"isCustomRate": false
	]
	
	// UI 组件
	var settingsView: UIView!
	var fromScreenView: UIView!
	var toScreenView: UIView!
	var keyboardView: UIView!
	var currencyPickerView: UIView!
	var fromSymbolButton: UIButton!
	var toSymbolButton: UIButton!
	var fromMoneyLabel: UILabel!
	var toMoneyLabel: UILabel!
	var tapSoundPlayer: AVAudioPlayer!
	var asteriskLabel: UILabel!
	
	//键盘距离顶部的间距
	var PADDING_BOTTOM: CGFloat = 20
	
	public func updateRate() {
		let newUrlString = self.updateRateUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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
				let now = Date().timeStamp

				//更新app正在使用的数据
				//self.rateUpdatedAt = now
				self.rates = rates as? Dictionary<String, NSNumber>
				//汇率更新后，需要主动更新app中正使用的汇率
				self.retrieveRate()

				//更新缓存数据
				let shared = UserDefaults(suiteName: self.groupId)
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
		let shared = UserDefaults(suiteName: self.groupId)
		self.fromSymbol = shared?.string(forKey: "fromSymbol")
		self.toSymbol = shared?.string(forKey: "toSymbol")
		
		self.rates = shared?.object(forKey: "rates") as? Dictionary<String, NSNumber>
		
		if self.rates != nil {
			let fromRate:Float! = rates[self.fromSymbol]?.floatValue
			let toRate:Float! = rates[self.toSymbol]?.floatValue
			self.rate = toRate/fromRate
		}
		
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
		let shared = UserDefaults(suiteName: self.groupId)
		let rateUpdatedAt: Int = shared?.integer(forKey: "rateUpdatedAt") ?? defaults["rateUpdatedAt"] as! Int
		let rateUpdatedFrequency: String = shared?.string(forKey: "rateUpdatedFrequency") ?? defaults["rateUpdatedFrequency"] as! String
		let autoUpdateRate = shared?.bool(forKey: "autoUpdateRate") ?? defaults["autoUpdateRate"] as! Bool
		let rates = shared?.object(forKey: "rates") as? Dictionary<String, NSNumber>

		return rates == nil ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.realtime.rawValue) ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.daily.rawValue && Date().diff(timestamp: rateUpdatedAt, unit: Date.unit.day) > 0) ||
			(autoUpdateRate && rateUpdatedFrequency == RateUpdatedFrequency.hourly.rawValue && Date().diff(timestamp: rateUpdatedAt, unit: Date.unit.hour) > 0)
	}
	
	func retrieveRate() {
		let fromRate: Float! = self.rates[self.fromSymbol]?.floatValue
		let toRate: Float! = self.rates[self.toSymbol]?.floatValue
		self.rate = toRate/fromRate
		print("self.rate:", self.rate)
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
		let shared = UserDefaults(suiteName: self.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? self.defaults["isCustomRate"] as! Bool
		
		let screenViewHeight: CGFloat = 200
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		// 创建屏幕容器
		let screenView = UIView()
		// 坐标
		screenView.frame = CGRect(x: 0, y: viewBounds.height - viewBounds.width - screenViewHeight - PADDING_BOTTOM, width: viewBounds.width, height: screenViewHeight)
		// 是否切除子视图超出部分
		screenView.clipsToBounds = true
		// 添加到当前视图控制器
		self.view.addSubview(screenView)
		
		self.fromScreenView = UIView(frame: CGRect(x: 0, y: 0, width: viewBounds.width, height: 100))
		//fromScreenView.backgroundColor = UIColor.red
		screenView.addSubview(self.fromScreenView)
		self.toScreenView = UIView(frame: CGRect(x: 0, y: 100, width: viewBounds.width, height: 100))
		//toScreenView.backgroundColor = UIColor.yellow
		screenView.addSubview(self.toScreenView)
		
		// 货币输入框
		fromMoneyLabel = UILabel(frame: CGRect(x: 16, y: 0, width:viewBounds.width - 80, height: 80))
		fromMoneyLabel.font = UIFont(name: "Avenir", size: 72)
		fromMoneyLabel.adjustsFontSizeToFitWidth = true
		fromMoneyLabel.textAlignment = .right
		fromMoneyLabel.text = numberFormat(self.fromMoney)
		fromMoneyLabel.textColor = UIColor.gray
		fromScreenView.addSubview(fromMoneyLabel)
		
		// 输入货币缩写标签
		fromSymbolButton = UIButton(frame: CGRect(x: viewBounds.width - 64, y: 0, width: 64, height: 80))
		fromSymbolButton.setTitle(self.fromSymbol, for: .normal)
		fromSymbolButton.setTitleColor(UIColor.gray, for: .normal)
		fromSymbolButton.tag = 1
		fromSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
		fromScreenView.addSubview(fromSymbolButton)
		
		// 货币输出框
		toMoneyLabel = UILabel(frame: CGRect(x: 16, y: 0, width: viewBounds.width - 80, height: 80))
		toMoneyLabel.font = UIFont(name: "Avenir", size: 72)
		toMoneyLabel.adjustsFontSizeToFitWidth = true
		toMoneyLabel.textAlignment = .right
		toMoneyLabel.text = self.output(self.fromMoney)
		toMoneyLabel.textColor = UIColor.white
		// 允许响应用户交互（长按出现copy）
		toMoneyLabel.isUserInteractionEnabled = true
		let longPress = UILongPressGestureRecognizer(target:self, action: #selector(toMoneyLongPress(_:)))
		toMoneyLabel.addGestureRecognizer(longPress)
		toScreenView.addSubview(toMoneyLabel)
		
		// 创建输入货币缩写标签
		toSymbolButton = UIButton(frame: CGRect(x: viewBounds.width - 64, y: 0, width: 64, height: 80))
		toSymbolButton.setTitle(self.toSymbol, for: .normal)
		toSymbolButton.tag = 2
		toSymbolButton.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
		toScreenView.addSubview(toSymbolButton)
		
		asteriskLabel = UILabel(frame: CGRect(x: viewBounds.width - 50, y: 8, width: 30, height: 30))
		asteriskLabel.text = "*"
		asteriskLabel.font = UIFont.systemFont(ofSize: 40)
		asteriskLabel.textColor = UIColor.white
		asteriskLabel.isHidden = !isCustomRate
		toScreenView.addSubview(asteriskLabel)
		
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
		//        let buttonHeight = (keyboardView.frame.size.height - 3) / 4
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % 4) + buttonPadding, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/4))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name:"Avenir", size:32)
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
	
	@objc func swipe(_ recognizer:UISwipeGestureRecognizer){
		if recognizer.direction == .up || recognizer.direction == .down {
			UIView.animate(withDuration: 0.5, animations: {
				self.fromScreenView.frame.origin.y = 100
				self.toScreenView.frame.origin.y = 0
			}, completion: {
				(finished:Bool) -> Void in
				
				let fromSymbol: String = self.toSymbol
				let toSymbol: String = self.fromSymbol
				//let newToMoney: String = self.fromMoney
				//反向计算得到原始toMoney
				let newFromMoney: String = String(Float(self.fromMoney)! * self.rate)
				//更新界面
				self.fromScreenView.frame.origin.y = 0
				self.toScreenView.frame.origin.y = 100
				//fromMoney没有缓存，不能通过UserDefaults事件来派发
				self.fromMoney = newFromMoney
				self.fromMoneyLabel.text = self.numberFormat(newFromMoney)

				//更新缓存
				let shared = UserDefaults(suiteName: self.groupId)
				shared?.set(fromSymbol, forKey: "fromSymbol")
				shared?.set(toSymbol, forKey: "toSymbol")
				let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? self.defaults["isCustomRate"] as! Bool
				if isCustomRate {
					shared?.set(false, forKey: "isCustomRate")
					self.asteriskLabel.isHidden = true
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
		let shared = UserDefaults(suiteName: self.groupId)
		let isSounds: Bool = shared?.bool(forKey: "sounds") ?? self.defaults["sounds"] as! Bool
		
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
		let shared = UserDefaults(suiteName: self.groupId)
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? self.defaults["isCustomRate"] as! Bool
		let customRate: Float = shared?.float(forKey: "customRate") ?? 1.0
		let rate = isCustomRate ? customRate : self.rate
		
		return numberFormat(String(Float(money)! * rate))
	}
	
	func registerSettingsBundle() {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.register(defaults: defaults)
	}
	
	//把 "1234567.89" -> "1,234,567.89"
	func numberFormat(_ s:String) -> String {
		let shared = UserDefaults(suiteName: self.groupId)
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? self.defaults["usesGroupingSeparator"] as! Bool
		let decimals = shared?.integer(forKey: "decimals") ?? self.defaults["decimals"] as! Int
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
				self.asteriskLabel.isHidden = !isCustomRate
			}
			
			if data.keys.contains("fromSymbol") {
				let symbol: String = data["fromSymbol"] as! String
				self.fromSymbolButton.setTitle(symbol, for: .normal)
				self.fromSymbol = symbol
				self.retrieveRate()
			}
			
			if data.keys.contains("toSymbol") {
				let symbol: String = data["toSymbol"] as! String
				self.toSymbolButton.setTitle(symbol, for: .normal)
				self.toSymbol = symbol
				self.retrieveRate()
			}
			
			if data.keys.contains("isCustomRate") || data.keys.contains("decimals") || data.keys.contains("usesGroupingSeparator") || data.keys.contains("fromSymbol") || data.keys.contains("toSymbol") {
				DispatchQueue.main.async {
					print("defaultsChanged")
					print("self.rate:", self.rate)
					print("self.fromMoney:", self.fromMoney)
					self.toMoneyLabel.text = self.output(self.fromMoney)
				}
			}
		}
	}
}



