//
//  CurrencyInterfaceController.swift
//  Watch Extension
//
//  Created by zhi.zhong on 2019/5/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import WatchKit
import Foundation


class CurrencyInterfaceController: WKInterfaceController {
	
	@IBOutlet var currenciesTable: WKInterfaceTable!
	
	var currencies: [Currency] = []
	
	var pickType: String = "fromSymbol"
	
	var currentSymbol: String = Config.defaults["fromSymbol"] as! String
	
	var favorites: [String] = Config.defaults["favorites"] as! [String]
	
	override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		let params = context as! [String]
		self.pickType = params[0]
		self.currentSymbol = params[1]
		
		let shared = UserDefaults(suiteName: Config.groupId)
		let favorites: [String] = shared?.array(forKey: "favorites") as? [String] ?? Config.defaults["favorites"] as! [String]
		self.favorites = favorites
		for symbol in favorites {
			self.currencies.append(Currency(symbol: symbol))
		}
        
        // Configure interface objects here.
		currenciesTable.setNumberOfRows(currencies.count, withRowType: "CurrencyRow")
		
		for index in 0..<currenciesTable.numberOfRows {
			guard let controller = currenciesTable.rowController(at: index) as? CurrencyRowController else { continue }
			
			controller.currentSymbol = self.currentSymbol
			controller.currency = currencies[index]
		}
    }
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		let symbol = self.favorites[rowIndex]
		WatchSessionUtil.sharedManager.sendMessage(key: self.pickType, value: symbol)
		self.dismiss()
	}

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
		//self.dismiss(animated: true, completion: nil)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
