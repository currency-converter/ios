//
//  SettingsViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	let cellIdentifier: String = "SettingsTableCell"
	let items: [String] = [
		NSLocalizedString("sound", comment: ""),
		NSLocalizedString("decimals", comment: "")
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let backgroundView = UIView(frame: self.view.bounds)
		backgroundView.backgroundColor = UIColor.hex("121212")
		// 添加到当前视图控制器
		self.view.addSubview(backgroundView)
		
		// 导航条
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
		navigationBar.barTintColor = UIColor.black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		navigationBar.backgroundColor = UIColor.black
		backgroundView.addSubview(navigationBar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onSettingsDone(_:)))
		navigationitem.title = NSLocalizedString("settings", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
		
		let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-64), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UIColor.black
		tableView.register(SettingsTableCell.self, forCellReuseIdentifier: cellIdentifier)
		self.view.addSubview(tableView)
	}
	
	@objc func onSettingsDone(_ sender: UIButton) {
		//		self.navigationController?.popToRootViewController(animated: true)
		self.close()
	}
	
	func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	//返回表格行数
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	//分组数量
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsTableCell
		//print("items[indexPath.row]:", items[indexPath.row])
		cell.setValueForCell(item: items[indexPath.row], index: indexPath.row)
		
		return cell
	}
	
	//行高
	//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
	//		return 60
	//	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@objc func btnClick(_ sender: UIButton) {
		print("button click")
	}
	
	func pickupTableViewCell() {
		print("====pickupTableViewCell===")
	}
}
