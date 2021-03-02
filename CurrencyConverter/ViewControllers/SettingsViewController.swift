//
//  STC.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/11.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, CallbackDelegate {
	@IBOutlet weak var cell0_0: UITableViewCell!
	@IBOutlet weak var cell1_0: UITableViewCell!
	@IBOutlet weak var cell1_1: UITableViewCell!
	@IBOutlet weak var cell1_2: UITableViewCell!
	@IBOutlet weak var cell1_3: UITableViewCell!
	@IBOutlet weak var cell2_0: UITableViewCell!
	@IBOutlet weak var cell2_1: UITableViewCell!
	@IBOutlet weak var cell3_0: UITableViewCell!
	@IBOutlet weak var cell3_1: UITableViewCell!
	@IBOutlet weak var cell3_2: UITableViewCell!
	@IBOutlet weak var cell3_3: UITableViewCell!
	@IBOutlet weak var cell4_0: UITableViewCell!
	@IBOutlet weak var keyboardClicksLabel: UILabel!
	@IBOutlet weak var autoUpdateRateLabel: UILabel!
	@IBOutlet weak var updateFrequencyLabel: UILabel!
	@IBOutlet weak var updatedAtLabel: UILabel!
	@IBOutlet weak var updatedAtValue: UILabel!
	@IBOutlet weak var frequencyValue: UILabel!
	@IBOutlet weak var customRateLabel: UILabel!
	@IBOutlet weak var demoLabel: UILabel!
	@IBOutlet weak var use1000SeparatorLabel: UILabel!
	@IBOutlet weak var decimalPlacesLabel: UILabel!
	@IBOutlet weak var decimalValue: UILabel!
	@IBOutlet weak var keyboardClicksSwitch: UISwitch!
	@IBOutlet weak var autoUpdateRateSwitch: UISwitch!
	@IBOutlet weak var customRateSwitch: UISwitch!
	@IBOutlet weak var use1000SeparatorSwitch: UISwitch!
	@IBOutlet weak var loading: UIActivityIndicatorView!
	@IBOutlet weak var updateImmediatelyButton: UIButton!
	@IBOutlet weak var disclaimerLabel: UILabel!
	@IBOutlet weak var themeLabel: UILabel!
	@IBOutlet weak var themeSegment: UISegmentedControl!
	@IBOutlet weak var customRateFrom: UILabel!
	@IBOutlet weak var customRateTo: UILabel!
	@IBOutlet weak var customRateTextField: UITextField!
	@IBOutlet weak var customRate1: UILabel!
	@IBOutlet weak var customRateEqual: UILabel!
	
	var sectionHeaders:[String] = [
		NSLocalizedString("settings.soundsHeader", comment: ""),
		NSLocalizedString("settings.rateUpdateHeader", comment: ""),
		NSLocalizedString("settings.customRateHeader", comment: ""),
		NSLocalizedString("settings.displayHeader", comment: ""),
		NSLocalizedString("settings.disclaimerHeader", comment: "")
	]
	
	var sectionFooters:[String] = [
		NSLocalizedString("settings.soundsFooter", comment: ""),
		NSLocalizedString("settings.rateUpdateFooter", comment: ""),
		NSLocalizedString("settings.customRateFooter", comment: ""),
		NSLocalizedString("settings.displayFooter", comment: ""),
		""
	]
	
	// 是否正在更新汇率
	var isUpdating = false
	
	var themeIndex: Int!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		initConfig()
		render()
		observe()
	}
	
	func onReady(key: String, value: String) {
		// 更新配置
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(value, forKey: key)
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [key: value])
		
		//更新界面
		if key == "decimals" {
			decimalValue.text = value
			demoLabel.text = self.formatDemoText()
		}
		
		if key == "rateUpdatedFrequency" {
			frequencyValue.text = NSLocalizedString("settings.update.\(value)", comment: "")
			frequencyValue.tag = Int(value) ?? Config.defaults["rateUpdatedFrequency"] as! Int
		}
	}
	
	@objc func onDidUpdateRate(_ notification: Notification) {
		isUpdating = false
		
		var title: String = NSLocalizedString("settings.updateSuccess", comment: "")
		if let data = notification.userInfo as? [String: Int] {
			if data["error"]?.description == "1" {
				title = NSLocalizedString("settings.updateFailed", comment: "")
			}
		}
		
		//避免出现非主线程更新UI的警告
		DispatchQueue.main.async {
			self.updatedAtValue.text = self.formatUpdatedAtText()
			self.updateImmediatelyButton.tintColor = UIColor.hex("0067d8")
			self.loading.stopAnimating()
			
			let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
			//显示提示框
			self.present(alertController, animated: true, completion: nil)
			//1秒钟后自动消失
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
				self.presentedViewController?.dismiss(animated: false, completion: nil)
			}
		}
	}
	
	@IBAction func onKeyboardClicksChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(sender.isOn, forKey: "sounds")
	}

	@IBAction func onAutoUpdateRateChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(sender.isOn, forKey: "autoUpdateRate")
	}
	
	@IBAction func onCustomRateSwitchChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(sender.isOn, forKey: "isCustomRate")
		if sender.isOn {
			shared?.set(self.customRateTextField.text, forKey: "customRate")
		} else {
			shared?.removeObject(forKey: "customRate")
		}
		self.toggleCustomRateDetail(sender.isOn)
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"isCustomRate": sender.isOn
		])
	}
	
	@IBAction func onCustomRateTextfieldChanged(_ sender: UITextField) {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(self.customRateTextField.text, forKey: "customRate")

		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"isCustomRate": true
		])
	}

	@IBAction func onUse1000SeparatorChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(sender.isOn, forKey: "usesGroupingSeparator")
		self.demoLabel.text = self.formatDemoText()
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"usesGroupingSeparator": sender.isOn
		])
	}

	@IBAction func onUpdateImmediatelyClick(_ sender: UIButton) {
		if !isUpdating {
			isUpdating = true
			updateImmediatelyButton.tintColor = UIColor.gray
			loading.startAnimating()
			let viewController = navigationController?.children[0] as! ViewController
			viewController.updateRate()
		}
	}
	
	@IBAction func onThemeChanged(_ sender: UISegmentedControl) {
		let shared = UserDefaults(suiteName: Config.groupId)
		let selectedTheme: Int = sender.selectedSegmentIndex
		shared?.set(selectedTheme, forKey: "theme")
		
		print("Theme Changed:", selectedTheme)
		
		setThemeIndex(selectedTheme)
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"theme": selectedTheme
		])
	}
	
	func observe() {
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidUpdateRate), name: .didUpdateRate, object: nil)
	}
	
	func initConfig() {
		// 初始化输入输出货币
		let shared = UserDefaults(suiteName: Config.groupId)
		self.themeIndex = shared?.integer(forKey: "theme")
	}
	
	func setThemeIndex(_ themeIndex: Int) {
		self.view.backgroundColor = Theme.appBackgroundColor[themeIndex]
		self.navigationController?.navigationBar.barStyle = Theme.barStyle[themeIndex]
		UIApplication.shared.statusBarStyle = Theme.statusBarStyle[themeIndex]
		
		self.tableView.backgroundColor = Theme.tableBackgroundColor[themeIndex]
		self.cell0_0.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell1_0.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell1_1.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell1_2.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell1_3.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell2_0.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell2_1.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell3_0.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell3_1.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell3_2.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell3_3.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.cell4_0.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		self.keyboardClicksLabel.textColor = Theme.cellTextColor[themeIndex]
		self.autoUpdateRateLabel.textColor = Theme.cellTextColor[themeIndex]
		self.updateFrequencyLabel.textColor = Theme.cellTextColor[themeIndex]
		self.updatedAtLabel.textColor = Theme.cellTextColor[themeIndex]
		self.customRateLabel.textColor = Theme.cellTextColor[themeIndex]
		self.customRate1.textColor = self.customRateSwitch.isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateFrom.textColor = self.customRateSwitch.isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateEqual.textColor = self.customRateSwitch.isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateTo.textColor = self.customRateSwitch.isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		//self.customRateDetailLabel.textColor = Theme.cellTextColor[themeIndex]
		self.demoLabel.textColor = Theme.cellTextColor[themeIndex]
		self.use1000SeparatorLabel.textColor = Theme.cellTextColor[themeIndex]
		self.decimalPlacesLabel.textColor = Theme.cellTextColor[themeIndex]
		self.themeLabel.textColor = Theme.cellTextColor[themeIndex]
		self.disclaimerLabel.textColor = Theme.cellTextColor[themeIndex]
	}
	
	func render() {
		setThemeIndex(themeIndex)
		
		let shared = UserDefaults(suiteName: Config.groupId)
		let frequency: Int = shared?.integer(forKey: "rateUpdatedFrequency") ?? Config.defaults["rateUpdatedFrequency"] as! Int
		let frequencyText = NSLocalizedString("settings.update.\(frequency)", comment: "")
		let decimals: Int = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		let isSounds: Bool = shared?.bool(forKey: "sounds") ?? Config.defaults["sounds"] as! Bool
		let isAutoUpdateRate: Bool = shared?.bool(forKey: "autoUpdateRate") ?? Config.defaults["autoUpdateRate"] as! Bool
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? Config.defaults["isCustomRate"] as! Bool
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
		let rates = shared?.object(forKey: "rates") as? [String: [String: NSNumber]]
		let fromSymbol: String = shared?.string(forKey: "fromSymbol") ?? Config.defaults["fromSymbol"] as! String
		let toSymbol: String = shared?.string(forKey: "toSymbol") ?? Config.defaults["toSymbol"] as! String
		let selectedTheme: Int = shared?.integer(forKey: "theme") ?? Config.defaults["theme"] as! Int
		
		var rate: Float = 1.0
		if rates != nil {
			let fromRate: Float! = Float(truncating: (rates![fromSymbol]! as [String: NSNumber])["a"]!)
			let toRate: Float! = Float(truncating: (rates![toSymbol]! as [String: NSNumber])["a"]!)
			rate = toRate/fromRate
		}
		
		if isCustomRate {
			rate = shared?.float(forKey: "customRate") ?? 1.0
		}
		
		//设置界面文字
		self.navigationController?.isNavigationBarHidden = false
		self.navigationItem.title = NSLocalizedString("settings.title", comment: "")
		self.keyboardClicksLabel.text = NSLocalizedString("settings.keyboardClicks", comment: "")
		self.updatedAtLabel.text = NSLocalizedString("settings.updatedAt", comment: "")
		self.updateFrequencyLabel.text = NSLocalizedString("settings.updateFrequency", comment: "")
		self.use1000SeparatorLabel.text = NSLocalizedString("settings.usesGroupingSeparator", comment: "")
		self.decimalPlacesLabel.text = NSLocalizedString("settings.decimalPlaces", comment: "")
		self.updateImmediatelyButton.setTitle(NSLocalizedString("settings.updateImmediately", comment: ""), for: .normal)
		self.customRateLabel.text = NSLocalizedString("settings.customRateHeader", comment: "")
		self.disclaimerLabel.text = NSLocalizedString("settings.disclaimer", comment: "")
		self.autoUpdateRateLabel.text = NSLocalizedString("settings.autoUpdateRate", comment: "")
		self.themeLabel.text = NSLocalizedString("settings.theme", comment: "")
		self.themeSegment.setTitle(NSLocalizedString("settings.themeWhite", comment: ""), forSegmentAt: 0)
		self.themeSegment.setTitle(NSLocalizedString("settings.themeBlack", comment: ""), forSegmentAt: 1)
		//设置初始值
		self.frequencyValue.text = frequencyText
		self.frequencyValue.tag = frequency
		self.updatedAtValue.text = self.formatUpdatedAtText()
		self.decimalValue.text = decimals.description
		self.keyboardClicksSwitch.isOn = isSounds
		self.autoUpdateRateSwitch.isOn = isAutoUpdateRate
		self.customRateSwitch.isOn = isCustomRate
		self.toggleCustomRateDetail(self.customRateSwitch.isOn)
		self.customRateTextField.text = "\(rate)"
		self.customRateTo.text = toSymbol
		self.customRateFrom.text = fromSymbol
		self.use1000SeparatorSwitch.isOn = usesGroupingSeparator
		self.demoLabel.font = UIFont(name: Config.numberFontName, size: 48)
		self.demoLabel.text = self.formatDemoText()
		self.themeSegment.selectedSegmentIndex = selectedTheme
	}
	
	func formatDemoText() -> String {
		return numberFormat("12345.67890")
	}
	
	func numberFormat(_ s:String) -> String {
		let shared = UserDefaults(suiteName: Config.groupId)
		let usesGroupingSeparator: Bool = shared?.bool(forKey: "usesGroupingSeparator") ?? Config.defaults["usesGroupingSeparator"] as! Bool
		let decimals = shared?.integer(forKey: "decimals") ?? Config.defaults["decimals"] as! Int
		var price: NSNumber = 0
		if let myInteger = Double(s) {
			price = NSNumber(value: myInteger)
		}
		//创建一个NumberFormatter对象
		let numberFormatter = NumberFormatter()
		//设置number显示样式
		numberFormatter.numberStyle = .decimal  // 小数形式
		numberFormatter.usesGroupingSeparator = usesGroupingSeparator //设置用组分隔
		numberFormatter.maximumFractionDigits = decimals //设置小数点后最多3位
		//格式化
		let format = numberFormatter.string(from: price)!
		return format
	}
	
	func formatUpdatedAtText() -> String {
        let shared = UserDefaults(suiteName: Config.groupId)
        let fromSymbol = shared?.string(forKey: "fromSymbol")
        let toSymbol = shared?.string(forKey: "toSymbol")
        let rates = shared?.object(forKey: "rates") as? [String: [String: NSNumber]]
        let fromRateUpdateAt: Int = (rates![fromSymbol!]?["b"]) as! Int
        let toRateUpdateAt: Int = rates![toSymbol!]?["b"] as! Int
        // 以更新慢的那个汇率的更新时间为当前汇率更新时间
        let timeStamp: Int = [fromRateUpdateAt, toRateUpdateAt].min()!
 		let timeInterval:TimeInterval = TimeInterval(timeStamp)
		let date = Date(timeIntervalSince1970: timeInterval)
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		let stringOfDate = dateFormatter.string(from: date)
		
		return stringOfDate
	}
	
	func toggleCustomRateDetail(_ isOn: Bool) {
		self.customRateTextField.isEnabled = isOn
		self.customRateTextField.textColor = isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRate1.textColor = isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateFrom.textColor = isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateEqual.textColor = isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
		self.customRateTo.textColor = isOn ? Theme.cellTextColor[themeIndex] : UIColor.gray
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sectionHeaders[section]
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.sectionFooters[section]
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//更新频率
		if indexPath.section == 1 && indexPath.row == 1 {
			self.performSegue(withIdentifier: "showFrequencySegue", sender: self.frequencyValue.tag.description)
		}
		//小数位数
		if indexPath.section == 3 && indexPath.row == 2 {
			self.performSegue(withIdentifier: "showDecimalSegue", sender: self.decimalValue.text)
		}
	}
	
	//在这个方法中给新页面传递参数
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		//if segue.identifier == "showDecimalSegue"{
		if segue.destination is DecimalsViewController {
			let controller = segue.destination as! DecimalsViewController
			controller.delegate = self
			controller.defaultValue = sender as? String
		}
		
		if segue.destination is FrequencyViewController {
			let controller = segue.destination as! FrequencyViewController
			controller.delegate = self
			controller.defaultValue = sender as? String
		}
	}
}
