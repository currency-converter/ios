//
//  CurrencyPickerViewController.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/3/21.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class CurrencyPickerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var rates: [String: [String: NSNumber]]!
	
	var allCurrencies = [
		0: [String]([]),
		1: [String]([])
	]
	
	var adHeaders:[String] = [
		NSLocalizedString("currencyPicker.favoriteCurrencies", comment: ""),
		NSLocalizedString("currencyPicker.allCurrencies", comment: "")
	]
	
	var alias: [String: String] = [:]
	
	var currencyNames: [String:String] = [:]
	
	var currencyTableView: UITableView!
	var searchController: UISearchController!
	var navigationitem: UINavigationItem = UINavigationItem()
	var editBarButton: UIBarButtonItem!
	var doneBarButton: UIBarButtonItem!
	
	var searchResults:Array = [String]()
	
	// 当前选中的货币，接收主窗口传递过来的值
	var currencySymbol: String = ""
	var currencyType: String = ""
	
	var themeIndex: Int!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initConfig()
		
		render()
	}
	
	func initConfig() {
		let shared = UserDefaults(suiteName: Config.groupId)
		if let favorites = shared?.array(forKey: "favorites") as? [String] {
			self.allCurrencies[0] = favorites
		} else {
			self.allCurrencies[0] = Config.defaults["favorites"] as? [String]
		}
		self.rates = Config.defaults["rates"] as? [String: [String: NSNumber]]
		self.allCurrencies[1] = Array((self.rates).keys.sorted())
		self.themeIndex = shared?.integer(forKey: "theme")
        switch self.themeIndex {
            case 0:
                overrideUserInterfaceStyle = .light
            case 1:
                overrideUserInterfaceStyle = .dark
            default:
                print("")
        }
		
		self.initCurrencyNames()
		self.initAlias()
	}
	
	func render() {
		self.view.backgroundColor = UIColor(named: "BackgroundColor")
		
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
		navigationBar.pushItem(navigationitem, animated: true)
		self.view.addSubview(navigationBar)
        
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(onPickerCancel(_:)))
		navigationitem.title = NSLocalizedString("currencyPicker.title", comment: "")
		navigationitem.rightBarButtonItem = rightBtn
		
		let searchController = UISearchController(searchResultsController: nil)
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
		searchBar.searchBarStyle = .minimal
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            textFieldInsideSearchBar.textColor = self.themeIndex == 1 ? UIColor.white : UIColor.black // UIColor(named: "FromMoneyLabelTextColor")
        }
		searchBar.delegate = self
        guard searchBar.value(forKey: "searchField") is UITextField else {
			return
		}
		
		let tableView = UITableView(frame: CGRect(x: 0, y: 0 + navigationBar.frame.size.height, width: viewBounds.width, height: viewBounds.height - navigationBar.frame.size.height), style: .plain)
		tableView.showsVerticalScrollIndicator = true
		tableView.delegate = self
		tableView.dataSource = self
		tableView.tableHeaderView = searchController.searchBar
		//去掉没有数据显示部分多余的分隔线
		tableView.tableFooterView =  UIView.init(frame: CGRect.zero)
		//将分隔线offset设为零，即将分割线拉满屏幕
		//tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		//设置分隔线颜色
