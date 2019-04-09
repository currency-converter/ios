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
		NSLocalizedString("favoriteCurrencies", comment: ""),
		NSLocalizedString("allCurrencies", comment: "")
	]
	
	var currencyNames:Dictionary = [
		"": NSLocalizedString("unknow", comment: ""),
		"AED": NSLocalizedString("AED", comment: ""),
		"AUD": NSLocalizedString("AUD", comment: ""),
		"BGN": NSLocalizedString("BGN", comment: ""),
		"BHD": NSLocalizedString("BHD", comment: ""),
		"BND": NSLocalizedString("BND", comment: ""),
		"BRL": NSLocalizedString("BRL", comment: ""),
		"BYN": NSLocalizedString("BYN", comment: ""),
		"CAD": NSLocalizedString("CAD", comment: ""),
		"CHF": NSLocalizedString("CHF", comment: ""),
		"CLP": NSLocalizedString("CLP", comment: ""),
		"CNY": NSLocalizedString("CNY", comment: ""),
		"COP": NSLocalizedString("COP", comment: ""),
		"CRC": NSLocalizedString("CRC", comment: ""),
		"CZK": NSLocalizedString("CZK", comment: ""),
		"DKK": NSLocalizedString("DKK", comment: ""),
		"DZD": NSLocalizedString("DZD", comment: ""),
		"EGP": NSLocalizedString("EGP", comment: ""),
		"EUR": NSLocalizedString("EUR", comment: ""),
		"GBP": NSLocalizedString("GBP", comment: ""),
		"HKD": NSLocalizedString("HKD", comment: ""),
		"HRK": NSLocalizedString("HRK", comment: ""),
		"HUF": NSLocalizedString("HUF", comment: ""),
		"IDR": NSLocalizedString("IDR", comment: ""),
		"ILS": NSLocalizedString("ILS", comment: ""),
		"INR": NSLocalizedString("INR", comment: ""),
		"IQD": NSLocalizedString("IQD", comment: ""),
		"ISK": NSLocalizedString("ISK", comment: ""),
		"JOD": NSLocalizedString("JOD", comment: ""),
		"JPY": NSLocalizedString("JPY", comment: ""),
		"KES": NSLocalizedString("KES", comment: ""),
		"KHR": NSLocalizedString("KHR", comment: ""),
		"KRW": NSLocalizedString("KRW", comment: ""),
		"KWD": NSLocalizedString("KWD", comment: ""),
		"LAK": NSLocalizedString("LAK", comment: ""),
		"LBP": NSLocalizedString("LBP", comment: ""),
		"LKR": NSLocalizedString("LKR", comment: ""),
		"MAD": NSLocalizedString("MAD", comment: ""),
		"MMK": NSLocalizedString("MMK", comment: ""),
		"MOP": NSLocalizedString("MOP", comment: ""),
		"MXN": NSLocalizedString("MXN", comment: ""),
		"MYR": NSLocalizedString("MYR", comment: ""),
		"NOK": NSLocalizedString("NOK", comment: ""),
		"NZD": NSLocalizedString("NZD", comment: ""),
		"OMR": NSLocalizedString("OMR", comment: ""),
		"PHP": NSLocalizedString("PHP", comment: ""),
		"PLN": NSLocalizedString("PLN", comment: ""),
		"QAR": NSLocalizedString("QAR", comment: ""),
		"RON": NSLocalizedString("RON", comment: ""),
		"RSD": NSLocalizedString("RSD", comment: ""),
		"RUB": NSLocalizedString("RUB", comment: ""),
		"SAR": NSLocalizedString("SAR", comment: ""),
		"SEK": NSLocalizedString("SEK", comment: ""),
		"SGD": NSLocalizedString("SGD", comment: ""),
		"SYP": NSLocalizedString("SYP", comment: ""),
		"THB": NSLocalizedString("THB", comment: ""),
		"TRY": NSLocalizedString("TRY", comment: ""),
		"TWD": NSLocalizedString("TWD", comment: ""),
		"TZS": NSLocalizedString("TZS", comment: ""),
		"UGX": NSLocalizedString("UGX", comment: ""),
		"USD": NSLocalizedString("USD", comment: ""),
		"VND": NSLocalizedString("VND", comment: ""),
		"ZAR": NSLocalizedString("ZAR", comment: "")
	]
	
	var currencyTableView: UITableView!
	var searchController: UISearchController!
	
	var searchResults:Array = [String]()
	
	// 当前选中的货币，接收主窗口传递过来的值
	var currentCurrency: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.hex("121212")
		
		self.allCurrencies[0] = UserDefaults.standard.array(forKey: "favorites") as? [String]
		
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		// 导航条
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
		navigationBar.barTintColor = UIColor.black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
		navigationBar.backgroundColor = UIColor.black
		self.view.addSubview(navigationBar)
		
		let navigationitem = UINavigationItem()
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onPickerDone(_:)))
		rightBtn.tintColor = UIColor.hex("f09a37")
		navigationitem.title = NSLocalizedString("selectCurrency", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
		
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.backgroundColor = UIColor.hex("121212")
		// Setup the Search Controller
		searchController.searchResultsUpdater = self
		//搜索时，取消背景变模糊
		searchController.obscuresBackgroundDuringPresentation = true
		//搜索时，取消背景变暗色
		searchController.dimsBackgroundDuringPresentation = true
		definesPresentationContext = false
		//搜索时，取消隐藏导航条
		//searchController.hidesNavigationBarDuringPresentation = false
		self.searchController = searchController
		
		// 搜索框
		let searchBar = searchController.searchBar
//		searchBar.barStyle = .black
		searchBar.delegate = self
		guard let searchTextFeild = searchBar.value(forKey: "searchField") as? UITextField else {
			return
		}
		searchTextFeild.backgroundColor = UIColor.black
		// 修改输入文字的颜色
		searchTextFeild.textColor = UIColor.white
		searchTextFeild.tintColor = UIColor.hex("f09a37")
		// 输入内容大写
		//searchTextFeild.autocapitalizationType = .allCharacters
		// 设置取消按钮字体颜色
		let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hex("f09a37")]
		UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
		
		let tableView = UITableView(frame: CGRect(x: 0, y: 64, width: viewBounds.width, height: viewBounds.height-64), style: .plain)
		//tableView.backgroundColor = UIColor.black
		let tableViewBackground = UIView(frame: self.view.bounds)
		tableViewBackground.backgroundColor = UIColor.black
		tableView.backgroundView = tableViewBackground
		//tableView.separatorColor = UIColor.hex("090909")
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableHeaderView = searchController.searchBar
		//去掉没有数据显示部分多余的分隔线
		tableView.tableFooterView =  UIView.init(frame: CGRect.zero)
		//将分隔线offset设为零，即将分割线拉满屏幕
		//		tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		//设置分隔线颜色
		tableView.separatorColor = UIColor.hex("333333")
		//进入页面时隐藏searchbar
		//tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
		self.view.addSubview(tableView)
		self.currencyTableView = tableView
	}
	
	@objc func onPickerDone(_ sender: UIButton) {
		self.close()
	}
	
	// 收藏/取消收藏
	@objc func toggleFavorite(_ sender: UITapGestureRecognizer) {
		var favorites:[String] = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? [String]()
		let currency = sender.view?.accessibilityLabel ?? ""
		if favorites.contains(currency) {
			favorites = favorites.filter {$0 != currency}
		} else {
			favorites.append(currency)
		}
		UserDefaults.standard.set(favorites, forKey: "favorites")
		
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
		}
		let data = self.allCurrencies[section] ?? [String]()
		return data.count
	}
	
	//分组数量
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.searchController?.isActive ?? false ? 1 : self.allCurrencies.count
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.black
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = UIColor.white
		header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
		header.subviews[0].backgroundColor = UIColor.hex("121212")
	}
	
	//设置头视图的View
	//	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	//		let view = UIView()
	//		view.backgroundColor = UIColor.hex("121212")
	//		let textLabel = UITextField(frame: CGRect(x: 15, y: 5, width: UIScreen.main.bounds.width-15, height: 20))
	//		textLabel.textColor = UIColor.white
	//		textLabel.font = UIFont.boldSystemFont(ofSize: 18)
	//		textLabel.text = adHeaders[section]
	//
	//		view.addSubview(textLabel)
	//		return view
	//	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionId:Int = indexPath.section
		let currency = self.searchController?.isActive ?? false ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		let isFav: Bool = allCurrencies[0]?.contains(currency ?? "") ?? false
		let unicode: String = isFav ? "B" : "C"
		
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CellID")
		cell.preservesSuperviewLayoutMargins = false
		cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		cell.layoutMargins = UIEdgeInsets.zero
		cell.backgroundColor = UIColor.black
		cell.selectionStyle = .blue
		let cellBackgroundView = UIView()
		cellBackgroundView.backgroundColor = UIColor.hex("333333")
		cell.selectedBackgroundView = cellBackgroundView

		// icon
		cell.imageView?.image = UIImage.iconFont(fontSize: 40, unicode: unicode, color: .white)
		cell.imageView?.accessibilityLabel = currency
		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleFavorite))
		cell.imageView?.addGestureRecognizer(singleTapGesture)
		cell.imageView?.isUserInteractionEnabled = true

		// label
		cell.textLabel?.text = self.currencyNames[currency ?? ""]
		cell.textLabel?.textColor = UIColor.white
		//cell.textLabel?.highlightedTextColor = UIColor.black

		// detail
		cell.detailTextLabel?.textColor = UIColor.white
		//cell.detailTextLabel?.highlightedTextColor = UIColor.black
		cell.detailTextLabel?.text = currency
		cell.detailTextLabel?.textAlignment = .natural

		// accessory
		cell.accessoryType = cell.textLabel?.text == currentCurrency ? .checkmark : .none
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
		if self.searchController?.isActive ?? false {
			return ""
		}
		return self.adHeaders[section]
	}
}

