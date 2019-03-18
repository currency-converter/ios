//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/2/25.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

enum CurrencyPickerType {
	case from
	case to
}

//域名
let domain = "\u{71}\u{75}\u{6E}\u{61}\u{72}"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // 当前输入货币是否为空
    var isEmpty: Bool = true
    
    // 输入货币数量
    var fromMony: String = "0"
    
    // 汇率
    var rate: Float!
    
    var rates: Dictionary<String,NSNumber>!
    
    // 计算精读
    var decimals: Int!
    
    // 输入货币类型
    var fromCurrency: String!
    
    // 输出货币类型
    var toCurrency: String!
	
	var currencyPickerType: CurrencyPickerType = CurrencyPickerType.from
    
    // 汇率更新时间
    var updatedAt: Int = 1551166586929
	
	var propertyList:String = NSHomeDirectory() + "/Library/app.plist"
    
    // api
    var updateRatesUrl:String = "https://cc.beta.\(domain).com/api/rates?ios=1"
	
	var allCurrencies = [
		0: [String](),
		1: [String]([
			"AED", "AUD", "BGN", "BHD", "BND", "BRL", "BYN", "CAD", "CHF", "CLP",
			"CNY", "COP", "CRC", "CZK", "DKK", "DZD", "EGP", "EUR", "GBP", "HKD",
			"HRK", "HUF", "IDR", "ILS", "INR", "IQD", "ISK", "JOD", "JPY", "KES",
			"KHR", "KRW", "KWD", "LAK", "LBP", "LKR", "MAD", "MMK", "MOP", "MXN",
			"MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RSD", "RUB",
			"SAR", "SEK", "SGD", "SYP", "THB", "TRY", "TWD", "TZS", "UGX", "USD",
			"VND", "ZAR"
		])
	]
	
	var adHeaders:[String] = [
		"Favorite Currencies",
		"All Currencies"
	]
	
	var currencyNames:Dictionary = [
		"": "Unknow",
		"AED": "United Arab Emirates Dirham",
		"AUD": "Australian Dollar",
		"BGN": "Bulgarian Lev",
		"BHD": "Bahraini Dinar",
		"BND": "Brunei Dollar",
		"BRL": "Brazilian Real",
		"BYN": "Belarusian Ruble",
		"CAD": "Canadian Dollar",
		"CHF": "Swiss Franc",
		"CLP": "Chilean Peso",
		"CNY": "Chinese Yuan",
		"COP": "Colombian Pesa",
		"CRC": "Costa Rican Colon",
		"CZK": "Czech Koruna",
		"DKK": "Danish Krone",
		"DZD": "Algerian Dinar",
		"EGP": "Egyptian Pound",
		"EUR": "Euro",
		"GBP": "British Pound",
		"HKD": "Hong Kong Dollar",
		"HRK": "Croatian Kuna",
		"HUF": "Hungarian Forint",
		"IDR": "Indonesian Rupiah",
		"ILS": "Israeli New Shekel",
		"INR": "Indian Rupee",
		"IQD": "Iraqi Dinar",
		"ISK": "Icelandic Krona",
		"JOD": "Jordanian Dinar",
		"JPY": "Japanese Yen",
		"KES": "Kenyan Shilling",
		"KHR": "Cambodian Riel",
		"KRW": "South Korean Won",
		"KWD": "Kuwaiti Dinar",
		"LAK": "Laotian Kip",
		"LBP": "Lebanese Pound",
		"LKR": "Sri Lankan Rupee",
		"MAD": "Moroccan Dirham",
		"MMK": "Myanmar Kyat",
		"MOP": "Macanese Pataca",
		"MXN": "Mexican Peso",
		"MYR": "Malaysian Ringgit",
		"NOK": "Norwegian Krone",
		"NZD": "New Zealand Dollar",
		"OMR": "Omani Rial",
		"PHP": "Philippine Peso",
		"PLN": "Polish Zloty",
		"QAR": "Qatari Rial",
		"RON": "Romanian Leu",
		"RSD": "Serbian Dinar",
		"RUB": "Russian Ruble",
		"SAR": "Saudi Riyal",
		"SEK": "Swedish Krona",
		"SGD": "Singapore Dollar",
		"SYP": "Syrian Pound",
		"THB": "Thai Baht",
		"TRY": "Turkish Lira",
		"TWD": "New Taiwan Dollar",
		"TZS": "Tanzanian Shilling",
		"UGX": "Ugandan Shilling",
		"USD": "US Dollar",
		"VND": "Vietnamese Dong",
		"ZAR": "South African Rand"
	]
	
	var defaultRates:NSDictionary = [
		"fromCurrency": "USD",
		"toCurrency": "CNY",
		"decimals": 2,
		"updatedAt": 1551251719471,
		"favorites": ["CNY", "HKD", "JPY", "USD"],
		"rates": [
			"AED":3.6728,"AUD":1.4013,"BGN":1.7178,"BHD":0.3769,"BND":1.3485,"BRL":3.7255,"BYN":2.13,"CAD":1.31691,"CHF":0.99505,"CLP":648.93,"CNY":6.6872,"COP":3069,"CRC":605.45,"CZK":22.4794,"DKK":6.54643,"DZD":118.281,"EGP":17.47,"EUR":0.8771,"GBP":0.75226,"HKD":7.8496,"HRK":6.5141,"HUF":277.27,"IDR":14067,"ILS":3.6082,"INR":71.0925,"IQD":1190,"ISK":119.5,"JOD":0.708,"JPY":110.749,"KES":99.85,"KHR":3958,"KRW":1121.95,"KWD":0.3032,"LAK":8565,"LBP":1505.7,"LKR":180.05,"MAD":9.539,"MMK":1499,"MOP":8.0847,"MXN":19.1921,"MYR":4.065,"NOK":8.53527,"NZD":1.4617,"OMR":0.3848,"PHP":51.72,"PLN":3.7801,"QAR":3.6406,"RON":4.1578,"RSD":103.5678,"RUB":65.7806,"SAR":3.75,"SEK":9.19689,"SGD":1.34869,"SYP":514.98,"THB":31.489,"TRY":5.3232,"TWD":30.783,"TZS":2338,"UGX":3668,"USD":1,"VND":23190,"ZAR":13.9727
		]
	]
	
	var searchResults:Array = [String]()
    
    // UI 组件
	var settingsView: UIView!
	var viewFromScreen: UIView!
	var viewToScreen: UIView!
	var currencyPickerView: UIView!
    var btnFromCurrency: UIButton!
	var btnToCurrency: UIButton!
    var txtFromMoney: UITextField!
    var txtToMoney: UITextField!
	var tbvResults: UITableView!
	var searchController: UISearchController!
	var searchBar: UISearchBar!
    
    func updateRates() {
        let newUrlString = self.updateRatesUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        //创建请求配置
        let config = URLSessionConfiguration.default
        //        创建请求URL
        let url = URL(string: newUrlString!)
        //        创建请求实例
        let request = URLRequest(url: url!)
        
        //        进行请求头的设置
        //        request.setValue(Any?, forKey: String)
        
        //        创建请求Session
        let session = URLSession(configuration: config)
        //        创建请求任务
        let task = session.dataTask(with: request) { (data,response,error) in
			if(error == nil) {
				// 将json数据解析成字典
				let rates = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
				self.rates = rates as? Dictionary<String, NSNumber>
				let configs:NSDictionary? = NSDictionary(contentsOfFile: self.propertyList)
				configs?.setValue(rates, forKey: "rates")
				configs?.write(toFile:self.propertyList, atomically:true)
			} else {
				print("Update rates failed.")
			}
        }
        
        // 激活请求任务
        task.resume()
    }
    
    func initConfig() {
		print("app.plist:", self.propertyList)
        // 判断文件是是否存在
        let manager = FileManager.default
        let notExist = !manager.fileExists(atPath: self.propertyList)
        if notExist {
            // 初始化配置项
            self.defaultRates.write(toFile:self.propertyList, atomically:true)
		}
		
		// 读取配置
		let configs:NSDictionary? = NSDictionary(contentsOfFile: self.propertyList)
		self.fromCurrency = configs?["fromCurrency"] as? String
		self.toCurrency = configs?["toCurrency"] as? String
		self.decimals = configs?["decimals"] as? Int
		self.allCurrencies[0] = configs?["favorites"] as? [String]
		
		// 计算汇率
		let rates:Dictionary = configs?["rates"] as! Dictionary<String, NSNumber>
		let fromRate:Float! = rates[self.fromCurrency]?.floatValue
		let toRate:Float! = rates[self.toCurrency]?.floatValue
		let rate:Float = toRate/fromRate
		self.rate = rate
		self.rates = rates
//		print("self.rates.keys:", self.rates.keys)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// 设置全局背景色
		self.view.backgroundColor = UIColor.black
		
		self.updateRates()
        
        self.initConfig()
		
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
		txtFromMoney.text = self.fromMony
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
		txtToMoney.text = self.fromMony
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
        
        // 创建键盘容器
        let keyboardView = UIView()
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
		
        let buttonWidth = (keyboardView.frame.size.width - 3) / 4
        let buttonHeight = (keyboardView.frame.size.height - 3) / 4
        let characters:[String] = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "A", "0", ".", "C"]
        
        for (index, item) in characters.enumerated() {
            // print(item)
            // 创建数字按钮
            var btn:UIButton

            switch item {
                case "C":
                    btn = UIButton.init(frame: CGRect(x:(buttonWidth + 1) * 3, y:0, width:buttonWidth, height:keyboardView.frame.size.height))
					btn.setBackgroundColor(color: UIColor.orange, forState: .normal)
					btn.setBackgroundColor(color: UIColor.white, forState: .highlighted)
                    btn.setTitleColor(UIColor.white, for: .normal)
					btn.setTitleColor(UIColor.gray, for: .highlighted)
                default:
                    btn = UIButton.init(frame: CGRect(x:(buttonWidth + 1) * CGFloat(index % 3), y:(buttonHeight + 1) * CGFloat(floor(Double(index/3))), width:buttonWidth, height:buttonHeight))
					btn.setTitleColor(UIColor.black, for: .normal)
					btn.setTitleColor(UIColor.white, for: .highlighted);
					btn.setBackgroundColor(color: UIColor.lightGray, forState: .normal)
					btn.setBackgroundColor(color: UIColor.gray, forState: .highlighted)
            }

            if item == "A" {
				btn.titleLabel?.font = UIFont(name:"CurrencyConverter", size:32)
				btn.setBackgroundColor(color: UIColor.gray, forState: .normal)
                btn.addTarget(self, action:#selector(onSettingsClick(_:)), for: UIControl.Event.touchDown)
            } else {
                btn.addTarget(self, action:#selector(onInput(_:)), for: UIControl.Event.touchDown)
				btn.titleLabel?.font = UIFont(name:"Avenir", size:32)
            }
            btn.setTitle(item, for: UIControl.State.normal)
            keyboardView.addSubview(btn)//将标签添加到View中
        }
		
		setupSettingsView()
		
		//setupCurrencyPickerView()
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
		if self.currencyPickerView == nil {
			self.setupCurrencyPickerView()
		}
		self.tbvResults.reloadData()
		if sender.tag == 1 {
			self.currencyPickerType = CurrencyPickerType.from
		} else {
			self.currencyPickerType = CurrencyPickerType.to
		}
		self.currencyPickerView.isHidden = false
		UIView.animate(withDuration: 0.5, animations: {
			self.currencyPickerView.frame.origin.y = UIApplication.shared.statusBarFrame.height
		}, completion: nil)
	}
    
    @objc func onInput(_ sender: UIButton) {//按钮相应事件方法，注意在该方法前需要加@objc
        // let btn = sender as! UIButton
        let n = sender.currentTitle
        switch n {
        case "C":
            self.isEmpty = true
            self.fromMony = "0"
        case "0":
            if fromMony != "0" {
                self.fromMony += "0"
				self.isEmpty = false
            }
        case ".":
            if !self.fromMony.contains(".") {
                self.fromMony += "."
				self.isEmpty = false
            }
        default:
            self.fromMony = self.isEmpty ? n! : self.fromMony + n!
			self.isEmpty = false
        }
		txtFromMoney.text = self.fromMony
		txtToMoney.text = self.output()
    }
    
    @objc func onSettingsClick(_ sender: UIButton) {
        self.settingsView.isHidden = false
		UIView.animate(withDuration: 0.5, animations: {
			self.settingsView.frame.origin.y = UIApplication.shared.statusBarFrame.height
		}, completion: nil)
    }
	
	@objc func onCurrenyClick(_ sender: UIButton) {
		self.currencyPickerView.isHidden = false
		UIView.animate(withDuration: 0.5, animations: {
			self.currencyPickerView.frame.origin.y = UIApplication.shared.statusBarFrame.height
		}, completion: nil)
	}
	
	@objc func onSettingsDone(_ sender: UIButton) {
		print("done")
		UIView.animate(withDuration: 0.5, animations: {
			self.settingsView.frame.origin.y = UIScreen.main.bounds.height
		}, completion: nil)
	}
	
	@objc func onCurrencyPickerCancel(_ sender: UIButton) {
		self.hideCurrencyPickerView()
	}
	
	@objc func imageViewClick(_ sender: UITapGestureRecognizer) {
		let configs:NSDictionary? = NSDictionary(contentsOfFile: self.propertyList)
		var favorites:[String] = configs?["favorites"] as? [String] ?? [String]()
		let currency = sender.view?.accessibilityLabel ?? ""
		if favorites.contains(currency) {
			favorites = favorites.filter {$0 != currency}
		} else {
			favorites.append(currency)
		}
		configs?.setValue(favorites, forKey: "favorites")
		configs?.write(toFile:self.propertyList, atomically:true)
		
		self.allCurrencies[0] = favorites
		self.tbvResults.reloadData()
	}
	
	func hideCurrencyPickerView() {
		//收起键盘
		//self.searchBar.resignFirstResponder()
		self.searchController.isActive = false
		UIView.animate(withDuration: 0.5, animations: {
			self.currencyPickerView.frame.origin.y = UIScreen.main.bounds.height
		}, completion: nil)
		self.tbvResults.contentOffset.y = 0
	}
	
	// 格式化输出换算结果
	func output() -> String {
		return String(format: "%.\(String(self.decimals))f", Float(self.fromMony)! * self.rate)
	}
	
	func setupSettingsView() {
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		self.settingsView = UIView(frame: CGRect(x: 0, y: viewBounds.height, width: viewBounds.width, height: viewBounds.height))
		self.settingsView.backgroundColor = UIColor.black
		self.settingsView.clipsToBounds = true
		self.settingsView.isHidden = true
		self.view.addSubview(self.settingsView)
		
		// 导航条
		let navbar:UINavigationBar = UINavigationBar(frame: CGRect(x:0, y:0, width:viewBounds.width, height: 44))
		navbar.barTintColor = UIColor.black
		navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		navbar.backgroundColor = UIColor.black
		self.settingsView.addSubview(navbar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onSettingsDone(_:)))
		
//		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onSettingsDone))
		navigationitem.title = "Settings"
		navigationitem.rightBarButtonItem = rightBtn
//		navigationitem.setRightBarButton(rightBtn, animated: true)
		navbar.pushItem(navigationitem, animated: true)
	}
	
	func setupCurrencyPickerView() {
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		self.currencyPickerView = UIView(frame: CGRect(x: 0, y: viewBounds.height, width: viewBounds.width, height: viewBounds.height))
		self.currencyPickerView.backgroundColor = UIColor.black
		self.currencyPickerView.clipsToBounds = true
		self.currencyPickerView.isHidden = true
		self.view.addSubview(self.currencyPickerView)
		
		// 导航条
		let navbar:UINavigationBar = UINavigationBar(frame: CGRect(x:0, y:0, width:viewBounds.width, height: 44))
		navbar.barTintColor = UIColor.black
//		navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		self.currencyPickerView.addSubview(navbar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onCurrencyPickerCancel(_:)))
		
		//		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onSettingsDone))
//		navigationitem.title = "Settings"
		navigationitem.rightBarButtonItem = rightBtn
		//		navigationitem.setRightBarButton(rightBtn, animated: true)
		navbar.pushItem(navigationitem, animated: true)

		tbvResults = UITableView(frame: CGRect(x: 0, y: 44, width: viewBounds.width, height: viewBounds.height-44), style: .plain)
		tbvResults.delegate = self
		tbvResults.dataSource = self
		tbvResults.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
		self.currencyPickerView.addSubview(tbvResults)
		
		let searchController = UISearchController(searchResultsController: nil)
		self.searchController = searchController
		// Setup the Search Controller
		searchController.searchResultsUpdater = self
		//搜索时，取消背景变模糊
		searchController.obscuresBackgroundDuringPresentation = false
		//搜索时，取消背景变暗色
		searchController.dimsBackgroundDuringPresentation = false
		//搜索时，取消隐藏导航条
		//searchController.hidesNavigationBarDuringPresentation = false
		tbvResults.tableHeaderView = searchController.searchBar
		
		// 搜索框
		let searchBar = searchController.searchBar
		self.searchBar = searchBar
//		searchBar.searchBarStyle = .minimal
//		searchBar.barStyle = .default
		searchBar.delegate = self
		//searchbar背景色
//		searchBar.barTintColor = UIColor.black
		//searchBar.placeholder = "Search"
		let searchTextFeild = searchBar.subviews.first?.subviews[1] as! UITextField
		// 修改输入文字的颜色
		//searchTextFeild.textColor = UIColor.rgba(r: 41, g: 202, b: 111, a: 1)
		// 输入内容大写
		searchTextFeild.autocapitalizationType = .allCharacters
	}
	
	//返回表格行数
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.searchController?.isActive ?? false {
			return self.searchResults.count
		} else {
			let data = self.allCurrencies[section] ?? [String]()
			return data.count
		}
	}
	
	//分组数量
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.searchController?.isActive ?? false ? 1 : self.allCurrencies.count
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionId:Int = indexPath.section
		let currency = self.searchController?.isActive ?? false ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "CellID")
		cell.detailTextLabel?.textColor = UIColor.black
		cell.detailTextLabel?.text = self.currencyNames[currency ?? ""]
		cell.detailTextLabel?.textAlignment = .natural
		cell.textLabel?.text = currency
		if (self.currencyPickerType == CurrencyPickerType.from && cell.textLabel?.text == self.fromCurrency) || (self.currencyPickerType == CurrencyPickerType.to && cell.textLabel?.text == self.toCurrency) {
//			cell.accessoryType = .checkmark
			cell.backgroundColor = UIColor.lightGray
		} else {
//			cell.accessoryType = .none
			cell.backgroundColor = UIColor.white
		}
