//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/2/25.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit
import AVFoundation

//货币选择类型
enum CurrencyPickerType: String {
	case from
	case to
}

//域名
let domain = "\u{71}\u{75}\u{6E}\u{61}\u{72}"

class ViewController: UIViewController, myDelegate {
	// plist文件路径
	static var propertyList:String = NSHomeDirectory() + "/Library/app.plist"
	
   	// 当前输入货币是否为空
    var isEmpty: Bool = true
	
	// 当前运算符
	var operatorSign:String = ""
	
	var operatorButton:UIButton!
	
	// 被操作的数
	var operatorEnd:String = ""
    
    // 输入货币数量
    var fromMoney: String = "0"
    
    // 汇率
    var rate: Float!
    
    var rates: Dictionary<String,NSNumber>!
    
    // 输入货币类型
    var fromCurrency: String!
    
    // 输出货币类型
	var toCurrency: String!
	
	var currencyPickerType: CurrencyPickerType = CurrencyPickerType.from
	
    // api
    var updateRatesUrl:String = "https://cc.beta.\(domain).com/api/rates?ios=1"
	
	
	var defaultRates:NSDictionary = [
		"fromCurrency": "USD",
		"toCurrency": "CNY",
		"favorites": ["CNY", "HKD", "JPY", "USD"],
		"rates": [
			"AED":3.6728,"AUD":1.4013,"BGN":1.7178,"BHD":0.3769,"BND":1.3485,"BRL":3.7255,"BYN":2.13,"CAD":1.31691,"CHF":0.99505,"CLP":648.93,"CNY":6.6872,"COP":3069,"CRC":605.45,"CZK":22.4794,"DKK":6.54643,"DZD":118.281,"EGP":17.47,"EUR":0.8771,"GBP":0.75226,"HKD":7.8496,"HRK":6.5141,"HUF":277.27,"IDR":14067,"ILS":3.6082,"INR":71.0925,"IQD":1190,"ISK":119.5,"JOD":0.708,"JPY":110.749,"KES":99.85,"KHR":3958,"KRW":1121.95,"KWD":0.3032,"LAK":8565,"LBP":1505.7,"LKR":180.05,"MAD":9.539,"MMK":1499,"MOP":8.0847,"MXN":19.1921,"MYR":4.065,"NOK":8.53527,"NZD":1.4617,"OMR":0.3848,"PHP":51.72,"PLN":3.7801,"QAR":3.6406,"RON":4.1578,"RSD":103.5678,"RUB":65.7806,"SAR":3.75,"SEK":9.19689,"SGD":1.34869,"SYP":514.98,"THB":31.489,"TRY":5.3232,"TWD":30.783,"TZS":2338,"UGX":3668,"USD":1,"VND":23190,"ZAR":13.9727
		]
	]
	
    // UI 组件
	var settingsView: UIView!
	var viewFromScreen: UIView!
	var viewToScreen: UIView!
	var keyboardView: UIView!
	var currencyPickerView: UIView!
    var btnFromCurrency: UIButton!
	var btnToCurrency: UIButton!
    var txtFromMoney: UITextField!
    var txtToMoney: UITextField!
	var tapSoundPlayer: AVAudioPlayer!
	
	func currencyCellClickCallback(data: String) {
		let configs:NSDictionary? = NSDictionary(contentsOfFile: ViewController.propertyList)
		if currencyPickerType == CurrencyPickerType.from {
			fromCurrency = data
			//更新界面
			self.btnFromCurrency.setTitle(data, for: .normal)
			//更新配置
			configs?.setValue(data, forKey: "fromCurrency")
		} else {
			toCurrency = data
			//更新界面
			self.btnToCurrency.setTitle(data, for: .normal)
			//更新配置
			configs?.setValue(data, forKey: "toCurrency")
		}
		configs?.write(toFile: ViewController.propertyList, atomically: true)
		//更新汇率
		let fromRate:Float! = self.rates[self.fromCurrency]?.floatValue
		let toRate:Float! = self.rates[self.toCurrency]?.floatValue
		let rate:Float = toRate/fromRate
		self.rate = rate
		//更新计算结果
		self.txtToMoney.text = self.output(money: self.fromMoney)
	}
    