extension CurrencyPickerViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		self.searchResults.removeAll(keepingCapacity: false)

		let keyword:String = searchController.searchBar.text!.uppercased()
		print(keyword)
		//从key和value中都找一遍
		for currency in currencyNames {
			if currency.key.contains(keyword) || currency.value.uppercased().contains(keyword) {
				self.searchResults.append(currency.key)
			}
		}

		self.currencyTableView?.reloadData()
		//self.currencyTableView?.setContentOffset(CGPoint.zero, animated: false)
		
		if searchController.searchBar.text?.count ?? 0 > 0 && self.searchResults.count == 0 {
			let noDataLabel = UILabel(frame: self.currencyTableView.frame)
			noDataLabel.text = NSLocalizedString("noResults", comment: "")
			noDataLabel.textAlignment = .center
			noDataLabel.textColor = UIColor.gray
			noDataLabel.font = UIFont.boldSystemFont(ofSize: 18)
			noDataLabel.backgroundColor = UIColor.black
			self.currencyTableView.separatorStyle = .none
			self.currencyTableView.backgroundView = noDataLabel
		} else {
			let tableViewBackground = UIView(frame: self.view.bounds)
			tableViewBackground.backgroundColor = UIColor.black
			self.currencyTableView.backgroundView = tableViewBackground
		}
	}
}
