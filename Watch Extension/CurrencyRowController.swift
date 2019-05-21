//
//  CurrencyRowController.swift
//  Watch Extension
//
//  Created by zhi.zhong on 2019/5/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import WatchKit

class CurrencyRowController: NSObject {
	@IBOutlet var flagImage: WKInterfaceImage!
	@IBOutlet var symbolLabel: WKInterfaceLabel!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var itemGroup: WKInterfaceGroup!
	
	var currentSymbol: String!
	
	var currency: Currency? {
		// 2
		didSet {
			// 3
			guard let currency = currency else { return }
			// 4
			symbolLabel.setText(currency.symbol)
			nameLabel.setText(NSLocalizedString(currency.symbol, comment: ""))
			if let flagPath = Bundle.main.path(forResource: currency.symbol, ofType: "png") {
				flagImage.setImage(UIImage(contentsOfFile: flagPath))
			}
			
			if currentSymbol == currency.symbol {
				itemGroup.setBackgroundColor(UIColor.loquatYellow)
			}
		}
	}
}
