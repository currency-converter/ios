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
		
		self.initCurrencyNames()
		self.initAlias()
	}
	
	func render() {
		self.view.backgroundColor = UIColor(named: "BackgroundColor")
		
		// 获取屏幕尺寸
		let viewBounds:CGRect = UIScreen.main.bounds
		
		// 状态条高度
//		let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
		
		// 给状态条加上背景色
//		let statusBarBackgroundView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
//        statusBarBackgroundView.backgroundColor = UIColor.hex("0000f7") // Theme.statusBarBackgroundColor[themeIndex]
//		self.view.addSubview(statusBarBackgroundView)
		
		let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
//		navigationBar.barStyle = Theme.barStyle[themeIndex]
		navigationBar.pushItem(navigationitem, animated: true)
		self.view.addSubview(navigationBar)

		editBarButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(onEditClick(_:)))
		doneBarButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onEditClick(_:)))
		navigationitem.leftBarButtonItem = self.editBarButton
		
		let rightBtn = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(onPickerCancel(_:)))
		rightBtn.tintColor = UIColor.loquatYellow
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
//		searchBar.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		searchBar.delegate = self
		guard let searchTextFeild = searchBar.value(forKey: "searchField") as? UITextField else {
			return
		}
		//searchTextFeild.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		// 修改输入文字的颜色
//		searchTextFeild.textColor = Theme.cellTextColor[themeIndex]
		searchTextFeild.tintColor = UIColor.loquatYellow
		// 输入内容大写
		//searchTextFeild.autocapitalizationType = .allCharacters
		// 设置取消按钮字体颜色
		let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.loquatYellow]
		UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
		
		let tableView = UITableView(frame: CGRect(x: 0, y: 0 + navigationBar.frame.size.height, width: viewBounds.width, height: viewBounds.height - navigationBar.frame.size.height), style: .plain)
		let tableViewBackground = UIView(frame: self.view.bounds)
//		tableViewBackground.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		tableView.backgroundView = tableViewBackground
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
	
	@objc func onEditClick(_ sender: UIButton) {
		if self.currencyTableView!.isEditing {
			navigationitem.leftBarButtonItem = self.editBarButton
			self.currencyTableView.setEditing(false, animated: true)
		} else {
			navigationitem.leftBarButtonItem = self.doneBarButton
			self.currencyTableView.setEditing(true, animated: true)
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
    
    // 分组背景色和分组文字颜色
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let headerView = view as? UITableViewHeaderFooterView {
//            headerView.contentView.backgroundColor = Theme.tableBackgroundColor[themeIndex]
//            headerView.textLabel?.textColor = Theme.cellTextColor[themeIndex]
//        }
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
		cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
		cell.layoutMargins = UIEdgeInsets.zero
//		cell.backgroundColor = Theme.cellBackgroundColor[themeIndex]
		cell.selectionStyle = .blue
		let cellBackgroundView = UIView()
//		cellBackgroundView.backgroundColor = Theme.cellSelectedBackgroundColor[themeIndex]
		cell.selectedBackgroundView = cellBackgroundView

		if let flagPath = Bundle.main.path(forResource: symbol, ofType: "png") {
			cell.imageView?.image = UIImage(contentsOfFile: flagPath)
		}

		// label
		cell.textLabel?.text = symbol
//		cell.textLabel?.textColor = Theme.cellTextColor[themeIndex]
		//cell.textLabel?.highlightedTextColor = UIColor.black

		// detail
//		cell.detailTextLabel?.textColor = Theme.cellTextColor[themeIndex]
		//cell.detailTextLabel?.highlightedTextColor = UIColor.black
		cell.detailTextLabel?.text = self.currencyNames[symbol ?? ""]
		cell.detailTextLabel?.textAlignment = .natural

		// accessory
		cell.accessoryType = cell.textLabel?.text == currencySymbol ? .checkmark : .none
		cell.tintColor = UIColor.loquatYellow
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
		return 66
	}
	
	// UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if searchController.searchBar.text != "" {
			return ""
		}
		return self.adHeaders[section]
	}
	
	// 设置单元格的编辑的样式
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		let sectionId:Int = indexPath.section
        let symbol = searchController.searchBar.text != "" && self.searchResults.count > indexPath.row ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		let isFav: Bool = allCurrencies[0]?.contains(symbol ?? "") ?? false

		return isFav ? UITableViewCell.EditingStyle.delete : UITableViewCell.EditingStyle.insert
	}
	
	// 单元格编辑后的响应方法
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let sectionId:Int = indexPath.section
		let symbol = searchController.searchBar.text != "" && self.searchResults.count > indexPath.row ? self.searchResults[indexPath.row] : allCurrencies[sectionId]?[indexPath.row]
		self.toggleFavorite(symbol: symbol ?? "")
	}
	
	// 设置 cell 是否允许移动
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		// 只允许收藏的货币排序
		if self.searchResults.count > 0 {
			return false
		}
		return indexPath.section == 0
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		// 移动cell之后更换数据数组里的循序
		(allCurrencies[0]![sourceIndexPath.row], allCurrencies[0]![destinationIndexPath.row]) = (allCurrencies[0]![destinationIndexPath.row], allCurrencies[0]![sourceIndexPath.row])
		
		//更新缓存
		let shared = UserDefaults(suiteName: Config.groupId)
		shared?.set(allCurrencies[0], forKey: "favorites")
		
		NotificationCenter.default.post(name: .didUserDefaultsChange, object: self, userInfo: [
			"favorites": allCurrencies[0]!
		])
	}
	
	/// 限制跨分区移动
	///
	/// - Parameters: 参数
	///   - tableView: tableView对象，代理的委托人
	///   - sourceIndexPath: 移动之前cell位置
	///   - proposedDestinationIndexPath: 移动之后cell的位置
	/// - Returns: cell移动之后最后位置
	func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		//根据分区下标判断分区是否允许移动，当前后的位置在同一个分区，允许移动，返回移动之后的位置，当前后位置不在同一个分区，不允许移动，返回移动之前的位置
		if sourceIndexPath.section == proposedDestinationIndexPath.section {
			return proposedDestinationIndexPath
		} else {
			return sourceIndexPath
		}
		
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
		//self.currencyTableView?.setContentOffset(CGPoint.zero, animated: false)
		
		if searchController.searchBar.text?.count ?? 0 > 0 && self.searchResults.count == 0 {
			let noDataLabel = UILabel(frame: self.currencyTableView.frame)
			noDataLabel.text = NSLocalizedString("currencyPicker.noResults", comment: "")
			noDataLabel.textAlignment = .center
//			noDataLabel.textColor = Theme.cellTextColor[themeIndex]
			noDataLabel.font = UIFont.boldSystemFont(ofSize: 18)
//			noDataLabel.backgroundColor = Theme.cellBackgroundColor[themeIndex]
			self.currencyTableView.separatorStyle = .none
			self.currencyTableView.backgroundView = noDataLabel
		} else {
			let tableViewBackground = UIView(frame: self.view.bounds)
//			tableViewBackground.backgroundColor = Theme.cellBackgroundColor[themeIndex]
			self.currencyTableView.backgroundView = tableViewBackground
		}
	}
}
