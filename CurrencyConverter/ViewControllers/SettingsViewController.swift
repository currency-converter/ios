//
//  STC.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/11.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, CallbackDelegate {
	@IBOutlet weak var keyboardClicksLabel: UILabel!
	@IBOutlet weak var autoUpdateRateLabel: UILabel!
	@IBOutlet weak var updateFrequencyLabel: UILabel!
	@IBOutlet weak var updatedAtLabel: UILabel!
	@IBOutlet weak var updatedAtValue: UILabel!
	@IBOutlet weak var frequencyValue: UILabel!
	@IBOutlet weak var customRateLabel: UILabel!
	@IBOutlet weak var customRateDetailLabel: UILabel!
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
	@IBOutlet weak var customRateStepper: UIStepper!
	@IBOutlet weak var disclaimerLabel: UILabel!
	
	let groupId: String = "group.com.zhongzhi.currencyconverter"
	
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
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		render()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.onDidUpdateRate), name: .didUpdateRate, object: nil)
	}
	
	func onReady(key: String, value: String) {
		// 更新配置
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(value, forKey: key)
		//更新界面
		if key == "decimals" {
			decimalValue.text = value
			demoLabel.text = self.formatDemoText()
			
			self.updateCustomRateDetail(rate: Float(self.customRateStepper.value))
			let decimals: Int = shared?.integer(forKey: "decimals") ?? 2
			self.customRateStepper.stepValue = 1/pow(10, Double(decimals))
		}
		
		if key == "rateUpdatedFrequency" {
			frequencyValue.text = NSLocalizedString("settings.update.\(value)", comment: "")
			frequencyValue.tag = Int(value) ?? 2
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
			self.updateImmediatelyButton.tintColor = UIColor.black
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
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "sounds")
	}

	@IBAction func onAutoUpdateRateChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "autoUpdateRate")
	}
	
	@IBAction func onCustomRateSwitchChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "isCustomRate")
		if sender.isOn {
			shared?.set(self.customRateStepper.value, forKey: "customRate")
		} else {
			shared?.removeObject(forKey: "customRate")
		}
		self.toggleCustomRateDetail(sender.isOn)
		NotificationCenter.default.post(name: .didChangeCustomRate, object: self)
	}
	
	@IBAction func onCustomRateStepperClick(_ sender: UIStepper) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(self.customRateStepper.value, forKey: "customRate")

		self.updateCustomRateDetail(rate: Float(sender.value))
		NotificationCenter.default.post(name: .didChangeCustomRate, object: self)
	}
	
	@IBAction func onUse1000SeparatorChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "thousandSeparator")
		self.demoLabel.text = self.formatDemoText()
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
	
	func render() {
		//self.view.backgroundColor = UIColor.hex("000000")
		//self.tableView.style = .plain
		//去除表格上放多余的空隙
		//self.tableView?.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
		
		let shared = UserDefaults(suiteName: self.groupId)
		let frequency = shared?.string(forKey: "rateUpdatedFrequency") ?? RateUpdatedFrequency.daily.rawValue
		let frequencyText = NSLocalizedString("settings.update.\(frequency)", comment: "")
		let decimals: Int = shared?.integer(forKey: "decimals") ?? 2
		let isSounds: Bool = shared?.bool(forKey: "sounds") ?? false
		let isAutoUpdateRate: Bool = shared?.bool(forKey: "autoUpdateRate") ?? true
		let isCustomRate: Bool = shared?.bool(forKey: "isCustomRate") ?? false
		let isUse1000Separator: Bool = shared?.bool(forKey: "thousandSeparator") ?? true
		let rates = shared?.object(forKey: "rates") as? Dictionary<String, NSNumber>
		let fromCurrency: String = shared?.string(forKey: "fromCurrency") ?? "USD"
		let toCurrency: String = shared?.string(forKey: "toCurrency") ?? "CNY"
		
		var rate: Float = 1.0
		if rates != nil {
			let fromRate:Float! = rates![fromCurrency]?.floatValue
			let toRate:Float! = rates![toCurrency]?.floatValue
			rate = toRate/fromRate
		}
		
		//设置界面文字
		self.navigationController?.isNavigationBarHidden = false
		self.navigationItem.title = NSLocalizedString("settings.title", comment: "")
		self.keyboardClicksLabel.text = NSLocalizedString("settings.keyboardClicks", comment: "")
		self.updatedAtLabel.text = NSLocalizedString("settings.updatedAt", comment: "")
		self.updateFrequencyLabel.text = NSLocalizedString("settings.updateFrequency", comment: "")
		self.use1000SeparatorLabel.text = NSLocalizedString("settings.use1000Separator", comment: "")
		self.decimalPlacesLabel.text = NSLocalizedString("settings.decimalPlaces", comment: "")
		self.updateImmediatelyButton.setTitle(NSLocalizedString("settings.updateImmediately", comment: ""), for: .normal)
		self.customRateLabel.text = NSLocalizedString("settings.customRateHeader", comment: "")
		self.disclaimerLabel.text = NSLocalizedString("settings.disclaimer", comment: "")
		self.autoUpdateRateLabel.text = NSLocalizedString("settings.autoUpdateRate", comment: "")
		//设置初始值
		self.frequencyValue.text = frequencyText
		self.frequencyValue.tag = Int(frequency) ?? 2
		self.updatedAtValue.text = self.formatUpdatedAtText()
		self.decimalValue.text = decimals.description
		self.keyboardClicksSwitch.isOn = isSounds
		self.autoUpdateRateSwitch.isOn = isAutoUpdateRate
		self.customRateSwitch.isOn = isCustomRate
		self.toggleCustomRateDetail(self.customRateSwitch.isOn)
		self.updateCustomRateDetail(rate: rate)
		self.customRateStepper.isContinuous = true
		self.customRateStepper.value = Double(rate)
		self.customRateStepper.stepValue = 1/pow(10, Double(decimals))
		self.use1000SeparatorSwitch.isOn = isUse1000Separator
		self.demoLabel.text = self.formatDemoText()
	}
	
	func formatDemoText() -> String {
		let shared = UserDefaults(suiteName: self.groupId)
		let decimals: Int = shared?.integer(forKey: "decimals") ?? 2
		let isUse1000Separator: Bool = shared?.bool(forKey: "thousandSeparator") ?? true

		var demoLabelText = "1234"
		if isUse1000Separator {
			demoLabelText = "1,234"
		}
		
		switch decimals {
		case 4:
			demoLabelText = "\(demoLabelText).3210"
		case 3:
			demoLabelText = "\(demoLabelText).210"
		case 2:
			demoLabelText = "\(demoLabelText).10"
		case 1:
			demoLabelText = "\(demoLabelText).0"
		default:
			break
		}
		
		return demoLabelText
	}
	
	func formatUpdatedAtText() -> String {
		let shared = UserDefaults(suiteName: self.groupId)
		let timeStamp = shared?.integer(forKey: "rateUpdatedAt") ?? 1463637809
		let timeInterval:TimeInterval = TimeInterval(timeStamp)
		let date = Date(timeIntervalSince1970: timeInterval)
		let dformatter = DateFormatter()
		dformatter.dateFormat = NSLocalizedString("dateTimeFormat", comment: "")//"yyyy-MM-dd HH:mm:ss"
		let updatedAtText = dformatter.string(from: date)
		
		return updatedAtText
	}
	
	func toggleCustomRateDetail(_ isOn: Bool) {
		self.customRateDetailLabel.textColor = isOn ? UIColor.black : UIColor.gray
		self.customRateStepper.tintColor = isOn ? UIColor.hex("0078fb") : UIColor.gray
		self.customRateStepper.isEnabled = isOn
	}
	
	func updateCustomRateDetail(rate: Float) {
		let shared = UserDefaults(suiteName: self.groupId)
		let fromCurrency: String = shared?.string(forKey: "fromCurrency") ?? "USD"
		let toCurrency: String = shared?.string(forKey: "toCurrency") ?? "CNY"
		let decimals: Int = shared?.integer(forKey: "decimals") ?? 2
		let fromMoney: String = String(format: "%.\(String(describing: decimals))f", arguments:[1.0])
		let toMoney = String(format: "%.\(decimals)f", arguments:[rate])

		self.customRateDetailLabel.text = "\(fromMoney) \(fromCurrency) = \(toMoney) \(toCurrency)"
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sectionHeaders[section]
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}

	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return self.sectionFooters[section]
	}
	
//	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//		return 30
//	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = UIColor.gray
		header.textLabel?.font = UIFont.systemFont(ofSize: 12)
		header.textLabel?.frame = header.frame
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		guard let footer = view as? UITableViewHeaderFooterView else { return }
		footer.textLabel?.textColor = UIColor.gray
		footer.textLabel?.font = UIFont.systemFont(ofSize: 12)
		footer.textLabel?.frame = footer.frame
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
	

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
