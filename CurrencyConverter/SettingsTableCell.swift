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
		self.backgroundColor = UIColor.black
		
		title.frame = CGRect(x: 15, y: 0, width: 300, height: 44)
		title.textColor = UIColor.white
		box.addSubview(title)
		
		let switcher = UISwitch(frame: CGRect(x: 315, y: 7, width: 100, height: 44))
		switcher.addTarget(self, action: #selector(switchDidChange), for: .touchDown)
		switcher.isOn = true
		box.addSubview(switcher)
	
		self.addSubview(box)
	}
	
	func setValueForCell(item: String, index: Int) {
		title.text = "\(index) \(item)"
	}
	
	@objc func switchDidChange() {
		print("changed.")
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