    func updateRates() {
        let newUrlString = self.updateRatesUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
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
				// 将json数据解析成字典
				let rates = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
				self.rates = rates as? Dictionary<String, NSNumber>
				let configs:NSDictionary? = NSDictionary(contentsOfFile: ViewController.propertyList)
				configs?.setValue(rates, forKey: "rates")
				configs?.write(toFile: ViewController.propertyList, atomically: true)
			} else {
				print("Update rates failed.")
			}
        }
        
        // 激活请求任务
        task.resume()
    }
    
    func initConfig() {
		print("app.plist:", ViewController.propertyList)
        // 判断文件是是否存在
        let manager = FileManager.default
        let notExist = !manager.fileExists(atPath: ViewController.propertyList)
        if notExist {
            // 初始化配置项
            self.defaultRates.write(toFile: ViewController.propertyList, atomically:true)
		}
		
		// 读取配置
		let configs:NSDictionary? = NSDictionary(contentsOfFile: ViewController.propertyList)
		self.fromCurrency = configs?["fromCurrency"] as? String
		self.toCurrency = configs?["toCurrency"] as? String
		
		// 计算汇率
		let rates:Dictionary = configs?["rates"] as! Dictionary<String, NSNumber>
		let fromRate:Float! = rates[self.fromCurrency]?.floatValue
		let toRate:Float! = rates[self.toCurrency]?.floatValue
		let rate:Float = toRate/fromRate
		self.rate = rate
		self.rates = rates
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		registerSettingsBundle()
		NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
//		defaultsChanged()
		
		// 设置全局背景色
		self.view.backgroundColor = UIColor.hex("121212")
		
		updateRates()
        
        initConfig()
		
		createScreenView()
		
		createKeyboardView()
    }
	
	private func createScreenView() {
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		// 创建屏幕容器
		let screenView = UIView()
		// 坐标
		screenView.frame = CGRect(x: 0, y: viewBounds.height - viewBounds.width - 180, width: viewBounds.width, height: 180)
		// 是否切除子视图超出部分
		screenView.clipsToBounds = true
		// 透明度
		// screenView = 0.5
		// 是否隐藏视图
		screenView.isHidden = false
		// 添加到当前视图控制器
		self.view.addSubview(screenView)
		
		self.viewFromScreen = UIView(frame: CGRect(x:0, y:20, width:viewBounds.width, height:66))
		screenView.addSubview(self.viewFromScreen)
		self.viewToScreen = UIView(frame: CGRect(x:0, y:96, width:viewBounds.width, height:66))
		screenView.addSubview(self.viewToScreen)
		
		// 创建输入货币数量标签
		txtFromMoney = UITextField(frame: CGRect(x:0, y:0, width:viewBounds.width - 64, height:66))
		txtFromMoney.clearButtonMode = .never
		txtFromMoney.font = UIFont(name: "Avenir", size: 48)
		txtFromMoney.adjustsFontSizeToFitWidth = true  //当文字超出文本框宽度时，自动调整文字大小
		txtFromMoney.minimumFontSize = 14
		txtFromMoney.textAlignment = .right
		txtFromMoney.text = self.fromMoney
		txtFromMoney.textColor = UIColor.white
		txtFromMoney.isEnabled = false
		viewFromScreen.addSubview(txtFromMoney)
		
		// 创建输入货币缩写标签
		btnFromCurrency = UIButton(frame: CGRect(x:viewBounds.width - 64, y:0, width:64, height:66))
		btnFromCurrency.setTitle(self.fromCurrency, for: .normal)
		btnFromCurrency.tag = 1
		btnFromCurrency.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
		viewFromScreen.addSubview(btnFromCurrency)
		
		// 创建输出货币数量标签
		txtToMoney = UITextField(frame: CGRect(x:0, y:0, width:viewBounds.width - 64, height:66))
		txtToMoney.clearButtonMode = .never
		txtToMoney.font = UIFont(name: "Avenir", size: 48)
		txtToMoney.adjustsFontSizeToFitWidth = true  //当文字超出文本框宽度时，自动调整文字大小
		txtToMoney.minimumFontSize = 14
		txtToMoney.textAlignment = .right
		txtToMoney.text = self.fromMoney
		txtToMoney.textColor = UIColor.white
		txtToMoney.isEnabled = false
		viewToScreen.addSubview(txtToMoney)
		
		// 创建输入货币缩写标签
		btnToCurrency = UIButton(frame: CGRect(x:viewBounds.width - 64, y:0, width:64, height:66))
		btnToCurrency.setTitle(self.toCurrency, for: .normal)
		btnToCurrency.tag = 2
		btnToCurrency.addTarget(self, action: #selector(showCurrencyPicker(_:)), for: .touchDown)
		viewToScreen.addSubview(btnToCurrency)
		
		let swipeUp = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
		swipeUp.direction = .up
		screenView.addGestureRecognizer(swipeUp)
		
		let swipeDown = UISwipeGestureRecognizer(target:self, action:#selector(swipe(_:)))
		swipeDown.direction = .down
		screenView.addGestureRecognizer(swipeDown)
	}
	
	private func createKeyboardView() {
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		// 创建键盘容器
		let keyboardView = UIView()
		self.keyboardView = keyboardView
		// 坐标
		keyboardView.frame = CGRect(x: 0, y: viewBounds.height - viewBounds.width, width: viewBounds.width, height: viewBounds.width)
		// 背景颜色
		// keyboardView.backgroundColor = UIColor.yellow
		// 是否切除子视图超出部分
		keyboardView.clipsToBounds = true
		// 透明度
		// screenView = 0.5
		// 是否隐藏视图
		keyboardView.isHidden = false
		// 添加到当前视图控制器
		self.view.addSubview(keyboardView)
		
		let buttonWidth = (keyboardView.frame.size.width - 50) / 4
		let buttonPadding:CGFloat = 10
		//        let buttonHeight = (keyboardView.frame.size.height - 3) / 4
		let characters:[String] = ["7", "8", "9", "=", "4", "5", "6", "+", "1", "2", "3", "-", "A", "0", ".", "AC"]
		
		for (index, item) in characters.enumerated() {
			// print(item)
			// 创建数字按钮
			var btn:UIButton
			btn = UIButton.init(frame: CGRect(x:(buttonWidth + buttonPadding) * CGFloat(index % 4) + buttonPadding, y:(buttonWidth + buttonPadding) * CGFloat(floor(Double(index/4))) + buttonPadding, width:buttonWidth, height:buttonWidth))
			btn.layer.cornerRadius = buttonWidth/2
			btn.setTitleColor(UIColor.white, for: .normal)
			btn.titleLabel?.font = UIFont(name:"Avenir", size:32)
			btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
			
			switch item {
			case "=", "+", "-", "AC":
				btn.setBackgroundColor(color: UIColor.hex("ff9408"), forState: .normal)
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
			let tempCurrency = self.fromCurrency
			self.fromCurrency = self.toCurrency
			self.toCurrency = tempCurrency
			self.rate = 1/self.rate
			
			UIView.animate(withDuration: 0.5, animations: {
				self.viewFromScreen.frame.origin.y = 96
				self.viewToScreen.frame.origin.y = 20
			}, completion: {
				(finished:Bool) -> Void in
				//更新界面
				self.viewFromScreen.frame.origin.y = 20
				self.viewToScreen.frame.origin.y = 96
				self.btnFromCurrency.setTitle(self.fromCurrency, for: .normal)
				self.btnToCurrency.setTitle(self.toCurrency, for: .normal)
				let tempMoney = self.txtFromMoney.text
				self.txtFromMoney.text = self.txtToMoney.text
				self.txtToMoney.text = tempMoney
			})
		}
	}
	
	@objc func showCurrencyPicker(_ sender: UIButton) {
		var currentCurrency = ""
		if sender.tag == 1 {
			self.currencyPickerType = .from
			currentCurrency = self.fromCurrency
		} else {
			self.currencyPickerType = .to
			currentCurrency = self.toCurrency
		}
		
		let pickerView = CurrencyPickerViewController()
		pickerView.currentCurrency = currentCurrency
		pickerView.delegate = self
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
			self.operatorEnd = ""
			self.operatorSign = ""
		case "A":
			self.onSettingsClick(sender)
		case "+", "-":
			if !self.isEmpty {
				self.operatorSign = n ?? ""
				self.operatorEnd = ""
				self.operatorButton = sender
				sender.isSelected = true
			}
		case "=":
			if self.operatorEnd != "" {
				var a:Float = 0
				if self.operatorSign == "+" {
					a = (self.fromMoney as NSString).floatValue + (self.operatorEnd as NSString).floatValue
				} else {
					a = (self.fromMoney as NSString).floatValue - (self.operatorEnd as NSString).floatValue
				}
				self.fromMoney = "\(a)"
			}
			self.operatorSign = ""
			self.operatorEnd = ""
        case "0":
			if self.operatorSign == "" {
				if fromMoney != "0" {
					self.fromMoney += "0"
					self.isEmpty = false
				}
			} else {
				self.operatorEnd += "0"
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
		
		if self.operatorSign != "" && self.operatorEnd != "" {
			txtFromMoney.text = self.operatorEnd
			txtToMoney.text = self.output(money: self.operatorEnd)
		} else {
			txtFromMoney.text = self.fromMoney
			txtToMoney.text = self.output(money: self.fromMoney)
		}
		
		self.playTapSound()
    }
	
	func playTapSound() {
		guard UserDefaults.standard.bool(forKey: "sound_preference") else {
			return
		}
		
		let path = Bundle.main.path(forResource: "Sounds/tap", ofType: "wav")!
		let url = URL(fileURLWithPath: path)
		
		do {
			try tapSoundPlayer = AVAudioPlayer(contentsOf: url)
			tapSoundPlayer.play()
		} catch {
			print("Could not load audio file.")
		}
	}
    
    @objc func onSettingsClick(_ sender: UIButton) {
		let settingsView = SettingsViewController()
		self.present(settingsView, animated: true, completion: nil)
    }
	
	@objc func onSettingsDone(_ sender: UIButton) {
		UIView.animate(withDuration: 0.5, animations: {
			self.settingsView.frame.origin.y = UIScreen.main.bounds.height
		}, completion: nil)
	}
	
	// 格式化输出换算结果
	func output(money:String) -> String {
		let decimals = UserDefaults.standard.integer(forKey: "decimals_preference")
		print("decimals:", decimals)
		return String(format: "%.\(String(decimals))f", Float(money)! * self.rate)
	}

	func registerSettingsBundle(){
		UserDefaults.standard.register(defaults: [
			"decimals_preference" : 2,
			"sound_preference": false
		])
	}
	
	@objc func defaultsChanged() {
		if !self.isEmpty {
			self.txtToMoney.text = self.output(money: self.fromMoney)
		}
	}

}



