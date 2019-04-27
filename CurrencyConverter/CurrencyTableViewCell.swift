//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/4/26.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

protocol myTableDelegate: NSObjectProtocol {
	func toggleFavorite(symbol: String)
}

class CurrencyTableViewCell: UITableViewCell {
	var delegate: myTableDelegate?
	
	lazy var box = UIView()
	var favorite = UILabel()
	var flag = UIImageView()
	var symbol = UILabel()
	var name = UILabel()
	var rate = UILabel()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.layout()
	}
	
	func layout() {
		self.backgroundColor = UIColor.black
		self.selectionStyle = .none
		self.tintColor = UIColor.loquatYellow
		
		let boxPadding: CGFloat = 15
		let flagWidth: CGFloat = 48
		let flagHeight: CGFloat = 36
		let cellHeight: CGFloat = boxPadding * 2 + flagHeight

		box.frame = CGRect(x: boxPadding, y: boxPadding, width: UIScreen.main.bounds.width - 2 * boxPadding, height: cellHeight - 2 * boxPadding)
		//box.backgroundColor = UIColor.yellow
		self.addSubview(box)
		
		favorite.frame = CGRect(x: 0, y: 0, width: 30, height: 36)
		favorite.textColor = UIColor.white
		favorite.font = UIFont(name: "CurrencyConverter", size: 42)
		favorite.isUserInteractionEnabled = true
		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite))
		favorite.addGestureRecognizer(singleTapGesture)
		box.addSubview(favorite)

		flag.frame = CGRect(x: 36, y: 0, width: flagWidth, height: flagHeight)
		//flag.backgroundColor = UIColor.red
		box.addSubview(flag)
		
		symbol.frame = CGRect(x: 90, y: 0, width: 100, height: 20)
		//symbol.backgroundColor = UIColor.yellow
		symbol.textColor = UIColor.white
		symbol.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		box.addSubview(symbol)
		
		name.frame = CGRect(x: 90, y: 20, width: box.frame.width - 48 - 5, height: 16)
		//country.backgroundColor = UIColor.green
		name.textColor = UIColor.white
		name.font = UIFont.systemFont(ofSize: 12)
		box.addSubview(name)
		
		rate.frame = CGRect(x: box.frame.width - 100, y: 0, width: 100, height: 20)
		//rate.backgroundColor = UIColor.red
		rate.font = UIFont.systemFont(ofSize: 14)
		rate.textAlignment = .right
		rate.textColor = UIColor.white
		box.addSubview(rate)
	}
	
	func setValueForCell(currency: Currency, isSelected: Bool) {
		let formattor = NumberFormatter()
		formattor.numberStyle = .decimal
		let rateText: String = formattor.string(from: currency.rate ?? 1) ?? ""
		
		self.symbol.text = currency.symbol
		self.name.text = currency.name
		self.rate.text = rateText
		if let flagPath = Bundle.main.path(forResource: currency.symbol, ofType: "png") {
			self.flag.image = UIImage(contentsOfFile: flagPath)
		}
		self.favorite.text = currency.isFav ?? false ? "B" : "C"
		self.favorite.accessibilityLabel = currency.symbol
		
		//self.accessoryType = isSelected ? .checkmark : .none
		self.isSelected = isSelected
		
		let cellBackgroundView = UIView()
		cellBackgroundView.backgroundColor = UIColor.hex("854b00")
		self.selectedBackgroundView = cellBackgroundView

	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	@objc func toggleFavorite(_ sender: UITapGestureRecognizer) {
		let symbol: String = sender.view!.accessibilityLabel!
		delegate?.toggleFavorite(symbol: symbol)
	}
}

