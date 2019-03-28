//
//  CurrencyPickerViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

protocol myDelegate {
	func currencyCellClickCallback(data: String)
}

class CurrencyPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
	var delegate: myDelegate?
	
	var allCurrencies = [
		0: [String](),
		1: [String]([
			"AED", "AUD", "BGN", "BHD", "BND", "BRL", "BYN", "CAD", "CHF", "CLP",
			"CNY", "COP", "CRC", "CZK", "DKK", "DZD", "EGP", "EUR", "GBP", "HKD",
			"HRK", "HUF", "IDR", "ILS", "INR", "IQD", "ISK", "JOD", "JPY", "KES",
			"KHR", "KRW", "KWD", "LAK", "LBP", "LKR", "MAD", "MMK", "MOP", "MXN",
			"MYR", "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON", "RSD", "RUB",
			"SAR", "SEK", "SGD", "SYP", "THB", "TRY", "TWD", "TZS", "UGX", "USD",
			"VND", "ZAR"
			])
	]
	
	var adHeaders:[String] = [
		"Favorite Currencies",
		"All Currencies"
	]
	
	var currencyNames:Dictionary = [
		"": "Unknow",
		"AED": "United Arab Emirates Dirham",
		"AUD": "Australian Dollar",
		"BGN": "Bulgarian Lev",
		"BHD": "Bahraini Dinar",
		"BND": "Brunei Dollar",
		"BRL": "Brazilian Real",
		"BYN": "Belarusian Ruble",
		"CAD": "Canadian Dollar",
		"CHF": "Swiss Franc",
		"CLP": "Chilean Peso",
		"CNY": "Chinese Yuan",
		"COP": "Colombian Pesa",
		"CRC": "Costa Rican Colon",
		"CZK": "Czech Koruna",
		"DKK": "Danish Krone",
		"DZD": "Algerian Dinar",
		"EGP": "Egyptian Pound",
		"EUR": "Euro",
		"GBP": "British Pound",
		"HKD": "Hong Kong Dollar",
		"HRK": "Croatian Kuna",
		"HUF": "Hungarian Forint",
		"IDR": "Indonesian Rupiah",
		"ILS": "Israeli New Shekel",
		"INR": "Indian Rupee",
		"IQD": "Iraqi Dinar",
		"ISK": "Icelandic Krona",
		"JOD": "Jordanian Dinar",
		"JPY": "Japanese Yen",
		"KES": "Kenyan Shilling",
		"KHR": "Cambodian Riel",
		"KRW": "South Korean Won",
		"KWD": "Kuwaiti Dinar",
		"LAK": "Laotian Kip",
		"LBP": "Lebanese Pound",
		"LKR": "Sri Lankan Rupee",
		"MAD": "Moroccan Dirham",
		"MMK": "Myanmar Kyat",
		"MOP": "Macanese Pataca",
		"MXN": "Mexican Peso",
		"MYR": "Malaysian Ringgit",
		"NOK": "Norwegian Krone",
		"NZD": "New Zealand Dollar",
		"OMR": "Omani Rial",
		"PHP": "Philippine Peso",
		"PLN": "Polish Zloty",
		"QAR": "Qatari Rial",
		"RON": "Romanian Leu",
		"RSD": "Serbian Dinar",
		"RUB": "Russian Ruble",
		"SAR": "Saudi Riyal",
		"SEK": "Swedish Krona",
		"SGD": "Singapore Dollar",
		"SYP": "Syrian Pound",
		"THB": "Thai Baht",
		"TRY": "Turkish Lira",
		"TWD": "New Taiwan Dollar",
		"TZS": "Tanzanian Shilling",
		"UGX": "Ugandan Shilling",
		"USD": "US Dollar",
		"VND": "Vietnamese Dong",
		"ZAR": "South African Rand"
	]
	
	var currencyTableView: UITableView!
	var searchController: UISearchController!
	
	var searchResults:Array = [String]()
	
	// 当前选中的货币，接收主窗口传递过来的值
	var currentCurrency: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let configs:NSDictionary? = NSDictionary(contentsOfFile: ViewController.propertyList)
		self.allCurrencies[0] = configs?["favorites"] as? [String]
		
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		let backgroundView = UIView(frame: self.view.bounds)
		backgroundView.backgroundColor = UIColor.hex("121212")
		backgroundView.clipsToBounds = true
		self.view.addSubview(backgroundView)
		
		// 导航条
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
		navigationBar.barTintColor = UIColor.black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		navigationBar.backgroundColor = UIColor.black
		backgroundView.addSubview(navigationBar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onPickerDone(_:)))
