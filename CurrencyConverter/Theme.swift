//
//  Theme.swift
//  CurrencyConverter
//
//  Created by zhi.zhong on 2019/5/3.
//  Copyright © 2019 zhi.zhong. All rights reserved.
//

import UIKit

class Theme {
	
	// 0 白
	// 1 黑
	
	// 主背景色
	static let appBackgroundColor: [UIColor] = [
		UIColor.white,
		UIColor.black
	]
	
	// tableview 背景色
	static let tableBackgroundColor: [UIColor] = [
		UIColor.hex("efefef"),
		UIColor.hex("171717")
	]
	
	// 单元格背景色
	static let cellBackgroundColor: [UIColor] = [
		UIColor.white,
		UIColor.hex("101010")
	]
	
	// 单元格选中时背景色
	static let cellSelectedBackgroundColor: [UIColor] = [
		UIColor.hex("eeeeee"),
		UIColor.hex("333333")
	]
	
	// 单元格文字颜色
	static let cellTextColor: [UIColor] = [
		UIColor.black,
		UIColor.white
	]
	
	// 单元格分割线颜色
	static let cellSeparatorColor: [UIColor] = [
		UIColor.hex("333333"),
		UIColor.hex("333333")
	]
	
	// 输入货币无输入时文字颜色
	static let fromMoneyLabelEmptyTextColor: [UIColor] = [
		UIColor.hex("999999"),
		UIColor.hex("444444")
	]
	
	// 输入货币文字颜色
	static let fromMoneyLabelTextColor: [UIColor] = [
		UIColor.hex("000000"),
		UIColor.hex("ffffff")
	]
	
	// 输出货币无输入时文字颜色
	static let toMoneyLabelEmptyTextColor: [UIColor] = [
		UIColor.hex("aaaaaa"),
		UIColor.hex("333333")
	]
	
	// 输出货币文字颜色
	static let toMoneyLabelTextColor: [UIColor] = [
		UIColor.hex("666666"),
		UIColor.hex("999999")
	]
	
	// 导航栏样式
	static let barStyle: [UIBarStyle] = [
		UIBarStyle.default,
		UIBarStyle.blackTranslucent
	]
	
	// 状态栏样式
	static let statusBarStyle: [UIStatusBarStyle] = [
		UIStatusBarStyle.default,
		UIStatusBarStyle.lightContent
	]
	
	//货币选择页用的是自定义导航条，需要自己覆盖状态条背景
	static let statusBarBackgroundColor: [UIColor] = [
		UIColor.hex("f7f7f7"),
		UIColor.hex("171717")
	]
	
	// 数字按钮背景色
	static let numberButtonBackgroundColor: [UIColor] = [
		UIColor.hex("f5f5f5"),
		UIColor.hex("424242")
	]
	
	// 数字按钮高亮时背景色
	static let numberButtonHighlightedBackgroundColor: [UIColor] = [
		UIColor.hex("cccccc"),
		UIColor.hex("646464")
	]
	
	// 数字文字颜色
	static let numberButtonTextColor: [UIColor] = [
		UIColor.black,
		UIColor.white
	]
	
	// 运算符按钮高亮时背景色
	static let operatorButtonHighlightedBackgroundColor: [UIColor] = [
		UIColor.hex("fbd5aa"),
		UIColor.hex("fbd5aa")
	]
	
	// 运算符按钮选中时背景色
	static let operatorButtonSelectedBackgroundColor: [UIColor] = [
		UIColor.hex("ffca8e"),
		UIColor.hex("fefefe")
	]
	
	// 运算符按钮选中时文字颜色
	static let operatorButtonSelectedTextColor: [UIColor] = [
		UIColor.hex("ffffff"),
		UIColor.hex("fb9601")
	]
	
	// 设置按钮背景色
	static let settingsButtonBackgroundColor: [UIColor] = [
		UIColor.hex("e2e2e2"),
		UIColor.hex("a5a5a5")
	]
	
	// 设置按钮文字颜色
	static let settingsButtonTextColor: [UIColor] = [
		UIColor.hex("000000"),
		UIColor.hex("000000")
	]
	

}