//		tableView.separatorColor = Theme.cellSeparatorColor[themeIndex]
		//滚动时隐藏键盘
		tableView.keyboardDismissMode = .onDrag
		//进入页面时隐藏searchbar
		//tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
		tableView.register(NSClassFromString("CurrencyTableViewCell"), forCellReuseIdentifier: "cellId")
		self.view.addSubview(tableView)
		self.currencyTableView = tableView
	}
	
	@objc func onPickerCancel(_ sender: UIButton) {
		self.close()
	}
    
    
    // 在点击事件的处理方法中处理点击事件
    @objc func labelTapped(_ sender: UIButton) {
        if let value = sender.accessibilityHint {
            toggleFavorite(symbol: value)
        }
    }
	
	// 收藏/取消收藏
	func toggleFavorite(symbol: String) {
		let shared = UserDefaults(suiteName: Config.groupId)
		var favorites:[String] = shared?.array(forKey: "favorites") as? [String] ?? [String]()
		let currency = symbol
		if favorites.contains(currency) {
			favorites = favorites.filter {$0 != currency}
		} else {
			favorites.append(currency)
		}
		shared?.set(favorites, forKey: "favorites")
		
		self.allCurrencies[0] = favorites
		self.currencyTableView.reloadData()
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"favorites": favorites
		])
	}
	
	func initCurrencyNames() {
		currencyNames[""] = NSLocalizedString("currencyPicker.unknow", comment: "")
		for currency in allCurrencies[1]! {
			currencyNames[currency] = NSLocalizedString(currency, comment: "")
		}
	}
	
	func initAlias() {
		let a: String = NSLocalizedString("alias", comment: "")
		let b: [String] = a.components(separatedBy: "&")
		for c in b {
			let d: [String] = c.trimmingCharacters(in: .whitespaces).components(separatedBy: "=")
			if d.count == 2 {
				self.alias[d[0].trimmingCharacters(in: .whitespaces)] = d[1].trimmingCharacters(in: .whitespaces)
			}
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
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 30
	}
	
	//cell
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let sectionId:Int = indexPath.section
		let symbol = searchController.searchBar.text != "" && self.searchResults.count > indexPath.row ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]

		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
		cell.preservesSuperviewLayoutMargins = false
		cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		cell.layoutMargins = UIEdgeInsets.zero
		cell.selectionStyle = .blue

		if let flagPath = Bundle.main.path(forResource: symbol, ofType: "png") {
			cell.imageView?.image = UIImage(contentsOfFile: flagPath)
		}

		// label
		cell.textLabel?.text = symbol
		cell.detailTextLabel?.text = self.currencyNames[symbol ?? ""]
		cell.detailTextLabel?.textAlignment = .natural
        
        let isFavorite = self.allCurrencies[0]?.contains(symbol ?? "") ?? false

		// accessory
        let customAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        
        let button = UIButton(type: .system)
        button.frame = customAccessoryView.bounds
        button.setTitle(isFavorite ? "★" : "☆", for: .normal)
        button.setTitleColor(self.themeIndex == 1 ? .white : .black, for: .normal)
        button.accessibilityHint = symbol
        // 添加点击事件
        button.addTarget(self, action: #selector(labelTapped(_:)), for: .touchUpInside)
        // 将 UIButton 添加到 customAccessoryView 中
        customAccessoryView.addSubview(button)
        
        cell.accessoryView = customAccessoryView
        cell.backgroundColor = cell.textLabel?.text == currencySymbol ? .systemBlue : .none
		return cell
	}
	
	//选中cell时触发这个代理
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//取消选中的样式
		tableView.deselectRow(at: indexPath, animated: true)
		
		//获取当前选中的单元格
		let cell: UITableViewCell! = tableView.cellForRow(at: indexPath)
		let data: String = (cell.textLabel?.text)!
		self.searchController.isActive = false
		let key: String = "\(currencyType)Symbol"
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(data, forKey: key)
		//清除自定义汇率
		shared?.set(false, forKey: "isCustomRate")

		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"isCustomRate": false,
			"changeType": "pick",
			key: data
		])

		self.close()
	}
	
	//行高
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 48
	}
	
	// UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchController.searchBar.text != "" {
			return self.searchResults.count == 0 ? NSLocalizedString("currencyPicker.noResults", comment: "") : NSLocalizedString("currencyPicker.searchResults", comment: "")
		}
		return self.adHeaders[section]
	}
}


extension CurrencyPickerViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		self.searchResults.removeAll(keepingCapacity: false)

		let keyword:String = searchController.searchBar.text!.uppercased()
		//从key和value中都找一遍
		for currency in currencyNames {
			if currency.key.contains(keyword) || currency.value.uppercased().contains(keyword) {
				self.searchResults.append(currency.key)
			}
		}
		
		for a in self.alias {
			if a.value.uppercased().contains(keyword) && !self.searchResults.contains(a.key) {
				self.searchResults.append(a.key)
			}
		}

		self.currencyTableView?.reloadData()
	}
}
