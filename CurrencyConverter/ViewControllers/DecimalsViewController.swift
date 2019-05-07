//
//  DecimalsViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/12.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class DecimalsViewController: UITableViewController {
	
	var delegate: CallbackDelegate?
	
	var defaultValue: String!
	
	var themeIndex: Int!
	
	var values: [String] = ["0", "1", "2", "3", "4"]

    override func viewDidLoad() {
        super.viewDidLoad()
		
		initConfig()
		
		render()

        // Do any additional setup after loading the view.
    }
	
	func initConfig() {
		let shared = UserDefaults(suiteName: Config.groupId)
		self.themeIndex = shared?.integer(forKey: "theme")
	}
	
	func render() {
		self.view.backgroundColor = Theme.appBackgroundColor[themeIndex]
		navigationItem.title = NSLocalizedString("settings.decimalPlaces", comment: "")
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return values.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let value = values[indexPath.row]
		
		let cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
		cell.preservesSuperviewLayoutMargins = false
		cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		cell.layoutMargins = UIEdgeInsets.zero
		cell.selectionStyle = .none
		cell.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		
		// label
		cell.textLabel?.text = value
		cell.textLabel?.textColor = Theme.cellTextColor[themeIndex]
		
		// accessory
		cell.accessoryType = value == defaultValue ? .checkmark : .none
		cell.tintColor = UIColor.loquatYellow
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//获取当前选中的单元格
		let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
		//print(cell.accessoryType == .checkmark)
		if cell.accessoryType != .checkmark {
			//取消已经选中的单元格
			for c in self.tableView.visibleCells {
				c.accessoryType = .none
			}
			cell.accessoryType = .checkmark
		}
		if let data = cell.textLabel?.text {
			self.delegate?.onReady(key: "decimals", value: data)
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
