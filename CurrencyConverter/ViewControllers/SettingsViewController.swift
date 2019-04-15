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
	@IBOutlet weak var updateFrequencyLabel: UILabel!
	@IBOutlet weak var updatedAtLabel: UILabel!
	@IBOutlet weak var updatedAtValue: UILabel!
	@IBOutlet weak var frequencyValue: UILabel!
	@IBOutlet weak var demoLabel: UILabel!
	@IBOutlet weak var use1000SeparatorLabel: UILabel!
	@IBOutlet weak var decimalPlacesLabel: UILabel!
	@IBOutlet weak var decimalValue: UILabel!
	@IBOutlet weak var keyboardClicksSwitch: UISwitch!
	@IBOutlet weak var use1000SeparatorSwitch: UISwitch!
	@IBOutlet weak var loading: UIActivityIndicatorView!
	@IBOutlet weak var updateImmediatelyButton: UIButton!
	
	let groupId: String = "group.com.zhongzhi.currencyconverter"
	
	var sectionHeaders:[String] = [
		NSLocalizedString("settings.sounds", comment: ""),
		NSLocalizedString("settings.rate", comment: ""),
		NSLocalizedString("settings.display", comment: "")
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
		let shared = UserDefaults(suiteName: self.groupId)
		let frequency = shared?.string(forKey: "rateUpdatedFrequency") ?? RateUpdatedFrequency.daily.rawValue
		let frequencyText = NSLocalizedString("settings.update.\(frequency)", comment: "")
		let decimals = shared?.integer(forKey: "decimals")
		let isSounds = shared?.bool(forKey: "sounds")
		let isUse1000Separator = shared?.bool(forKey: "thousandSeparator")
		//设置界面文字
		self.navigationController?.isNavigationBarHidden = false
		self.navigationItem.title = NSLocalizedString("settings.title", comment: "")
		self.keyboardClicksLabel.text = NSLocalizedString("settings.keyboardClicks", comment: "")
		self.updatedAtLabel.text = NSLocalizedString("settings.updatedAt", comment: "")
		self.updateFrequencyLabel.text = NSLocalizedString("settings.updateFrequency", comment: "")
		self.use1000SeparatorLabel.text = NSLocalizedString("settings.use1000Separator", comment: "")
		self.decimalPlacesLabel.text = NSLocalizedString("settings.decimalPlaces", comment: "")
		self.updateImmediatelyButton.setTitle(NSLocalizedString("settings.updateImmediately", comment: ""), for: .normal)
		//设置初始值
		self.frequencyValue.text = frequencyText
		self.frequencyValue.tag = Int(frequency) ?? 2
		self.updatedAtValue.text = self.formatUpdatedAtText()
		self.decimalValue.text = decimals?.description
		self.keyboardClicksSwitch.isOn = isSounds ?? false
		self.use1000SeparatorSwitch.isOn = isUse1000Separator ?? true
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
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.sectionHeaders[section]
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 40
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//小数位数
		if indexPath.section == 2 && indexPath.row == 2 {
			self.performSegue(withIdentifier: "showDecimalSegue", sender: self.decimalValue.text)
		}
		//更新频率
		if indexPath.section == 1 && indexPath.row == 0 {
			self.performSegue(withIdentifier: "showFrequencySegue", sender: self.frequencyValue.tag.description)
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
