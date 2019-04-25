//
//  CurrencyPickerViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class CurrencyPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
	
	var allCurrencies = [
		0: [String]([]),
		1: [String]([])
	]
	
	var adHeaders:[String] = [
		NSLocalizedString("currencyPicker.favoriteCurrencies", comment: ""),
		NSLocalizedString("currencyPicker.allCurrencies", comment: "")
	]
	
	var currencyNames: [String:String] = [:]
	
	var currencyTableView: UITableView!
	var searchController: UISearchController!
	
	var searchResults:Array = [String]()
	
	// 当前选中的货币，接收主窗口传递过来的值
	var currencySymbol: String = ""
	var currencyType: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let shared = UserDefaults(suiteName: Config.groupId)
		if let favorites = shared?.array(forKey: "favorites") as? [String] {
			self.allCurrencies[0] = favorites
		} else {
			self.allCurrencies[0] = Config.defaults["favorites"] as? [String]
		}
		self.allCurrencies[1] = Array((Config.defaults["rates"] as! [String: [String: NSNumber]]).keys)
		
		self.view.backgroundColor = UIColor.appBackgroundColor
		
		self.initCurrencyNames()
		
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
		rightBtn.tintColor = UIColor.loquatYellow
		navigationitem.title = NSLocalizedString("currencyPicker.title", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		navigationBar.pushItem(navigationitem, animated: true)
		
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.backgroundColor = UIColor.appBackgroundColor
		// Setup the Search Controller
		searchController.searchResultsUpdater = self
		//搜索时，取消背景变模糊
		//searchController.obscuresBackgroundDuringPresentation = true
		//搜索时取消背景变暗色，否则cell上的点击事件触发不了
		searchController.dimsBackgroundDuringPresentation = false
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
		searchTextFeild.tintColor = UIColor.loquatYellow
		// 输入内容大写
		//searchTextFeild.autocapitalizationType = .allCharacters
		// 设置取消按钮字体颜色
		let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.loquatYellow]
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
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
		self.view.addSubview(tableView)
		self.currencyTableView = tableView
	}
	
	@objc func onPickerDone(_ sender: UIButton) {
		self.close()
	}
	
	// 收藏/取消收藏
	@objc func toggleFavorite(_ sender: UITapGestureRecognizer) {
		let shared = UserDefaults(suiteName: Config.groupId)
		var favorites:[String] = shared?.array(forKey: "favorites") as? [String] ?? [String]()
		let currency = sender.view?.accessibilityLabel ?? ""
		if favorites.contains(currency) {
			favorites = favorites.filter {$0 != currency}
		} else {
			favorites.append(currency)
		}
		shared?.set(favorites, forKey: "favorites")
		
		self.allCurrencies[0] = favorites
		self.currencyTableView.reloadData()
	}
	
	func initCurrencyNames() {
		currencyNames[""] = NSLocalizedString("currencyPicker.unknow", comment: "")
		for currency in allCurrencies[1]! {
			currencyNames[currency] = NSLocalizedString(currency, comment: "")
		}
	}
	
	func close() {
		self.dismiss(animated: true, completion: nil)
	}
	
	//返回表格行数
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.searchBar.text != "" {
			return self.searchResults.count
		}
		let data = self.allCurrencies[section] ?? [String]()
		return data.count
	}
	
	//分组数量
	func numberOfSections(in tableView: UITableView) -> Int {
		return searchController.searchBar.text != "" ? 1 : self.allCurrencies.count
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		view.tintColor = UIColor.black
		let header = view as! UITableViewHeaderFooterView
		header.textLabel?.textColor = UIColor.white
		header.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
		header.subviews[0].backgroundColor = UIColor.appBackgroundColor
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionId:Int = indexPath.section
		let currency = searchController.searchBar.text != "" ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		let isFav: Bool = allCurrencies[0]?.contains(currency ?? "") ?? false
		let unicode: String = isFav ? "B" : "C"
		
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
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
		cell.accessoryType = cell.detailTextLabel?.text == currencySymbol ? .checkmark : .none
		cell.tintColor = UIColor.loquatYellow
		return cell
	}
	
	//选中cell时触发这个代理
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//取消选中的样式
		tableView.deselectRow(at: indexPath, animated: true)
		
		//获取当前选中的单元格
		let cell:UITableViewCell! = tableView.cellForRow(at: indexPath)
		let text = cell.detailTextLabel?.text
		if let data = text?.description {
			let key: String = "\(currencyType)Symbol"
			let shared = UserDefaults(suiteName: Config.groupId)
			shared?.set(data, forKey: key)
			//清除自定义汇率
			shared?.set(false, forKey: "isCustomRate")
			
			NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
				"isCustomRate": false,
				key: data
			])
		}
		
		self.close()
	}
	
	//行高
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 60
	}
	
	// UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchController.searchBar.text != "" {
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
			noDataLabel.text = NSLocalizedString("currencyPicker.noResults", comment: "")
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
