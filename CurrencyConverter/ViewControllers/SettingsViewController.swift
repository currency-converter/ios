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
	@IBOutlet weak var use1000SeparatorLabel: UILabel!
	@IBOutlet weak var decimalPlacesLabel: UILabel!
	@IBOutlet weak var decimalValue: UILabel!
	@IBOutlet weak var keyboardClicksSwitch: UISwitch!
	@IBOutlet weak var use1000SeparatorSwitch: UISwitch!
	
	let groupId: String = "group.com.zhongzhi.currencyconverter"
	
	var sectionHeaders:[String] = [
		NSLocalizedString("settings.sounds", comment: ""),
		NSLocalizedString("settings.rates", comment: ""),
		NSLocalizedString("settings.display", comment: "")
	]
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		render()

        // Do any additional setup after loading the view.
    }
	
	func onReady(key: String, value: String) {
		// 更新配置
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(value, forKey: key)
		//更新界面
		if key == "decimals" {
			decimalValue.text = value
		}
		
		if key == "ratesUpdatedFrequency" {
			frequencyValue.text = NSLocalizedString("settings.update.\(value)", comment: "")
			frequencyValue.tag = Int(value) ?? 2
		}
	}
	
	@IBAction func onKeyboardClicksChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "sounds")
	}

	@IBAction func onUse1000SeparatorChanged(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "thousandSeparator")
	}
	
	func render() {
		let shared = UserDefaults(suiteName: self.groupId)
		let frequency = shared?.string(forKey: "ratesUpdatedFrequency") ?? RatesUpdatedFrequency.daily.rawValue
		let frequencyText = NSLocalizedString("settings.update.\(frequency)", comment: "")
		let timeStamp = shared?.integer(forKey: "ratesUpdatedAt") ?? 1463637809
		let timeInterval:TimeInterval = TimeInterval(timeStamp)
		let date = Date(timeIntervalSince1970: timeInterval)
		let dformatter = DateFormatter()
		dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let updatedAtText = dformatter.string(from: date)
		let decimals = shared?.integer(forKey: "decimals")
		let isSounds = shared?.bool(forKey: "sounds")
		let isUse1000Separator = shared?.bool(forKey: "thousandSeparator")
		//设置界面文字
		self.navigationItem.title = NSLocalizedString("settings.title", comment: "")
		self.keyboardClicksLabel.text = NSLocalizedString("settings.keyboardClicks", comment: "")
		self.updatedAtLabel.text = NSLocalizedString("settings.updatedAt", comment: "")
		self.updateFrequencyLabel.text = NSLocalizedString("settings.updateFrequency", comment: "")
		self.use1000SeparatorLabel.text = NSLocalizedString("settings.use1000Separator", comment: "")
		self.decimalPlacesLabel.text = NSLocalizedString("settings.decimalPlaces", comment: "")
		//设置初始值
		self.frequencyValue.text = frequencyText
		self.frequencyValue.tag = Int(frequency) ?? 2
		self.updatedAtValue.text = updatedAtText
		self.decimalValue.text = decimals?.description
		self.keyboardClicksSwitch.isOn = isSounds ?? false
		self.use1000SeparatorSwitch.isOn = isUse1000Separator ?? true
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
		if indexPath.section == 2 && indexPath.row == 1 {
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