//		navigationitem.title = "Settings"
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
		
		let searchController = UISearchController(searchResultsController: nil)
		//searchController.searchBar.searchBarStyle = .minimal
		// Setup the Search Controller
		searchController.searchResultsUpdater = self
		//搜索时，取消背景变模糊
		searchController.obscuresBackgroundDuringPresentation = false
		//搜索时，取消背景变暗色
		searchController.dimsBackgroundDuringPresentation = false
		//搜索时，取消隐藏导航条
		//searchController.hidesNavigationBarDuringPresentation = false
		self.searchController = searchController

		// 搜索框
		let searchBar = searchController.searchBar
		searchBar.barStyle = .black
		searchBar.delegate = self
		let searchTextFeild = searchBar.subviews.first?.subviews[1] as! UITextField
		searchTextFeild.backgroundColor = UIColor.black
		// 修改输入文字的颜色
		searchTextFeild.textColor = UIColor.white
		// 输入内容大写
		searchTextFeild.autocapitalizationType = .allCharacters
	
		let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: viewBounds.width, height: viewBounds.height-64), style: .plain)
		tableView.tableHeaderView = searchController.searchBar
		tableView.backgroundColor = UIColor.black
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
		backgroundView.addSubview(tableView)
		self.currencyTableView = tableView
	}
	
	@objc func onPickerDone(_ sender: UIButton) {
		self.close()
	}
	
	// 收藏/取消收藏
	@objc func toggleFavorite(_ sender: UITapGestureRecognizer) {
		let configs:NSDictionary? = NSDictionary(contentsOfFile: ViewController.propertyList)
		var favorites:[String] = configs?["favorites"] as? [String] ?? [String]()
		let currency = sender.view?.accessibilityLabel ?? ""
		if favorites.contains(currency) {
			favorites = favorites.filter {$0 != currency}
		} else {
			favorites.append(currency)
		}
		configs?.setValue(favorites, forKey: "favorites")
		configs?.write(toFile: ViewController.propertyList, atomically:true)

		self.allCurrencies[0] = favorites
		self.currencyTableView.reloadData()
	}
	
	func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	//返回表格行数
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.searchController?.isActive ?? false {
			return self.searchResults.count
		} else {
			let data = self.allCurrencies[section] ?? [String]()
			return data.count
		}
	}
	
	//分组数量
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.searchController?.isActive ?? false ? 1 : self.allCurrencies.count
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.black
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = UIColor.white
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionId:Int = indexPath.section
		let currency = self.searchController?.isActive ?? false ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
		cell.selectionStyle = .none
		cell.detailTextLabel?.textColor = UIColor.white
		cell.detailTextLabel?.text = self.currencyNames[currency ?? ""]
		cell.detailTextLabel?.textAlignment = .natural
		cell.textLabel?.text = currency
		cell.textLabel?.textColor = UIColor.white
		if (cell.textLabel?.text == currentCurrency) {
			cell.backgroundColor = UIColor.hex("222222")
		} else {
			cell.backgroundColor = UIColor.black
		}
		cell.imageView?.image = UIImage.iconFont(fontSize: 40, unicode: (allCurrencies[0]?.contains(currency ?? "") ?? false) ? "B" : "C", color: .white)
		cell.imageView?.accessibilityLabel = currency
		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite))
		cell.imageView?.addGestureRecognizer(singleTapGesture)
		cell.imageView?.isUserInteractionEnabled = true
		return cell
	}
	
	//选中cell时触发这个代理
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//取消选中的样式
		tableView.deselectRow(at: indexPath, animated: true)

		//获取当前选中的单元格
		let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
		let text = cell.textLabel?.text
		if let text = text {
			self.delegate?.currencyCellClickCallback(data: text)
		}
		
		self.close()
	}
	
	//行高
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 60
	}
	
	// UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.searchController?.isActive ?? false ? "" : self.adHeaders[section]
	}
}

extension CurrencyPickerViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		print("search keyword:", searchController.searchBar.text!)
		self.searchResults.removeAll()
		self.allCurrencies[1]?.forEach {
			item in
			if item.contains(searchController.searchBar.text!) {
				self.searchResults.append(item)
			}
		}
		self.currencyTableView?.reloadData()
	}
}