//		cell.imageView?.image = UIImage(named:"Logo")
		cell.imageView?.image = UIImage.iconFont(fontSize: 40, unicode: (allCurrencies[0]?.contains(currency ?? "") ?? false) ? "B" : "C", color: .black)
		cell.imageView?.accessibilityLabel = currency
		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewClick))
		cell.imageView?.addGestureRecognizer(singleTapGesture)
		cell.imageView?.isUserInteractionEnabled = true
		return cell
	}
	
	//选中cell时触发这个代理
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//取消选中的样式
		tableView.deselectRow(at: indexPath, animated: true)
		
		//获取当前选中的单元格
		let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
		let text = cell.textLabel?.text
		if let text = text {
			let configs:NSDictionary? = NSDictionary(contentsOfFile: self.propertyList)
			if self.currencyPickerType == CurrencyPickerType.from {
				self.fromCurrency = text
				//更新界面
				self.btnFromCurrency.setTitle(text, for: .normal)
				//更新配置
				configs?.setValue(text, forKey: "fromCurrency")
				for item in self.tbvResults.visibleCells {
					if (item.textLabel?.text == text) {
						item.accessoryType = .checkmark
					} else {
						item.accessoryType = .none
					}
				}
			} else {
				self.toCurrency = text
				//更新界面
				self.btnToCurrency.setTitle(text, for: .normal)
				//更新配置
				configs?.setValue(text, forKey: "toCurrency")
			}
			configs?.write(toFile:self.propertyList, atomically:true)
			//更新汇率
			let fromRate:Float! = self.rates[self.fromCurrency]?.floatValue
			let toRate:Float! = self.rates[self.toCurrency]?.floatValue
			let rate:Float = toRate/fromRate
			self.rate = rate
			//更新计算结果
			self.txtToMoney.text = self.output()
		}
		self.hideCurrencyPickerView()
	}
	
	//行高
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 60
	}
	
	// UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.searchController?.isActive ?? false ? "" : self.adHeaders[section]
	}
	
	//searchbar的事件代理
//	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//		print("3 searchBar")
//
//		print("3 text=\(String(describing: searchBar.text)), string=\(searchText)")
//
//		self.searchResults.removeAll()
//		self.allCurrencies[1]?.forEach {
//			item in
//			if item.contains(searchText) {
//				self.searchResults.append(item)
//			}
//		}
//		self.tbvResults.reloadData()
//	}
//	func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//		print("begin editing")
//		self.searchResults.removeAll()
//		self.searchBarIsActive = true
//		self.tbvResults.reloadData()
//		return true
//	}
//	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//		print("end editing")
//		self.searchBarIsActive = false
//		self.tbvResults.reloadData()
//	}

}

extension ViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		print("search keyword:", searchController.searchBar.text!)
		self.searchResults.removeAll()
		self.allCurrencies[1]?.forEach {
			item in
			if item.contains(searchController.searchBar.text!) {
				self.searchResults.append(item)
			}
		}
		self.tbvResults.reloadData()
	}
}

