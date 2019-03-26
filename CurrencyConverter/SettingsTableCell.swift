//
//  SettingsTableCell.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

protocol PickupTableViewCellDelegate: NSObjectProtocol {
	func pickupTableViewCell()
}

class SettingsTableCell: UITableViewCell {
	var title = UILabel()
	lazy var box = UIView()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.selectionStyle = .none
		
		title.frame = CGRect(x: 15, y: 0, width: 300, height: 44)
		box.addSubview(title)
		
//		let switcher = UISwitch(frame: CGRect(x: 315, y: 7, width: 100, height: 44))
//		switcher.addTarget(self, action: #selector(switchDidChange(_:)), for: .touchDown)
//		switcher.isOn = true
//		box.addSubview(switcher)
		
//		let btn = UIButton(frame: CGRect(x: 315, y: 7, width: 100, height: 44))
//		btn.setTitle("test", for: .normal)
//		btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchDown)
//		box.addSubview(btn)
		let button = UIButton(type: .custom)
		button.frame = CGRect(x:315, y:0, width:80, height:30)
		button.setTitle("FirstBtn", for: .normal)
		button.setTitleColor(UIColor.red, for: .normal)
		button.backgroundColor = UIColor.green
		button.addTarget(self, action: #selector(self.btnClick), for: .touchUpInside)
		box.addSubview(button)
		self.addSubview(box)
	}
	
	func setValueForCell(item: String, index: Int) {
		title.text = "\(index) \(item)"
	}
	
	@objc func btnClick() {
		print("clicked.")
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
//	override func setSelected(_ selected: Bool, animated: Bool) {
//		super.setSelected(selected, animated: animated)
//
//		// Configure the view for the selected state
//	}
}
