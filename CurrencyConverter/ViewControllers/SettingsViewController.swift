//
//  SettingsViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController  {

	let groupId: String = "group.com.zhongzhi.currencyconverter"
	
	var decimalsLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.hex("121212")
		
		let shared = UserDefaults(suiteName: self.groupId)
		// 导航条
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
		navigationBar.barTintColor = UIColor.black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		navigationBar.backgroundColor = UIColor.black
		self.view.addSubview(navigationBar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onSettingsDone(_:)))
		rightBtn.tintColor = UIColor.hex("f09a37")
		navigationitem.title = NSLocalizedString("settings", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
		
		self.addLine(fromPoint: CGPoint(x: 0, y: 64), toPoint: CGPoint(x: UIScreen.main.bounds.width, y: 64))
		
		//Sounds
		let soundsLabel = UILabel(frame: CGRect(x: 15, y: 60, width: 150, height: 50))
		soundsLabel.text = NSLocalizedString("keyboardClicks", comment: "")
		soundsLabel.textColor = UIColor.white
		self.view.addSubview(soundsLabel)
		
		let soundsSwitch = UISwitch( frame: CGRect(x: UIScreen.main.bounds.width-70, y: 70, width: 50, height: 40))
		soundsSwitch.isOn = shared?.bool(forKey: "sounds") ?? false
		soundsSwitch.addTarget(self, action: #selector(soundsDidChange(_:)), for: .valueChanged)
		self.view.addSubview(soundsSwitch)
		
		self.addLine(fromPoint: CGPoint(x: 0, y: 110), toPoint: CGPoint(x: UIScreen.main.bounds.width, y: 110))
		
		//decimal
		decimalsLabel = UILabel(frame: CGRect(x: 15, y: 110, width: 150, height: 50))
		decimalsLabel.text = NSLocalizedString("decimalPlaces", comment: "") + "(\(shared?.integer(forKey: "decimals") ?? 0))"
		decimalsLabel.textColor = UIColor.white
		self.view.addSubview(decimalsLabel)
		
		let decimalsSlider = UISlider( frame: CGRect(x: 15, y: 160, width: UIScreen.main.bounds.width-30, height: 40))
		decimalsSlider.minimumValue = 0
		decimalsSlider.maximumValue = 4
		decimalsSlider.setValue(Float(shared?.integer(forKey: "decimals") ?? 0), animated: true)
		decimalsSlider.isContinuous = false
		decimalsSlider.addTarget(self, action: #selector(self.onDecimalChange(slider:)), for: UIControl.Event.valueChanged)
		self.view.addSubview(decimalsSlider)
		
		self.addLine(fromPoint: CGPoint(x: 15, y: 200), toPoint: CGPoint(x: UIScreen.main.bounds.width, y: 200))
		
		let thousandSeparatorLabel = UILabel(frame: CGRect(x: 15, y: 200, width: UIScreen.main.bounds.width-70, height: 50))
		thousandSeparatorLabel.text = NSLocalizedString("thousandSeparator", comment: "")
		thousandSeparatorLabel.textColor = UIColor.white
		self.view.addSubview(thousandSeparatorLabel)
		
		let thousandSeparatorSwitch = UISwitch( frame: CGRect(x: UIScreen.main.bounds.width-70, y: 210, width: 50, height: 40))
		thousandSeparatorSwitch.isOn = shared?.bool(forKey: "thousandSeparator") ?? true
		thousandSeparatorSwitch.addTarget(self, action: #selector(thousandSeparatorDidChange(_:)), for: .valueChanged)
		self.view.addSubview(thousandSeparatorSwitch)
		
		self.addLine(fromPoint: CGPoint(x: 0, y: 250), toPoint: CGPoint(x: UIScreen.main.bounds.width, y: 250))
		
	}
	
	func addLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
		let line = CAShapeLayer()
		let linePath = UIBezierPath()
		linePath.move(to: start)
		linePath.addLine(to: end)
		line.path = linePath.cgPath
		line.strokeColor = UIColor.hex("333333").cgColor
		line.lineWidth = 1
		line.lineJoin = CAShapeLayerLineJoin.round
		self.view.layer.addSublayer(line)
	}
	
	func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func onDecimalChange(slider:UISlider) {
		let shared = UserDefaults(suiteName: self.groupId)
		let decimals = lroundf(slider.value)
		slider.setValue(Float(decimals), animated: true)
		decimalsLabel.text = NSLocalizedString("decimalPlaces", comment: "") + "(\(decimals))"
		shared?.set(decimals, forKey: "decimals")
	}
	
	@objc func onSettingsDone(_ sender: UIButton) {
		self.close()
	}
	
	@objc func soundsDidChange(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "sounds")
	}
	
	@objc func thousandSeparatorDidChange(_ sender: UISwitch) {
		let shared = UserDefaults(suiteName: self.groupId)
		shared?.set(sender.isOn, forKey: "thousandSeparator")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}
